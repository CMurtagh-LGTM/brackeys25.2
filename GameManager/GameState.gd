class_name GameState
extends RefCounted

var trump: Suit
var lead_suit: Suit
var deck_info: DeckInfo
var trick: Array[Card]

func _init(trump_: Suit, lead_suit_: Suit, deck_info_: DeckInfo, trick_: Array[Card]):
	trump = trump_
	lead_suit = lead_suit_
	deck_info = deck_info_
	trick = trick_

