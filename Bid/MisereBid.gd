class_name MisereBid
extends Bid

func has_met(current_deal_score: int) -> bool:
	return current_deal_score == 0

func _init() -> void:
	target = 7
	character = "M"

func score(game_state: GameState) -> int:
	return ceil(game_state.trick_count() / 2.0)
