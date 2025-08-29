class_name Hand
extends Node2D

const _seperation: float = 5

enum Compass {
	SOUTH, WEST, NORTH, EAST
}

enum DiscardTarget {
	DISCARD, BONUS
}

@onready var _stack: Stack = $Stack
@onready var _hand_score_label: Label = $HandScore
@onready var _dealer_icon: Node2D = $Dealer
@onready var _bid: BidChooser = $Bid
@onready var _bid_indicator: Node2D = $BidIndicator
@onready var _bid_label: Label = $BidIndicator/Panel/Label
@onready var _info_display: Node2D = $Info
@onready var _info_display_label: Label = $Info/Label
@onready var _total_score_indicator: Node2D = $TotalScore
@onready var _total_score_label: Label = $TotalScore/Panel/Label

var _cards: Array[Card] = []
var _ai: AI
var _focus_index: int = -1
var _current_deal_score: int = 0
var _current_bid: Bid = null
var _total_score: int = 0

var _has_turn: bool = false
var _is_discarding: bool = false

var _game_state: GameState

signal play(Card)
signal _discard_card(Card)

func add_card(card: Card, index: int = -1, time: float = Globals.card_deal_time) -> void:
	if index == -1:
		_cards.push_back(card)
	else:
		_cards.insert(index, card)
	await card.move_to(self, Vector2.ZERO, 0, time)
	card.reveal(globals.open_hands or _ai == null)
	if _ai == null:
		card.clicked.connect(_on_card_clicked.bind(card))
		card.hovered.connect(_on_card_hovered.bind(card))

		if _game_state != null and card.get_bower(_game_state.trump()):
			card.highlight(card.get_bower_colour())
		else:
			card.unhighlight()

	_position_cards()

func remove_card(card: Card) -> void:
	if _ai == null:
		card.clicked.disconnect(_on_card_clicked)
		card.hovered.disconnect(_on_card_hovered)
	_cards.erase(card)
	_focus_index = -1
	_position_cards()

func get_hand_size() -> int:
	return _cards.size()

func random_card() -> Card:
	if _cards.is_empty():
		return null
	return _cards.pick_random()

func discard_last_card() -> Card:
	assert(not _cards.is_empty())
	var card: Card = _cards[-1]
	remove_card(card)
	return card

func discard(new_hand_size: int, target: DiscardTarget) -> Array[Card]:
	_is_discarding = true
	_info_display.visible = true

	var target_string: String = ""
	if target == DiscardTarget.DISCARD:
		target_string = "Discard Pile"
	elif target == DiscardTarget.BONUS:
		target_string = "Bonus Pile"
	_info_display_label.text = "Discarding to " + target_string

	var cards_discarded: Array[Card] = []
	while _cards.size() - cards_discarded.size() > new_hand_size:
		var card: Card
		if _ai == null:
			card = await _discard_card

			card.clicked.disconnect(_on_card_clicked)
			card.hovered.disconnect(_on_card_hovered)
		else:
			# Other targets are unimplemented
			assert(target == DiscardTarget.BONUS)
			card = _cards[await _ai.decide_bonus_discard(_cards, _game_state)]
		cards_discarded.push_back(card)
		card.conceal()
		_focus_index = -1
		_position_cards()

	for card: Card in cards_discarded:
		_cards.erase(card)
	_position_cards()

	_is_discarding = false
	_info_display.visible = false
	return cards_discarded

func is_player() -> bool:
	return _ai == null

func set_ai(ai: AI) -> void:
	_ai = ai

func set_is_player() -> void:
	if _ai == null:
		return
	_ai = null
	for card: Card in _cards:
		card.reveal()
		card.clicked.connect(_on_card_clicked.bind(card))
		card.hovered.connect(_on_card_hovered.bind(card))

func set_is_dealer() -> void:
	_dealer_icon.visible = true

func winning_trick(cards_: Array[Card]) -> void:
	await _stack.append(cards_)
	_current_deal_score += 1
	_hand_score_label.text = str(_current_deal_score)
	_hand_score_label.visible = true
	if _current_bid.has_met(_current_deal_score):
		_bid_indicator.modulate = Globals.LIGHT_RED if not _current_bid.has_met(_current_deal_score) else Globals.LIGHT_GREEN

func get_deal_score() -> int:
	return _current_deal_score

func update_score(bonus: int = 0) -> void:
	if _current_bid.has_met(_current_deal_score):
		_total_score += _current_bid.score(_game_state) + bonus
	else:
		_total_score -= _current_bid.score(_game_state)
	_total_score_label.text = str(_total_score)
	_current_deal_score = 0

# To be used by triumphs
func add_score(score: int) -> void:
	_total_score += score
	_total_score_label.text = str(_total_score)

func get_total_score() -> int:
	return _total_score

func player_bid(min_allowed_bid: int) -> void:
	_info_display.visible = true
	_info_display_label.text = "Bidding"

	_bid.visible = true
	_current_bid = await _bid.choose_bid(_game_state, min_allowed_bid)
	_bid.visible = false
	_info_display.visible = false
	_set_bid_indicator()

func ai_bid(min_allowed_bid: int, max_allowed_bid: int, highest_bid: int, revealed_card: Card) -> void:
	_info_display.visible = true
	_info_display_label.text = "Bidding"
	var bid_index: int = await _ai.decide_bid(min_allowed_bid, max_allowed_bid, highest_bid, revealed_card, _game_state, _cards)
	_current_bid = _game_state.bids()[bid_index]
	_info_display.visible = false
	_set_bid_indicator()

