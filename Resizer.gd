class_name Resizer
extends Node2D

func _ready() -> void:
	globals.viewport_resize.connect(_on_viewport_resize)
	_on_viewport_resize()

func _on_viewport_resize() -> void:
	get_parent().size = globals.viewport_size
