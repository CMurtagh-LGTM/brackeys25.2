class_name RejectTrump
extends TriumphAction

func before_bid(state: TriumphGameState) -> void:
	state.game_state.set_trump(null)

func has_before_bid(state: TriumphGameState) -> bool:
	return state.game_state.trump() != null
