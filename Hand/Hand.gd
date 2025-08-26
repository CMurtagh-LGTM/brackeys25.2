class_name Hand
extends Node2D

const _seperation: float = 5

enum Compass {
	SOUTH, WEST, NORTH, EAST
}

var _cards: Array[Card] = []
var _has_turn: bool = false
var _ai: AI = AI.new()
var _focus_index: int = 0

var _game_state: GameState

signal play(Card)

func add_card(card: Card, index: int = -1) -> void:
	if index == -1:
		_cards.push_back(card)
	else:
		_cards.insert(index, card)
	add_child(card)
	if _ai == null:
		card.clicked.connect(_on_card_clicked.bind(card))
		card.hovered.connect(_on_card_hovered.bind(card))
	_position_cards()

func remove_card(card: Card) -> void:
	if _ai == null:
		card.clicked.disconnect(_on_card_clicked)
		card.hovered.disconnect(_on_card_hovered)
	_cards.erase(card)
	remove_child(card)
	_position_cards()

func get_is_player() -> bool:
	return _ai == null

func set_is_player() -> void:
	if _ai == null:
		return
	_ai = null
	for card: Card in _cards:
		card.reveal()
		card.clicked.connect(_on_card_clicked.bind(card))
		card.hovered.connect(_on_card_hovered.bind(card))

func gain_turn(game_state: GameState) -> void:
	_has_turn = true
	_game_state = game_state
	for card: Card in _cards:
		card.set_active(true)
	if _ai != null:
		_play_turn()

func lose_turn() -> void:
	_has_turn = false
	for card: Card in _cards:
		card.set_active(false)
	_position_cards()

func _hand_arc(x: float) -> float:
	return (1.0/4.0)*x**2.0-1.0/16

func _hand_arc_derivative(x: float) -> float:
	return 0.5 * x

func _play_turn() -> void:
	assert(_ai != null)
	_play_card(await _ai.decide_card(_cards, _can_play_card))

func _play_card(card: Card) -> void:
	remove_card(card)
	play.emit(card)

func _position_cards() -> void:
	for card_index: int in _cards.size():
		var card: Card = _cards[card_index]
		var x: float = card_index - _cards.size()/2.0 + 0.5
		card.position.x = x * (Card.width + _seperation)
		var y = 2*x/_cards.size()
		card.position.y = _hand_arc(y) * 50
		card.rotation = atan(_hand_arc_derivative(y/4.0))

func _update_focused_card() -> void:
	_position_cards()
	for card: Card in _cards:
		card.set_can_play(Card.CanPlay.NONE)

	if _has_turn:
		var focused_card: Card = _cards[_focus_index]
		focused_card.position += Vector2.UP.rotated(focused_card.rotation) * 5.0

		if _can_play_card(focused_card):
			focused_card.set_can_play(Card.CanPlay.YES)
		else:
			focused_card.set_can_play(Card.CanPlay.NO)

func _ready() -> void:
	for card: Card in _cards:
		card.reveal(globals.open_hands or _ai == null)

func _has_suit(suit: Suit) -> bool:
	for card: Card in _cards:
		if card.info.suit == suit:
			return true
	return false

func _can_play_card(card: Card) -> bool:
	if _game_state.lead_suit == null:
		return true
	if card.info.suit == _game_state.trump or card.info.suit == _game_state.lead_suit:
		return true
	if not _has_suit(_game_state.lead_suit):
		return true
	return false

func _on_card_clicked(card: Card) -> void:
	if _ai != null or not _has_turn:
		return
	if _can_play_card(card):
		_play_card(card)

func _on_card_hovered(card: Card) -> void:
	if not _has_turn:
		return
	_focus_index = _cards.find(card)
	_update_focused_card()