func current_bid() -> Bid:
	return _current_bid

func cards() -> Array[Card]:
	return _cards.duplicate()

## end of a trick
func clear() -> Array[Card]:
	var cards_ = _cards.duplicate()
	for card: Card in cards_:
		card.reset_state()
	_cards.clear()
	cards_.append_array(_stack.clear())
	_focus_index = -1
	_current_deal_score = 0
	_current_bid = null
	_hand_score_label.visible = false
	_dealer_icon.visible = false
	_bid.visible = false
	_bid_indicator.visible = false
	_info_display.visible = false
	return cards_

## end of a game
func reset() -> void:
	_total_score = 0
	_total_score_label.text = str(_total_score)
	clear()

func set_game_state(game_state: GameState) -> void:
	if _game_state != null:
		_game_state.trump_changed.disconnect(_on_trump_update)
	_game_state = game_state
	_game_state.trump_changed.connect(_on_trump_update)

func _on_trump_update() -> void:
	if _ai == null:
		for card: Card in _cards:
			if card.get_bower(_game_state.trump()):
				card.highlight(card.get_bower_colour())
			else:
				card.unhighlight()
	
func gain_turn() -> void:
	_has_turn = true
	_info_display.visible = true
	_info_display_label.text = "Playing"

	for card: Card in _cards:
		card.set_active(true)
	if _ai != null:
		_play_turn()

func lose_turn() -> void:
	_has_turn = false
	_info_display.visible = false
	for card: Card in _cards:
		card.set_active(false)
	_focus_index = -1
	_position_cards()

func _hand_arc(x: float) -> float:
	return (1.0/4.0)*x**2.0-1.0/16

func _hand_arc_derivative(x: float) -> float:
	return 0.5 * x

func _play_turn() -> void:
	assert(_ai != null)
	_play_card(await _ai.decide_card(_game_state, _cards.filter(_can_play_card)))

func _play_card(card: Card) -> void:
	remove_card(card)
	card.unhighlight()
	play.emit(card)

func _position_cards() -> void:
	_sort_hand()

	for card_index: int in _cards.size():
		var card: Card = _cards[card_index]
		var x: float = card_index - _cards.size()/2.0 + 0.5
		card.position.x = x * (Card.width + _seperation)
		var y = 2*x/_cards.size()
		card.position.y = _hand_arc(y) * 50
		card.rotation = atan(_hand_arc_derivative(y/4.0))

	_stack.position = Vector2.LEFT * 4.5 * (Card.width + _seperation)
	_hand_score_label.position = _stack.position + Vector2.UP * Card.height/2
	_dealer_icon.position = -_stack.position
	_bid.position = Vector2(0, -145)
	_bid_indicator.position = Vector2(-60, -Card.height)
	_total_score_indicator.position = Vector2(-105, -Card.height)
	_info_display.position = Vector2(70, -Card.height)

func _sort_hand() -> void:
	_cards.sort_custom(func(a: Card, b: Card) -> bool:
		if a.get_bower(null) != b.get_bower(null):
			return a.get_bower(null) > b.get_bower(null)
		
		if a.suit(null) != null and b.suit(null) != null:
			if  a.suit(null).colour as int != b.suit(null).colour as int:
				return a.suit(null).colour as int > b.suit(null).colour as int

			if a.suit(null).name != b.suit(null).name:
				return a.suit(null).name > b.suit(null).name

		return a.ordinal() > b.ordinal()
	)

func _update_focused_card() -> void:
	assert(_focus_index >= 0)
	_position_cards()
	for card: Card in _cards:
		card.set_can_play(Card.CanPlay.NONE)

	if _has_turn or _is_discarding:
		var focused_card: Card = _cards[_focus_index]
		focused_card.position += Vector2.UP.rotated(focused_card.rotation) * 5.0

		if _has_turn:
			if _can_play_card(focused_card):
				focused_card.set_can_play(Card.CanPlay.YES)
			else:
				focused_card.set_can_play(Card.CanPlay.NO)

func _set_bid_indicator() -> void:
	_bid_indicator.visible = true
	_bid_indicator.modulate = Globals.LIGHT_RED if not _current_bid.has_met(_current_deal_score) else Globals.LIGHT_GREEN
	_bid_label.text = str(_current_bid.character)

func _can_play_card(card: Card) -> bool:
	var card_suit: Suit = card.suit(_game_state.trump())

	# Can always play excuse card
	if card.is_excuse():
		return true
	# Leading can play any
	if _game_state.lead_suit() == null:
		return true
	# Need to follow suit
	if card_suit == _game_state.lead_suit():
		return true
	if not Utils.has_suit(_cards, _game_state.lead_suit(), _game_state.trump()):
		return true
	return false

func _ready() -> void:
	clear()
	_position_cards()

func _on_card_clicked(card: Card) -> void:
	if _ai != null:
		return
	if _has_turn and _can_play_card(card):
		_play_card(card)
	if _is_discarding:
		_discard_card.emit(card)

func _on_card_hovered(card: Card) -> void:
	if not _has_turn and not _is_discarding:
		return
	var new_focus_index: int = _cards.find(card)
	if _focus_index == new_focus_index:
		return
	_focus_index = new_focus_index
	_update_focused_card()
