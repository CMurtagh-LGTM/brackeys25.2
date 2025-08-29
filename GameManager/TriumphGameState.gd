class_name TriumphGameState
extends RefCounted

var player: Hand
var hands: Array[Hand]
var deck: Deck
var discard_pile: Stack
var bonus_pile: Stack
var origin: Node2D

var game_state: GameState

func _init(player_: Hand, hands_: Array[Hand], deck_: Deck, discard_pile_: Stack, bonus_pile_: Stack, origin_) -> void:
	player = player_
	hands = hands_
	deck = deck_
	discard_pile = discard_pile_
	bonus_pile = bonus_pile_
	origin = origin_
	
