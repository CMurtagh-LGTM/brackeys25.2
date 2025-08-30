class_name SaveFile
extends Resource

@export var tutorial_index: int
@export var tutorial_complete: bool
@export var current_level: int

@export var triumph_infos: Array[TriumphInfo]

func _init(tutorial_index_: int = 0, tutorial_complete_: bool = false, current_level_: int = 0, triumph_infos_: Array[TriumphInfo] = []) -> void:
	tutorial_index = tutorial_index_
	tutorial_complete = tutorial_complete_
	current_level = current_level_
	triumph_infos = triumph_infos_
	

