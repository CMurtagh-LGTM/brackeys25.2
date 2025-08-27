class_name GameState
extends RefCounted

var trump: Suit
var lead_suit: Suit
var deck_info: DeckInfo
var trick: Array[Card]
var last_play: bool

func _init(trump_: Suit, lead_suit_: Suit, deck_info_: DeckInfo, trick_: Array[Card], last_play_: bool):
	trump = trump_
	lead_suit = lead_suit_
	deck_info = deck_info_
	trick = trick_
	last_play = last_play_

