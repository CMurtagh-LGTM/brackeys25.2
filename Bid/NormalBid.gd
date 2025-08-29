class_name NormalBid
extends Bid

func has_met(current_deal_score: int) -> bool:
	return current_deal_score >= target

func _init(target_: int) -> void:
	score = target_
	target = target_
	character = str(target_)
