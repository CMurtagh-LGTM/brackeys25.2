class_name GameManager
extends Node2D

signal finished(player_position: int, player_score: int)

@onready var _hand_scene: PackedScene = preload("res://Hand/Hand.tscn")

@onready var _arrow: Node2D = $Arrow
@onready var _next: Button = $Next
@onready var _bonus_pile: Stack = $Bonus
@onready var _bonus_label: Label = $Bonus/Label
@onready var _discard_pile: Stack = $Discard

# const over_under_bid_text: Array[String] = ["Underbid", "Overbid"]

@onready var _bid_info: Node2D = $BidInfo
@onready var _total_bid_label: Label = $BidInfo/Total/Label
@onready var _call_info: Label = $BidInfo/CallInfo
@onready var _win_condition: Node2D = $WinCondition
@onready var _win_condition_label: Label = %WinConditionLabel
@onready var _remaining_rounds_label: Label = %RemainingRounds
@onready var _triumph_chooser: TriumphChooser = $TriumphChooser
@onready var _deck_order_label: Label = %DeckOrder
@onready var _origin: Node2D = $Origin

@onready var _pips: Array[Sprite2D] = [$Pips/Pip0, $Pips/Pip1, $Pips/Pip2, $Pips/Pip3, $Pips/Pip4]

@onready var _deck: Deck = $Deck
@onready var _trick: Trick = $Trick

const _arrow_offsets: Array[Vector2] = [
	Vector2.DOWN * -Card.height,
	Vector2.LEFT * -Card.height,
	Vector2.UP * -Card.height,
	Vector2.RIGHT * -Card.height,
]

var initialized: bool = false

var _deck_info: DeckInfo = preload("res://Resources/Decks/French53.tres")
var _ai_info: AIInfo

var _deal_size: int = 7 # Number of cards to deal
var _deal_packets: Array = [
	[1],
	[2],
	[3],
	[2, 2],
	[3, 2],
	[2, 2, 2],
	[2, 3, 2],
	[3, 2, 3],
	[3, 3, 3],
	[3, 2, 2, 3],
]
var _deal_count: int = 3 # Number of times to deal

var _hands: Array[Hand]
var _triumphs: Array[Triumph]

var _current_hand: int = 0
var _hand_count: int = 4
var _dealer: int = 0
var _tricks_remaining: int = 0
var _deals_remaining: int = 0

var _game_state: GameState

var _win_condition_text: String = ""

var _current_arrow_point: Hand.Compass

const _pile_seperation: float = 10
const _next_position_offset: Vector2 = Vector2(74, 56)
const _bid_position_offset: Vector2 = Vector2(0, 100)
const _deck_position_offset: Vector2 = Vector2(-184, 0)
const _turnup_position_offset: Vector2 = _deck_position_offset + Vector2.LEFT * (Card.width + _pile_seperation)
const _discard_pile_position_offset: Vector2 = - _deck_position_offset
const _bonus_pile_position_offset: Vector2 = - _deck_position_offset + Vector2.RIGHT * (Card.width + _pile_seperation)
const _win_condition_position_offset: Vector2 = Vector2.UP * 110

func set_deck_info(deck_info: DeckInfo) -> void:
	assert(not initialized)
	_deck_info = deck_info

func set_ai_info(ai_info: AIInfo) -> void:
	assert(not initialized)
	_ai_info = ai_info

func set_deal_count(count: int) -> void:
	assert(not initialized)
	_deal_count = count

func set_trick_count(count: int) -> void:
	assert(not initialized)
	_deal_size = count

func set_win_condition(text: String) -> void:
	assert(not initialized)
	_win_condition_text = text

func set_hand_count(count: int) -> void:
	assert(count >= 2 and count <= 4)
	_hand_count = count

func set_triumphs(triumphs: Array[Triumph]) -> void:
	assert(not initialized)
	_triumphs = triumphs

func _ready() -> void:
	initialized = true
	globals.viewport_resize.connect(_on_viewport_resize)

	_start_game()

func _calculate_triumph_game_state() -> TriumphGameState:
	return TriumphGameState.new(_hands[0], _hands, _deck, _discard_pile, _bonus_pile, _origin, _game_state)

func _on_hand_play(card: Card) -> void:
	_hands[_current_hand].lose_turn()
	await _trick.add_card(card, _game_state.trump(), _hand_index_to_compass(_current_hand))
	_current_hand += 1
	_current_hand %= _hands.size()
	if _trick.card_count() >= _hands.size():
		_end_trick()
		return
	_hands[_current_hand].gain_turn()
	_point_to_hand(_hand_index_to_compass(_current_hand))

