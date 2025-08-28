class_name GameOver
extends Node2D

@onready var _menu_buttons: Node2D = $MenuButtons

signal main_menu_pressed

func _ready() -> void:
	globals.viewport_resize.connect(_on_viewport_resize)
	_on_viewport_resize()

func _on_viewport_resize() -> void:
	_menu_buttons.position = globals.viewport_center()

func _on_main_menu_pressed() -> void:
	main_menu_pressed.emit()
