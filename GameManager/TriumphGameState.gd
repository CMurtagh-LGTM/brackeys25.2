class_name TriumphGameState
extends RefCounted

var player: Hand
var deck: Deck
var discard_pile: Stack

func _init(player_: Hand, deck_: Deck, discard_pile_: Stack) -> void:
	player = player_
	deck = deck_
	discard_pile = discard_pile_
	
