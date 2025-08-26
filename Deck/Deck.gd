class_name Deck
extends Node2D

var deck_info: DeckInfo
var _cards: Array[Card]

func shuffle() -> void:
	_cards.shuffle()

func reset() -> void:
	_cards.clear()	
	for card_info: CardInfo in deck_info.cards:
		_cards.push_back(Card.instantiate(card_info))
	shuffle()

func draw_card() -> Card:
	return _cards.pop_back()

func _ready() -> void:
	reset()
