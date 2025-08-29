class_name MeldAction
extends TriumphAction

@export var cards: Array[NormalCardInfo.Character] = []
@export var score: int = 2

func before_bid(state: TriumphGameState) -> void:
	state.player.add_score(score)

func _has_card(hand_cards: Array[Card], character: NormalCardInfo.Character) -> bool:
	for card: Card in hand_cards:
		if not card.info() is NormalCardInfo:
			continue
		if not (card.info() as NormalCardInfo).character == character:
			continue
		return true
	return false

func has_before_bid(state: TriumphGameState) -> bool:
	for character: NormalCardInfo.Character in cards:
		if not _has_card(state.player.cards(), character):
			return false
	return true

