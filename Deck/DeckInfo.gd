class_name DeckInfo
extends Resource

@export var name: String
@export var cards: Array[CardInfo]

func has_best() -> bool:
	for card: CardInfo in cards:
		if card.get_bower() == Card.Bower.BEST:
			return true
	return false

func has_jacks() -> bool:
	for card: CardInfo in cards:
		if card.get_ordinal() == Card.Ordinal.JACK:
			return true
	return false

# these could be mesoised
func lowest_ordinal() -> Card.Ordinal:
	var lowest: Card.Ordinal = Card.Ordinal.TOP
	for card: CardInfo in cards:
		if card.get_ordinal() < lowest:
			lowest = card.get_ordinal()
	return lowest

func highest_ordinal() -> Card.Ordinal:
	var lowest: Card.Ordinal = Card.Ordinal.BOTTOM
	for card: CardInfo in cards:
		if card.get_ordinal() > lowest:
			lowest = card.get_ordinal()
	return lowest

