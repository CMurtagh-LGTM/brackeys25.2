class_name Trick
extends Node2D

const _hand_offsets: Array[Vector2] = [
	2.0/3.0 * Card.width * Vector2(1, 1),
	2.0/3.0 * Card.width * Vector2(-1, 1),
	2.0/3.0 * Card.width * Vector2(-1, -1),
	2.0/3.0 * Card.width * Vector2(1, -1),
]

var _cards: Array[Card] = []
var _compasses: Array[Hand.Compass] = []

func lead_suit() -> Suit:
	if _cards.is_empty():
		return null
	return _cards[0].info.suit

func card_count() -> int:
	return _cards.size()

func add_card(card: Card, compass: Hand.Compass) -> void:
	card.position = _hand_offsets[compass]
	card.rotation = Globals.hand_rotations[compass]
	card.set_active(false)
	_cards.append(card)
	_compasses.append(compass)
	add_child(card)

func get_winner(trump: Suit) -> Hand.Compass:
	assert(!_cards.is_empty())
	var best_card_index = 0
	var best_card: Card = _cards[best_card_index]
	for card_index: int in range(1, _cards.size()):
		var card: Card = _cards[card_index]
		if card.info.suit == trump and (best_card.info.suit != trump or card.info.get_ordinal() > best_card.info.get_ordinal()):
			best_card_index = card_index
			best_card = card
		if card.info.suit == best_card.info.suit and card.info.get_ordinal() > best_card.info.get_ordinal():
			best_card_index = card_index
			best_card = card
	return _compasses[best_card_index]

func clear() -> void:
	for card: Card in _cards:
		remove_child(card)
	_cards.clear()
	_compasses.clear()
