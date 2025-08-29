class_name RejectTurnupAction
extends TriumphAction

func before_bid(state: TriumphGameState) -> void:
	var old_turnup: Card = state.game_state.turnup()
	await state.discard_pile.push_card(old_turnup)

	var new_turnup: Card = await state.deck.draw_card()
	state.game_state.set_turnup(new_turnup)

func has_before_bid(_state: TriumphGameState) -> bool:
	return true
