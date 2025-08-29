class_name DiscardAction
extends TriumphAction

enum Target {
	DISCARD, BONUS
}

@export var target: Target = Target.DISCARD
@export var cards: int = 1

func before_bid(state: TriumphGameState) -> void:
	var hand_size: int = state.player.get_hand_size() - cards

	if target == Target.DISCARD:
		await state.discard_pile.append(await state.player.discard(hand_size, Hand.DiscardTarget.DISCARD))
	elif target == Target.BONUS:
		await state.bonus_pile.append(await state.player.discard(hand_size, Hand.DiscardTarget.BONUS))

	for _i: int in cards:
		await state.player.add_card(await state.deck.draw_card())

func has_before_bid(_state: TriumphGameState) -> bool:
	return true
