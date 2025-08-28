class_name DrawAction
extends TriumphAction

func before_bid(state: TriumphGameState) -> void:
	var hand_size:int = state.player.get_hand_size()
	await state.player.add_card(await state.deck.draw_card())
	await state.discard_pile.append(await state.player.player_discard(hand_size, "Discard"))

func has_before_bid(_state: TriumphGameState) -> bool:
	return true
