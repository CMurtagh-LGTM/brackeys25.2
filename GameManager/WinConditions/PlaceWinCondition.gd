class_name PlaceWinCondition
extends WinCondition

@export_range(1, 4) var minimum_place: int = 2

func to_label() -> String:
	return "Place at least: " + str(minimum_place) + Utils.nth(minimum_place)

func has_won(place_: int, _score: int) -> bool:
	# place is 0 indexed whilst minimum_place is 1 indexed
	return place_ < minimum_place

