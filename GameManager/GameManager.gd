class_name GameManager
extends Node2D

var deck_info: DeckInfo = preload("res://Resources/Decks/French32.tres")

@onready var _hand_scene: PackedScene = preload("res://Hand/Hand.tscn")
@onready var _deck_scene: PackedScene = preload("res://Deck/Deck.tscn")
@onready var _trick_scene: PackedScene = preload("res://Trick/Trick.tscn")

@onready var _arrow: Node2D = $Arrow
@onready var _next: Button = $Next
@onready var _bonus_pile: Stack = $Bonus
@onready var _bonus_label: Label = $Bonus/Label
@onready var _discard_pile: Stack = $Discard

# const over_under_bid_text: Array[String] = ["Underbid", "Overbid"]

@onready var _bid_info: Node2D = $BidInfo
@onready var _total_bid_label: Label = $BidInfo/Total/Label
@onready var _call_info: Label = $BidInfo/CallInfo

@onready var _pips: Array[Sprite2D] = [$Pips/Pip0, $Pips/Pip1, $Pips/Pip2, $Pips/Pip3, $Pips/Pip4]

const _arrow_offsets: Array[Vector2] = [
	Vector2.DOWN * -Card.height,
	Vector2.LEFT * -Card.height,
	Vector2.UP * -Card.height,
	Vector2.RIGHT * -Card.height,
]
const _pip_offset: Vector2 = Vector2(46, 49)

var _deal_size: int = 7 # Number of cards to deal
var _deal_packets: Array[int] = [2, 3, 2]
var _deal_count: int = 3 # Number of times to deal

var _deck: Deck
var _hands: Array[Hand]
var _trick: Trick
var _turnup: Card = null

var _trump: Suit
var _current_hand: int = 0
var _dealer: int = 0
var _tricks_remaining: int = 0

var _current_arrow_point: Hand.Compass

const _pile_seperation: float = 10
const _next_position_offset: Vector2 = Vector2(74, 56)
const _bid_position_offset: Vector2 = Vector2(0, 100)
const _deck_position_offset: Vector2 = Vector2(-184, 0)
const _turnup_position_offset: Vector2 = _deck_position_offset + Vector2.LEFT * (Card.width + _pile_seperation)
const _discard_pile_position_offset: Vector2 = - _deck_position_offset
const _bonus_pile_position_offset: Vector2 = - _deck_position_offset + Vector2.RIGHT * (Card.width + _pile_seperation)

func _ready() -> void:
	globals.viewport_resize.connect(_on_viewport_resize)

	_deck = _deck_scene.instantiate()
	_deck.deck_info = deck_info
	add_child(_deck)

	_trick = _trick_scene.instantiate()
	add_child(_trick)

	_next.visible = false
	_bid_info.visible = false

	_bonus_label.visible = false

	for pip: Sprite2D in _pips:
		pip.modulate.a = 0

	for compass: Hand.Compass in Globals.hand_compasses:
		var hand: Hand = _hand_scene.instantiate()

		hand.rotation = Globals.hand_rotations[compass]

		_hands.push_back(hand)
		add_child(hand)
		hand.play.connect(_on_hand_play)

	_on_viewport_resize()

	_hands[0].set_is_player()

	_dealer = randi_range(0, 3)

	_deal()

func _calculate_game_state() -> GameState:
	return GameState.new(_trump, _trick.lead_suit(_trump), _deck.deck_info, _trick.get_cards(), _trick.card_count() == _hands.size() - 1)

func _on_hand_play(card: Card) -> void:
	_hands[_current_hand].lose_turn()
	card.reveal()
	await _trick.add_card(card, _hand_index_to_compass(_current_hand))
	_current_hand += 1
	_current_hand %= _hands.size()
	if _trick.card_count() >= _hands.size():
		_end_trick()
		return
	_hands[_current_hand].gain_turn(_calculate_game_state())
	_point_to_hand(_hand_index_to_compass(_current_hand))

static func sum(accum, number):
	return accum + number

func _deal() -> void:
	_trump = null;
	_on_update_trump()
	_hands[_dealer].set_is_dealer()
	_current_hand = (_dealer + 1) % _hands.size()
	assert(_deal_packets.reduce(sum) == _deal_size)
	for packet: int in _deal_packets:
		for relative_hand_index: int in _hands.size():
			var hand = _hands[(relative_hand_index + _current_hand) % _hands.size()]
			for _i in range(packet):
				await hand.add_card(_deck.draw_card())

	var turnup: Card = _deck.draw_card()
	turnup.reveal()
	await turnup.move_to(self, globals.viewport_center() + _turnup_position_offset, 0, Globals.card_deal_time)
	_turnup = turnup

	_trump = turnup.suit(null)
	_on_update_trump()

	_tricks_remaining = _deal_size
	_start_bid()

