class_name Stack
extends Node2D

var _cards: Array[Card]

func push_card(card: Card) -> void:
	_cards.push_back(card)
	if card.get_parent():
		await card.move_to(self, Vector2.ZERO, 0, Globals.card_stack_time)
	else:
		add_child(card)
	_position_cards()

func append(cards: Array[Card]) -> void:
	_cards.append_array(cards)
	for card: Card in cards:
		await card.move_to(self, Vector2.ZERO, 0, Globals.card_stack_time)
	_position_cards()

func shuffle() -> void:
	_cards.shuffle()
	for card_index: int in _cards.size():
		move_child(_cards[card_index], card_index)
	_position_cards()

func clear() -> Array[Card]:
	var cards = _cards.duplicate()
	_cards.clear()
	return cards

func draw_card() -> Card:
	var card: Card = _cards.pop_back()
	_position_cards()
	return card

func peek_top() -> Card:
	return _cards.back()

func get_cards() -> Array[Card]:
	return _cards.duplicate()

func _position_cards() -> void:
	for card_index: int in _cards.size():
		_cards[card_index].position = - Vector2.ONE * card_index / 3

