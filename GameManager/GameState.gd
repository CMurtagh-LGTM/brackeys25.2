class_name GameState
extends RefCounted

var trump: Suit
var lead_suit: Suit

func _init(trump_: Suit, lead_suit_: Suit):
	trump = trump_
	lead_suit = lead_suit_