func _start_bid() -> void:
	# Get bids from players
	var current_total := 0
	var highest_bidder_index: int = _current_hand
	_bid_info.visible = true
	_total_bid_label.text = str(current_total)
	_call_info.text = ""
	for relative_bid_index: int in _hands.size():
		var hand: Hand = _hands[_current_hand]
		_point_to_hand(_hand_index_to_compass(_current_hand))

		# Make sure that the game is overcalled
		# floor(amount_underbid / yet_to_bid_players)
		@warning_ignore("integer_division")
		var disallowed_bid: int = (_deal_size - current_total) / (_hands.size() - relative_bid_index)

		if hand.is_player():
			await hand.player_bid(disallowed_bid)
		else:
			await hand.ai_bid(disallowed_bid, _hands[highest_bidder_index].current_bid(), _deck.peek_top(), _calculate_game_state())

		if hand.current_bid() > _hands[highest_bidder_index].current_bid():
			highest_bidder_index = _current_hand

		current_total += hand.current_bid()
		_total_bid_label.text = str(current_total)
		_current_hand += 1
		_current_hand %= _hands.size()

	# Display info
	# if current_total < _deal_size:
	# 	_call_info.text = over_under_bid_text[0]
	# elif current_total > _deal_size:
	# 	_call_info.text = over_under_bid_text[1]

	_point_to_hand(_hand_index_to_compass(highest_bidder_index))
	_arrow.modulate = Globals.LIGHT_GREEN
	await get_tree().create_timer(Globals.breath_time).timeout
	_bid_info.visible = false

	# Highest bidder gets right to card turned up
	var highest_bidder: Hand = _hands[highest_bidder_index]
	highest_bidder.add_card(_turnup)
	_turnup = null
	var _discarded_cards: Array[Card] = await highest_bidder.discard(_deal_size, _calculate_game_state(), "Bonus")
	for card in _discarded_cards:
		card.reveal()
	await _bonus_pile.append(_discarded_cards)
	_bonus_label.text = str(_calculate_bonus_score())
	_bonus_label.visible = true

	_start_trick()

func _start_trick() -> void:
	_hands[_current_hand].gain_turn(_calculate_game_state())
	_point_to_hand(_hand_index_to_compass(_current_hand))

func _end_trick() -> void:
	var winner: Hand.Compass = _trick.get_winner(_trump)
	_point_to_hand(winner)
	_current_hand = _compass_to_hand_index(winner)
	_arrow.modulate = Globals.LIGHT_GREEN
	_next.visible = true
	await _next.pressed

	_next.visible = false
	await _hands[_compass_to_hand_index(winner)].winning_trick(_trick.clear())
	_tricks_remaining -= 1
	if _tricks_remaining > 0:
		_start_trick()
	else:
		_end_deal()

func _calculate_bonus_score() -> int:
	var bonus: int = 0
	for card: Card in _bonus_pile.get_cards():
		if card.suit(_trump) != _trump:
			continue
		bonus += 1
		if card.ordinal() > Card.Ordinal.THIRTEEN:
			bonus += 1
		if card.get_bower(_trump) != Card.Bower.NONE:
			bonus += 1
	return bonus

func _end_deal() -> void:
	var cards: Array[Card] = []

	# Work out who should get bonus
	var top_score_index: int = _dealer + 1 % _hands.size()
	for relative_hand_index: int in _hands.size():
		var hand_index: int = (relative_hand_index + _dealer + 1) % _hands.size()
		if (_hands[hand_index].get_deal_score() >= _hands[top_score_index].get_deal_score() and
			(_hands[hand_index].get_deal_score() > _hands[top_score_index].get_deal_score() or _hands[hand_index].current_bid() > _hands[top_score_index].current_bid())
		):
			top_score_index = hand_index

	# Apply scores
	var bonus_score: int = _calculate_bonus_score()
	for hand_index: int in _hands.size():
		_hands[hand_index].update_score(bonus_score if hand_index == top_score_index else 0)
	_bonus_label.visible = false

	# Reset cards
	for hand: Hand in _hands:
		cards.append_array(hand.clear())
	cards.append_array(_discard_pile.clear())
	cards.append_array(_bonus_pile.clear())
	_dealer += 1
	_dealer %= _hands.size()
	await _deck.add_cards(cards)
	_deck.shuffle()

	await get_tree().create_timer(Globals.breath_time).timeout

	_deal()

func _on_update_trump() -> void:
	for pip: Sprite2D in _pips:
		var target_colour: Color = pip.modulate
		if _trump != null:
			pip.texture = _trump.texture

			var a: float = pip.modulate.a
			pip.modulate = Suit.colours[_trump.colour]
			pip.modulate.a = a
			target_colour = Suit.colours[_trump.colour]

		target_colour.a = float(_trump != null)
		create_tween().tween_property(pip, "modulate", target_colour, 0.2)

func _compass_to_hand_index(compass: Hand.Compass) -> int:
	return compass as int

func _hand_index_to_compass(index: int) -> Hand.Compass:
	return Globals.hand_compasses[index]

func _point_to_hand(compass: Hand.Compass) -> void:
	_current_arrow_point = compass
	_arrow.modulate = Globals.BLACK
	_arrow.position = globals.hand_position(compass) + _arrow_offsets[compass]
	_arrow.rotation = Globals.hand_rotations[compass]

func _on_viewport_resize() -> void:
	_next.position = globals.viewport_center() + _next_position_offset
	_deck.position = globals.viewport_center() + _deck_position_offset
	_bid_info.position = globals.viewport_center()
	_discard_pile.position = globals.viewport_center() + _discard_pile_position_offset

	if _turnup:
		_turnup.position = globals.viewport_center() + _turnup_position_offset

	_bonus_pile.position = globals.viewport_center() + _bonus_pile_position_offset
	for hand_index: int in _hands.size():
		_hands[hand_index].position = globals.hand_position(_hand_index_to_compass(hand_index))

	_trick.position = globals.viewport_center()
	_pips[0].position = globals.viewport_center()
	_pips[1].position = _pip_offset
	_pips[2].position = Vector2(globals.viewport_size.x - _pip_offset.x, _pip_offset.y)
	_pips[3].position = Vector2(_pip_offset.x, globals.viewport_size.y - _pip_offset.y)
	_pips[4].position = Vector2(globals.viewport_size.x - _pip_offset.x, globals.viewport_size.y - _pip_offset.y)

	_arrow.position = globals.hand_position(_current_arrow_point) + _arrow_offsets[_current_arrow_point]
