class_name AutoDiscardAction
extends TriumphAction

@export var target: Hand.DiscardTarget = Hand.DiscardTarget.DISCARD
@export var suit: Suit = null
@export var character: NormalCardInfo.Character

func _get_matched_cards(state: TriumphGameState) -> Array[Card]:
	var matched_cards: Array[Card] = []
	for card: Card in state.player.cards():
		if not card.info() is NormalCardInfo:
			continue
		if suit != null and not card.suit(null) == suit:
			continue
		if character != null and not (card.info() as NormalCardInfo).character == character:
			continue
		matched_cards.append(card)
	return matched_cards

func before_bid(state: TriumphGameState) -> void:
	var cards_to_discard: Array[Card] = _get_matched_cards(state)
	for card: Card in cards_to_discard:
		state.player.remove_card(card)

	if target == Hand.DiscardTarget.DISCARD:
		await state.discard_pile.append(cards_to_discard)
	elif target == Hand.DiscardTarget.BONUS:
		await state.bonus_pile.append(cards_to_discard)

	for _i: int in cards_to_discard.size():
		await state.player.add_card(await state.deck.draw_card(), -1, Globals.card_deal_time, true)

func has_before_bid(state: TriumphGameState) -> bool:
	return not _get_matched_cards(state).is_empty()
