class_name Stack
extends Node2D

var _cards: Array[Card]

@export var _revealed: bool = false
@onready var _audio: AudioStreamPlayer = $AudioStreamPlayer
@onready var _audio2: AudioStreamPlayer = $AudioStreamPlayer2

signal cards_updated

func push_card(card: Card, time: float= Globals.card_stack_time) -> void:
	_cards.push_back(card)
	if card.get_parent():
		await card.move_to(self, Vector2.ZERO, 0, time)
	else:
		add_child(card)
	card.reveal(_revealed)
	cards_updated.emit()
	_position_cards()

func append(cards: Array[Card], quiet: bool = false) -> void:
	_cards.append_array(cards)
	if not globals.muted and not quiet:
		if cards.size() > 1:
			_audio.play()
		else:
			_audio2.play()
	for card: Card in cards:
		await card.move_to(self, Vector2.ZERO, 0, Globals.card_stack_time)
		card.reveal(_revealed)
	cards_updated.emit()
	_position_cards()

func shuffle() -> void:
	_cards.shuffle()
	if not globals.muted:
		_audio.play()
		await _audio.finished
	for card_index: int in _cards.size():
		move_child(_cards[card_index], card_index)
	_position_cards()

func clear() -> Array[Card]:
	var cards = _cards.duplicate()
	_cards.clear()
	cards_updated.emit()
	return cards

func draw_card() -> Card:
	assert(not _cards.is_empty())
	var card: Card = _cards.pop_back()
	_position_cards()
	cards_updated.emit()
	return card

func peek_top() -> Card:
	if _cards.is_empty():
		return null
	return _cards.back()

func get_cards() -> Array[Card]:
	return _cards.duplicate()

func is_empty() -> bool:
	return _cards.is_empty()

func _position_cards() -> void:
	for card_index: int in _cards.size():
		_cards[card_index].position = - Vector2.ONE * card_index / 3
