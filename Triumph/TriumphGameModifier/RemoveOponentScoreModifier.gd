class_name RemoveOponentScoreModifier
extends TriumphGameModifier

@export var score: int = 1

func change_game(state: TriumphGameState) -> void:
	for hand: Hand in state.hands:
		if hand == state.player:
			continue
		hand.add_score(-score)

