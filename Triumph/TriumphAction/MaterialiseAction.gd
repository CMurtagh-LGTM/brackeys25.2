class_name MaterialiseAction
extends TriumphAction

@export var card_info: CardInfo

func before_bid(state: TriumphGameState) -> void:
	var card: Card = Card.instantiate(card_info, true)
	var hand_size:int = state.player.get_hand_size()
	state.origin.add_child(card)
	await state.player.add_card(card)
	await state.discard_pile.append(await state.player.player_discard(hand_size, "Discard"))

func has_before_bid(_state: TriumphGameState) -> bool:
	return true
