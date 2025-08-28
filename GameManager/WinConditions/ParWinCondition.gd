class_name ParWinCondition
extends WinCondition

@export var par: int = 3

func to_label() -> String:
	return "Par: " + str(par)

func has_won(par_: int) -> bool:
	return par_ >= par
