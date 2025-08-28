class_name PlaceWinCondition
extends WinCondition

@export_range(1, 4) var minimum_place: int = 2

func _nth() -> String:
	assert(minimum_place > 0)
	if minimum_place % 10 == 1:
		return "st"
	if minimum_place % 10 == 2:
		return "nd"
	if minimum_place % 10 == 3:
		return "rd"
	return "th"

func to_label() -> String:
	return "Place at least: " + str(minimum_place) + _nth()

func has_won(place_: int, _score: int) -> bool:
	# place is 0 indexed whilst minimum_place is 1 indexed
	return place_ < minimum_place

