class_name AI
extends RefCounted

const _delay := 0.5

const _mistake_chance: float = 0.0 if Globals.debug_ai else 0.1
const _bid_deviation: float = 0.5 if Globals.debug_ai else 1.0

const trump_bonus: float = 0.4

# TODO calculate the threshold based on the deck
const singleton_threshold: Card.Ordinal = Card.Ordinal.QUEEN
const offsuit_threshold: Card.Ordinal = Card.Ordinal.ACE

const stash_threshold: float = 1.5
const high_bid: int = 3
# How much to reduce score (highest_bid - high_bid + 1) * high_bid_penalty 
const high_bid_penalty = 0.25
const turnup_score_threshold: float = 0.5
const turnup_reveal_threshold: float = 0.75

var _stashing: bool = false

func _best_card_ordinal(cards: Array[Card], trump: Suit, exclude_suit: Suit, threshold: Card.Ordinal, include_bowers: bool = false) -> Card:
	var best_card: Card = null
	for card: Card in cards:
		if card.suit(trump) == exclude_suit:
			continue
		if card.ordinal() < threshold:
			continue
		if not include_bowers and card.get_bower(trump) != Card.Bower.NONE:
			continue
		if best_card != null and card.get_bower(trump) < best_card.get_bower(trump):
			continue
		if (best_card == null
			or card.ordinal() > best_card.ordinal()
		):
			best_card = card
	return best_card

func _best_bower(cards: Array[Card], trump: Suit) -> Card:
	var best_bower: Card = null
	for card: Card in cards:
		if (card.get_bower(trump) != Card.Bower.NONE
			and (best_bower == null or card.get_bower(trump) > best_bower.get_bower(trump))
		):
			best_bower = card
	return best_bower

func _worst_card_ordinal(cards: Array[Card], trump: Suit) -> Card:
	if cards.is_empty():
		return null
	var worst_card: Card = cards[0]
	for card: Card in cards:
		if card.get_bower(trump) < worst_card.get_bower(trump):
			worst_card = card
			continue
		if card.suit(trump) != trump and worst_card.suit(trump) == trump:
			worst_card = card
			continue
		if card.ordinal() < worst_card.ordinal():
			worst_card = card
			continue

	return worst_card

func _lead(game_state: GameState, cards: Array[Card]) -> Card:
	# Find off suit singletons
	var suit_count: Dictionary[Suit, int] = {}
	for card: Card in cards:
		suit_count.get_or_add(card.suit(game_state.trump), 0)
		suit_count[card.suit(game_state.trump)] += 1

	var decent_singletons: Array[Card] = []
	for card: Card in cards:
		if suit_count[card.suit(game_state.trump)] > 1:
			continue
		if card.suit(game_state.trump) == game_state.trump:
			continue
		if card.ordinal() < singleton_threshold:
			continue
		if card.get_bower(game_state.trump) != Card.Bower.NONE:
			continue
		decent_singletons.append(card)

	if not decent_singletons.is_empty():
		var best_singleton = decent_singletons[0]
		for singleton: Card in decent_singletons:
			if singleton.ordinal() > best_singleton.ordinal():
				best_singleton = singleton
		ai_print("lead singleton")
		return best_singleton

	# Find high off suit
	var best_decent_offsuit: Card = _best_card_ordinal(cards, game_state.trump, game_state.trump, offsuit_threshold)
	if best_decent_offsuit:
		ai_print("lead decent offsuit")
		return best_decent_offsuit

	# Go fishing for trumps
	var best_bower: Card = _best_bower(cards, game_state.trump)
	if best_bower:
		ai_print("lead bower")
		return best_bower

	# Just pick the best off suit
	var best_offsuit: Card = _best_card_ordinal(cards, game_state.trump, game_state.trump, Card.Ordinal.BOTTOM)
	if best_offsuit:
		ai_print("lead offsuit")
		return best_offsuit

	# Somehow we have all trumps and no bowers
	var best_card: Card = _best_card_ordinal(cards, game_state.trump, null, Card.Ordinal.BOTTOM)
	if best_card == null:
		@warning_ignore("assert_always_false")
		assert(0)
	ai_print("lead best trump")
	return best_card

func _potential_winners(current_winning_card: Card, cards: Array[Card], trump: Suit, lead_suit: Suit) -> Array[Card]:
	var potential_winners: Array[Card] = []
	for card: Card in cards:
		# Can't win without lead suit or trump
		if card.suit(trump) != lead_suit and card.suit(trump) != trump:
			continue
		# If winning card is a trump we need a trump to beat it
		if card.suit(trump) != trump and current_winning_card.suit(trump) == trump:
			continue
		# If winning card is a bower we need at least match it
		if card.get_bower(trump) < current_winning_card.get_bower(trump):
			continue
		# We can trump the card
		if card.suit(trump) == trump and current_winning_card.suit(trump) != trump:
			potential_winners.append(card)
			continue
		# We need to have a higher number
		if card.ordinal() <= current_winning_card.ordinal():
			continue
		potential_winners.append(card)
	return potential_winners

