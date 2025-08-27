class_name AI
extends RefCounted

const _delay := 0.5

var _terribleness := 0.75

func decide_card(game_state: GameState, cards: Array[Card], can_play_card: Callable) -> Card:
	await cards[0].get_tree().create_timer(_delay).timeout
	for card: Card in cards:
		if can_play_card.call(card):
			return card
	@warning_ignore("assert_always_false")
	assert(0)
	return cards[0]

func decide_bid(disallowed_bid: int, highest_bid: int, revealed_card: Card, game_state: GameState, cards: Array[Card]) -> int:
	await cards[0].get_tree().create_timer(_delay).timeout
	
	# Calculate these outside the loop to keep O(n)
	var low: Card.Ordinal = game_state.deck_info.lowest_ordinal()
	var high: Card.Ordinal = game_state.deck_info.highest_ordinal()

	var score: float = 0.0
	for card: Card in cards:
		score += _score_card(card, low, high, game_state.trump)

	if int(score) == highest_bid and _score_card(revealed_card, low, high, game_state.trump) > 0.5:
		score += 1

	if Globals.debug_ai:
		print(score)
	else:
		score += randf_range(-_terribleness, _terribleness)

	if disallowed_bid < int(score):
		return int(score)
	else:
		return disallowed_bid + 1


func worst_card(cards: Array[Card], game_state: GameState) -> int:
	await cards[0].get_tree().create_timer(_delay).timeout
	
	# Calculate these outside the loop to keep O(n)
	var low: Card.Ordinal = game_state.deck_info.lowest_ordinal()
	var high: Card.Ordinal = game_state.deck_info.highest_ordinal()

	var worst_index: int = 0
	var worst_score: float = INF
	for index: int in cards.size():
		var score: float = _score_card(cards[index], low, high, game_state.trump)
		if score < worst_score:
			worst_index = index

	return worst_index

const trump_bonus: float = 1.0/3.0

func _score_card(card: Card, low: float, high: float, trump: Suit) -> float:
	assert(low < high)
	var ordinal_count: float = high - low
	var card_ordinal: float = card.info.get_ordinal() as int as float
	var score: float = (card_ordinal - low) / ordinal_count

	if trump:
		score *= 1 - trump_bonus # make room for trump bonus
		if card.info.suit == trump:
			score += trump_bonus

	return score
