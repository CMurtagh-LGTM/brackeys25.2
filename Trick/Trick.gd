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

func lead_suit(trump: Suit) -> Suit:
	if _cards.is_empty():
		return null
	if _cards[0].is_bower(trump) == Card.Bower.LEFT:
		return trump
	return _cards[0].info.suit

func card_count() -> int:
	return _cards.size()

func add_card(card: Card, compass: Hand.Compass) -> void:
	card.set_active(false)
	await card.move_to(self, _hand_offsets[compass], Globals.hand_rotations[compass])
	_cards.append(card)
	_compasses.append(compass)

func is_higher(card1: Card, card2: Card, trump: Suit) -> bool:
	# Check bower order first
	if card1.is_bower(trump) > card2.is_bower(trump):
		return true
	if card1.is_bower(trump) < card2.is_bower(trump):
		return false

	# Check trump
	if card1.info.suit == trump and card2.info.suit != trump:
		return true

	# Check lead suit
	if card1.info.suit != card2.info.suit:
		return false

	# Check number
	if card1.info.get_ordinal() > card2.info.get_ordinal():
		return true

	return false

func get_winner(trump: Suit) -> Hand.Compass:
	assert(!_cards.is_empty())
	var best_card_index = 0
	var best_card: Card = _cards[best_card_index]
	for card_index: int in range(1, _cards.size()):
		var card: Card = _cards[card_index]
		if is_higher(card, best_card, trump):
			best_card_index = card_index
			best_card = card
	return _compasses[best_card_index]

func clear() -> Array[Card]:
	var cards = _cards.duplicate()
	for card: Card in _cards:
		card.reset_state()
	_cards.clear()
	_compasses.clear()
	return cards
