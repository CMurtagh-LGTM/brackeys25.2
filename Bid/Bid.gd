class_name Bid
extends RefCounted

## The display on the button
var character: String = ""

## If target is less than minimum bid is is disabled
var target: int = 0

## The amount of score awarded when won
func score(_game_state: GameState) -> int:
	assert(false)
	return 0

func has_met(_current_deal_score: int) -> bool:
	assert(false)
	return true