func _start_game() -> void:
	_deals_remaining = _deal_count

	_win_condition_label.text = _win_condition_text
	_deck_order_label.text = _deck_info.deck_order

	_next.visible = false
	_bid_info.visible = false
	_bonus_label.visible = false
	_triumph_chooser.visible = false
	for pip: Sprite2D in _pips:
		pip.modulate.a = 0

	_deck.deck_info = _deck_info
	_deck.reset()
	_deck.set_discard_pile(_discard_pile)

	_game_state = GameState.new(_deck_info, _trick, _hand_count)
	_game_state.trump_changed.connect(_on_update_game_state_trump)
	_game_state.turnup_changed.connect(_on_turnup_changed)

	_bonus_pile.cards_updated.connect(_on_bonus_pile_changed)

	for index: int in _hand_count:
		var hand: Hand = _hand_scene.instantiate()
		var compass: Hand.Compass = _hand_index_to_compass(index)

		hand.rotation = Globals.hand_rotations[compass]

		_hands.push_back(hand)
		add_child(hand)
		hand.play.connect(_on_hand_play)

		hand.reset()
		hand.set_game_state(_game_state)

	_hands[0].set_is_player()
	for hand_index: int in range(1, _hands.size()):
		_hands[hand_index].set_ai(AI.new(_ai_info))
	_dealer = randi_range(0, _hands.size() - 1)

	for bid_index: int in _deal_size + 1:
		_game_state.add_bid(NormalBid.new(bid_index))
	
	for triumph: Triumph in _triumphs:
		triumph.apply_game_modifier(_calculate_triumph_game_state())

	call_deferred("_on_viewport_resize")
	_deal()

func _end_game() -> void:
	var positions: Array[Hand] = _hands.duplicate()
	positions.sort_custom(func(a: Hand, b:Hand):
		if a.get_total_score() == b.get_deal_score():
			return 
		return a.get_total_score() > b.get_total_score()
	)

	finished.emit(positions.find(_hands[0]), _hands[0].get_total_score())

func _deal() -> void:
	_deals_remaining -= 1

	_remaining_rounds_label.text = str(_deals_remaining + 1)

	_game_state.set_trump(null);
	_hands[_dealer].set_is_dealer()
	_current_hand = (_dealer + 1) % _hands.size()
	assert(_deal_packets[_deal_size-1].reduce(Utils.sum) == _deal_size)
	for packet: int in _deal_packets[_deal_size-1]:
		for relative_hand_index: int in _hands.size():
			var hand = _hands[(relative_hand_index + _current_hand) % _hands.size()]
			for _i in range(packet):
				await hand.add_card(await _deck.draw_card())

	var turnup: Card = await _deck.draw_card()
	_game_state.set_turnup(turnup)

	_tricks_remaining = _deal_size
	_triumphs_before_bid()

func _on_turnup_changed() -> void:
	if _game_state.turnup() != null:
		_game_state.set_trump(_game_state.turnup().suit(null))
		await _game_state.turnup().move_to(self, globals.viewport_center() + _turnup_position_offset, 0, Globals.card_deal_time)

func _triumphs_before_bid() -> void:
	_point_to_hand(_hand_index_to_compass(0))
	var game_state := _calculate_triumph_game_state()

	_triumph_chooser.visible = true
	while true:
		var triumphs_before_bid: Array[Triumph] = []
		for triumph: Triumph in _triumphs:
			if not triumph.has_before_bid(game_state):
				continue
			triumphs_before_bid.append(triumph)
		
		# None left
		if triumphs_before_bid.is_empty():
			break

		var triumph: Triumph = await _triumph_chooser.choose(triumphs_before_bid, 0.75, true)

		# Check skip pressed
		if triumph != null:
			await triumph.before_bid(game_state)
		else:
			break
	_triumph_chooser.visible = false

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
		@warning_ignore("narrowing_conversion")
		var minimum_bid: int = ceilf((_deal_size - current_total + 1) / float(_hands.size() - relative_bid_index))

		if hand.is_player():
			await hand.player_bid(minimum_bid)
		else:
			var current_bid_score: int = _hands[highest_bidder_index].current_bid().score if _hands[highest_bidder_index].current_bid() else 0
			await hand.ai_bid(minimum_bid, _deal_size, current_bid_score, _deck.peek_top())

		if hand.current_bid().score > _hands[highest_bidder_index].current_bid().score:
			highest_bidder_index = _current_hand

		current_total += hand.current_bid().score
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

	# Highest bidder gets right to card turned up
	var highest_bidder: Hand = _hands[highest_bidder_index]
	highest_bidder.add_card(_game_state.turnup())
	_game_state.set_turnup(null)
	var _discarded_cards: Array[Card] = await highest_bidder.discard(_deal_size, Hand.DiscardTarget.BONUS)
	await _bonus_pile.append(_discarded_cards)
	_bid_info.visible = false

	_start_trick()

