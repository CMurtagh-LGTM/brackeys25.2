class_name RandomiseHandsAction
extends TriumphAction

func before_bid(state: TriumphGameState) -> void:
	var hand_size = state.game_state.trick_count()

	var cards: Array[Card] = []
	for hand: Hand in state.hands:
		var hand_cards: Array[Card] = hand.cards()
		for card: Card in hand_cards:
			hand.remove_card(card)
		cards.append_array(hand_cards)

	cards.shuffle()

	for _i in hand_size:
		for hand: Hand in state.hands:
			hand.add_card(cards.pop_back())

func has_before_bid(_state: TriumphGameState) -> bool:
	return true
