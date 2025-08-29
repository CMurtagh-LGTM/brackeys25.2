class_name DrawAction
extends TriumphAction

@export var target: Hand.DiscardTarget = Hand.DiscardTarget.DISCARD
@export var cards: int = 1

func before_bid(state: TriumphGameState) -> void:
	var hand_size: int = state.player.get_hand_size()

	for _i: int in cards:
		await state.player.add_card(await state.deck.draw_card())

	var cards_to_discard: Array[Card] = await state.player.discard(hand_size, target)
	if target == Hand.DiscardTarget.DISCARD:
		await state.discard_pile.append(cards_to_discard)
	elif target == Hand.DiscardTarget.BONUS:
		await state.bonus_pile.append(cards_to_discard)

func has_before_bid(_state: TriumphGameState) -> bool:
	return true
