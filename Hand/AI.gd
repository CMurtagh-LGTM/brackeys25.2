class_name AI
extends RefCounted

var _delay := 0.5

func decide_card(cards: Array[Card], can_play_card: Callable) -> Card:
	await cards[0].get_tree().create_timer(_delay).timeout
	for card: Card in cards:
		if can_play_card.call(card):
			return card
	@warning_ignore("assert_always_false")
	assert(0)
	return cards[0]
