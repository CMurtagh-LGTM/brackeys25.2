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
	return _cards[0].suit(trump)

func card_count() -> int:
	return _cards.size()

func add_card(card: Card, trump: Suit, compass: Hand.Compass) -> void:
	card.set_active(false)
	card.reveal()
	await card.move_to(self, _hand_offsets[compass], Globals.hand_rotations[compass])
	_cards.append(card)
	_compasses.append(compass)
	_highlight_winning(trump)

static func is_higher(card1: Card, card2: Card, trump: Suit) -> bool:
	# Check bower order first
	if card1.get_bower(trump) > card2.get_bower(trump):
		return true
	if card1.get_bower(trump) < card2.get_bower(trump):
		return false

	# Check trump
	if trump and card1.suit(trump) == trump and card2.suit(trump) != trump:
		return true

	# Check lead suit
	if card1.suit(trump) != card2.suit(trump):
		return false

	# Check number
	if card1.ordinal() > card2.ordinal():
		return true

	return false

func get_winner(trump: Suit) -> Hand.Compass:
	assert(!_cards.is_empty())
	return _compasses[_current_winning_card_index(_cards, trump)]

func clear() -> Array[Card]:
	var cards = _cards.duplicate()
	for card: Card in _cards:
		card.reset_state()
	_cards.clear()
	_compasses.clear()
	return cards

func get_cards() -> Array[Card]:
	return _cards.duplicate()

static func current_winning_card(cards: Array[Card], trump: Suit) -> Card:
	if cards.is_empty():
		return null
	return cards[_current_winning_card_index(cards, trump)]

static func _current_winning_card_index(cards: Array[Card], trump: Suit) -> int:
	var best_card_index = 0
	var best_card: Card = cards[best_card_index]
	for card_index: int in range(1, cards.size()):
		var card: Card = cards[card_index]
		if is_higher(card, best_card, trump):
			best_card_index = card_index
			best_card = card
	return best_card_index

func _highlight_winning(trump: Suit) -> void:
	for card: Card in _cards:
		card.unhighlight()
	current_winning_card(_cards, trump).highlight(Globals.LIGHT_GREEN)

