class_name DeckBonus
extends TriumphAction

@export var cards: int = 1

func before_bid(state: TriumphGameState) -> void:
	for _i: int in cards:
		var card: Card = await state.deck.draw_card()
		card.reveal()
		await state.bonus_pile.push_card(card, Globals.card_move_time)

func has_before_bid(_state: TriumphGameState) -> bool:
	return true
