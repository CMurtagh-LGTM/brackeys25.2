class_name Deck
extends Node2D

var deck_info: DeckInfo

@onready var _cards: Stack = $Pile

func shuffle() -> void:
	_cards.shuffle()

func add_cards(cards: Array[Card]) -> void:
	for card: Card in cards:
		card.conceal()
	await _cards.append(cards)

func reset() -> void:
	_cards.clear()
	assert(deck_info)
	for card_info: CardInfo in deck_info.cards:
		_cards.push_card(Card.instantiate(card_info))
	shuffle()

func draw_card() -> Card:
	return _cards.draw_card()

func peek_top() -> Card:
	return _cards.peek_top()
