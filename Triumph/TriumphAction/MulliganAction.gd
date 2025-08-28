class_name MulliganAction
extends TriumphAction

func before_bid(state: TriumphGameState) -> void:
	var hand_size:int = state.player.get_hand_size()

	for _i: int in hand_size:
		await state.discard_pile.push_card(state.player.discard_last_card())

	for _i: int in hand_size:
		await state.player.add_card(await state.deck.draw_card())

func has_before_bid(_state: TriumphGameState) -> bool:
	return true
