class_name DrawAction
extends TriumphAction

enum Target {
	DISCARD, BONUS
}

@export var target: Target = Target.DISCARD

func before_bid(state: TriumphGameState) -> void:
	var hand_size:int = state.player.get_hand_size()
	await state.player.add_card(await state.deck.draw_card())
	if target == Target.DISCARD:
		await state.discard_pile.append(await state.player.player_discard(hand_size, "Discard"))
	elif target == Target.BONUS:
		await state.bonus_pile.append(await state.player.player_discard(hand_size, "Bonus"))

func has_before_bid(_state: TriumphGameState) -> bool:
	return true