func _middle(game_state: GameState, cards: Array[Card]) -> Card:
	# Best card if can win else worst card
	var current_winning_card: Card = Trick.current_winning_card(game_state.trick, game_state.trump)

	var potential_winners: Array[Card] = _potential_winners(current_winning_card, cards, game_state.trump, game_state.lead_suit)
	var best_winning_card: Card = _best_card_ordinal(potential_winners, game_state.trump, null, Card.Ordinal.BOTTOM)

	if best_winning_card != null:
		ai_print("played best winning card")
		return best_winning_card

	ai_print("throw off")
	return _worst_card_ordinal(cards, game_state.trump)

func _last(game_state: GameState, cards: Array[Card]) -> Card:
	# Worst winning card if can win else worst card
	var current_winning_card: Card = Trick.current_winning_card(game_state.trick, game_state.trump)

	var potential_winners: Array[Card] = _potential_winners(current_winning_card, cards, game_state.trump, game_state.lead_suit)
	var worst_winning_Card: Card = _worst_card_ordinal(potential_winners, game_state.trump)

	if worst_winning_Card != null:
		ai_print("played worst winning card")
		return worst_winning_Card

	ai_print("throw off")
	return _worst_card_ordinal(cards, game_state.trump)

func decide_card(game_state: GameState, cards: Array[Card]) -> Card:
	assert(not cards.is_empty())
	await cards[0].get_tree().create_timer(_delay).timeout

	if randf_range(0, 1) < _mistake_chance:
		return cards[0]

	if game_state.lead_suit == null:
		return _lead(game_state, cards)

	if not game_state.last_play:
		return _middle(game_state, cards)

	return _last(game_state, cards)

func decide_bid(min_allowed_bid: int, max_allowed_bid, highest_bid: int, revealed_card: Card, game_state: GameState, cards: Array[Card]) -> int:
	await cards[0].get_tree().create_timer(_delay).timeout
	
	# Calculate these outside the loop to keep O(n)
	var low: Card.Ordinal = game_state.deck_info.lowest_ordinal()
	var high: Card.Ordinal = game_state.deck_info.highest_ordinal()

	var score: float = 0.0
	for card: Card in cards:
		score += _trick_score_win_change(card, low, high, game_state.trump)

	score += randfn(0, _bid_deviation)

	if highest_bid >= high_bid:
		ai_print("lowering bid due to high bid")
		score -= (highest_bid - high_bid + 1) * high_bid_penalty

	if ((score == highest_bid + turnup_score_threshold or score == min_allowed_bid + turnup_score_threshold)
		and _trick_score_win_change(revealed_card, low, high, game_state.trump) > turnup_reveal_threshold):
		ai_print("trying for turnup")
		score += 1

	if (score > highest_bid + stash_threshold) and (score > min_allowed_bid + stash_threshold):
		ai_print("trying for stash")
		score -= 1
		_stashing = true

	if Globals.debug_ai:
		print("bid score: ", score)

	@warning_ignore("narrowing_conversion")
	return clampf(score, min_allowed_bid, max_allowed_bid)

func _lowest_score_card_index(cards: Array[Card], low: float, high: float, trump: Suit, only_trumps: bool) -> int:
	var worst_index: int = 0
	var worst_score: float = INF
	for index: int in cards.size():
		if only_trumps and cards[index].suit(trump) != trump:
			continue

		var score: float = _trick_score_win_change(cards[index], low, high, trump)
		if score < worst_score:
			worst_score = score
			worst_index = index
	return worst_index

func decide_bonus_discard(cards: Array[Card], game_state: GameState) -> int:
	await cards[0].get_tree().create_timer(_delay).timeout
	
	# Calculate these outside the loop to keep O(n)
	var low: Card.Ordinal = game_state.deck_info.lowest_ordinal()
	var high: Card.Ordinal = game_state.deck_info.highest_ordinal()

	if _stashing:
		_stashing = false
		return _lowest_score_card_index(cards, low, high, game_state.trump, true)

	return _lowest_score_card_index(cards, low, high, game_state.trump, false)

## Change this card may win a trick,
## bowers give more because they could quite possibly gain the lead
func _trick_score_win_change(card: Card, low: float, high: float, trump: Suit) -> float:
	assert(low < high)
	var bower: Card.Bower = card.get_bower(trump)
	if (bower == Card.Bower.BEST):
		return 1.1
	if (bower == Card.Bower.RIGHT):
		return 1.05
	if (bower == Card.Bower.LEFT):
		return 1.0

	var ordinal_count: float = high - low + 1
	var card_ordinal: float = card.ordinal() as int as float
	# we don't add subtract one from ordinal count so bower ace is less than right bower
	var score: float = (card_ordinal - low) / ordinal_count

	if trump:
		score *= 1 - trump_bonus # make room for trump bonus
		if card.suit(trump) == trump:
			score += trump_bonus

	return score

func reset() -> void:
	_stashing = false

static func ai_print(value: String) -> void:
	if Globals.debug_ai:
		print(value)