func _on_bonus_pile_changed() -> void:
	_bonus_label.text = str(_calculate_bonus_score())
	_bonus_label.visible = not _bonus_pile.is_empty()

func _start_trick() -> void:
	_hands[_current_hand].gain_turn()
	_point_to_hand(_hand_index_to_compass(_current_hand))

func _end_trick() -> void:
	var winner: Hand.Compass = _trick.get_winner(_game_state.trump())
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
		if card.suit(_game_state.trump()) != _game_state.trump():
			continue
		bonus += 1
		if card.ordinal() > Card.Ordinal.THIRTEEN:
			bonus += 1
		if card.get_bower(_game_state.trump()) != Card.Bower.NONE:
			bonus += 1
	return bonus

func _end_deal() -> void:
	var cards: Array[Card] = []

	# Work out who should get bonus
	var top_score_index: int = (_dealer + 1) % _hands.size()
	for relative_hand_index: int in _hands.size():
		var hand_index: int = (relative_hand_index + _dealer + 1) % _hands.size()
		if (_hands[hand_index].get_deal_score() >= _hands[top_score_index].get_deal_score() and
			(_hands[hand_index].get_deal_score() > _hands[top_score_index].get_deal_score() or
				_hands[hand_index].current_bid().score > _hands[top_score_index].current_bid().score)
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

	if _deals_remaining > 0:
		_deal()
	else: 
		_end_game()

func _on_update_game_state_trump() -> void:
	for pip: Sprite2D in _pips:
		var target_colour: Color = pip.modulate
		if _game_state.trump() != null:
			pip.texture = _game_state.trump().texture

			var a: float = pip.modulate.a
			pip.modulate = Suit.colours[_game_state.trump().colour]
			pip.modulate.a = a
			target_colour = Suit.colours[_game_state.trump().colour]

		target_colour.a = float(_game_state.trump() != null)
		create_tween().tween_property(pip, "modulate", target_colour, 0.2)

func _compass_to_hand_index(compass: Hand.Compass) -> int:
	if _hand_count == 4:
		return compass as int
	if _hand_count == 3:
		assert(compass != Hand.Compass.NORTH)
		return [0, 1, -1, 2][compass]
	if _hand_count == 2:
		assert(compass != Hand.Compass.EAST)
		assert(compass != Hand.Compass.WEST)
		return [0, -1, 1, -1][compass]
	assert(false)
	return -1

func _hand_index_to_compass(index: int) -> Hand.Compass:
	if _hand_count == 4:
		return Globals.hand_compasses[index]
	if _hand_count == 3:
		return [Hand.Compass.SOUTH, Hand.Compass.WEST, Hand.Compass.EAST][index]
	if _hand_count == 2:
		return [Hand.Compass.SOUTH, Hand.Compass.NORTH][index]
	assert(false)
	return Hand.Compass.SOUTH

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
	_win_condition.position = globals.viewport_center() + _win_condition_position_offset
	_deck_order_label.position = globals.viewport_size - _deck_order_label.size
	_origin.position = globals.viewport_center()

	if _game_state.turnup():
		_game_state.turnup().position = globals.viewport_center() + _turnup_position_offset

	_bonus_pile.position = globals.viewport_center() + _bonus_pile_position_offset
	for hand_index: int in _hands.size():
		_hands[hand_index].position = globals.hand_position(_hand_index_to_compass(hand_index))

	_trick.position = globals.viewport_center()
	_pips[0].position = globals.viewport_center()
	_pips[1].position = Globals.pip_offset
	_pips[2].position = Vector2(globals.viewport_size.x - Globals.pip_offset.x, Globals.pip_offset.y)
	_pips[3].position = Vector2(Globals.pip_offset.x, globals.viewport_size.y - Globals.pip_offset.y)
	_pips[4].position = Vector2(globals.viewport_size.x - Globals.pip_offset.x, globals.viewport_size.y - Globals.pip_offset.y)

	_arrow.position = globals.hand_position(_current_arrow_point) + _arrow_offsets[_current_arrow_point]
