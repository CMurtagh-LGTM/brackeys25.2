class_name Deck
extends Node2D

var deck_info: DeckInfo
var _discard_pile: Stack

@onready var _cards: Stack = $Pile

func shuffle() -> void:
	await _cards.shuffle()

func add_card(card: Card) -> void:
	if card.transient():
		card.get_parent().remove_child(card)
		return
	await _cards.push_card(card)

func add_cards(cards: Array[Card], quiet: bool = false) -> void:
	cards = cards.filter(func(card: Card) -> bool: return not card.transient())
	await _cards.append(cards, quiet)

func reset() -> void:
	_cards.clear()
	assert(deck_info)
	for card_info: CardInfo in deck_info.cards:
		_cards.push_card(Card.instantiate(card_info))

func draw_card() -> Card:
	if _cards.is_empty():
		await add_cards(_discard_pile.clear())
	return _cards.draw_card()

func set_discard_pile(pile: Stack) -> void:
	_discard_pile = pile

func peek_top() -> Card:
	return _cards.peek_top()
