class_name ExchangeHandsAction
extends TriumphAction

func before_bid(state: TriumphGameState) -> void:
	var hands_cards: Array = []
	for hand_index: int in state.hands.size():
		var hand: Hand = state.hands[hand_index]
		hands_cards.append(hand.cards())

	for hand_index: int in state.hands.size():
		var hand: Hand = state.hands[hand_index]
		var target_hand: Hand  = state.hands[(hand_index + 1) % state.hands.size()]
		for card: Card in hands_cards[hand_index]:
			hand.remove_card(card)
			await target_hand.add_card(card, -1, Globals.card_deal_time)


func has_before_bid(_state: TriumphGameState) -> bool:
	return true
