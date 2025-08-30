class_name ParWinCondition
extends WinCondition

@export var par: int = 3

func to_label() -> String:
	return "Score at least: " + str(par)

func has_won(_place: int, score: int) -> bool:
	return score >= par
