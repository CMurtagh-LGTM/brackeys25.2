class_name Utils
extends RefCounted

static func sum(accum, number):
	return accum + number

static func has_suit(cards: Array[Card], suit: Suit, trump: Suit) -> bool:
	for card: Card in cards:
		if card.suit(trump) == suit:
			return true
	return false
