class_name Stack
extends Node2D

var _cards: Array[Card]

func push_card(card: Card) -> void:
	_cards.push_back(card)
	if card.get_parent():
		card.get_parent().remove_child(card)
	add_child(card)
	_position_cards()

func append(cards: Array[Card]) -> void:
	_cards.append_array(cards)
	for card: Card in cards:
		card.get_parent().remove_child(card)
		add_child(card)
	_position_cards()

func shuffle() -> void:
	_cards.shuffle()
	for card_index: int in _cards.size():
		move_child(_cards[card_index], card_index)
	_position_cards()

func clear() -> void:
	for card: Card in _cards:
		remove_child(card)
	_cards.clear()

func draw_card() -> Card:
	var card: Card = _cards.pop_back()
	_position_cards()
	return card

func peek_top() -> Card:
	return _cards.back()

func _position_cards() -> void:
	for card_index: int in _cards.size():
		_cards[card_index].position = position - Vector2.ONE * card_index / 3
