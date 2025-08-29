class_name NormalBid
extends Bid

var _score: int

func has_met(current_deal_score: int) -> bool:
	return current_deal_score >= target

func score(_game_state: GameState) -> int:
	return _score

func _init(target_: int) -> void:
	_score = target_
	target = target_
	character = str(target_)
