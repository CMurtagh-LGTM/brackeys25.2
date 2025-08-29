class_name PeekAction
extends TriumphAction

func before_bid(state: TriumphGameState) -> void:

	for hand: Hand in state.hands:
		if hand == state.player:
			continue
		hand.random_card().reveal()

func has_before_bid(_state: TriumphGameState) -> bool:
	return true
