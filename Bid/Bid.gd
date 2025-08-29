class_name Bid
extends RefCounted

## The display on the button
@export var character: String = ""

## The amount of score awarded when won
@export var score: int = 0
## If target is less than minimum bid is is disabled
@export var target: int = 0

func has_met(_current_deal_score: int) -> bool:
	assert(false)
	return true
