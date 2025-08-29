class_name PeekAction
extends TriumphAction

@export var count: int = 1

func before_bid(state: TriumphGameState) -> void:

	for hand: Hand in state.hands:
		if hand == state.player:
			continue
		for _i: int in count:
			hand.random_card().reveal()

func has_before_bid(_state: TriumphGameState) -> bool:
	return true
