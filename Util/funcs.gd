class_name Utils
extends RefCounted

static func sum(accum, number):
	return accum + number

static func has_suit(cards: Array[Card], suit: Suit, trump: Suit) -> bool:
	for card: Card in cards:
		if card.suit(trump) == suit:
			return true
	return false

static func nth(place: int) -> String:
	assert(place > 0)
	if place % 10 == 1:
		return "st"
	if place % 10 == 2:
		return "nd"
	if place % 10 == 3:
		return "rd"
	return "th"

