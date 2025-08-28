class_name GameOver
extends Node2D

@onready var _pips: Array[Sprite2D] = [$Pips/Pip1, $Pips/Pip2, $Pips/Pip3, $Pips/Pip4]
@onready var _menu_buttons: Node2D = $MenuButtons

signal main_menu_pressed

func _ready() -> void:
	globals.viewport_resize.connect(_on_viewport_resize)
	_on_viewport_resize()

func _on_viewport_resize() -> void:
	_pips[0].position = Globals.pip_offset
	_pips[1].position = Vector2(globals.viewport_size.x - Globals.pip_offset.x, Globals.pip_offset.y)
	_pips[2].position = Vector2(Globals.pip_offset.x, globals.viewport_size.y - Globals.pip_offset.y)
	_pips[3].position = Vector2(globals.viewport_size.x - Globals.pip_offset.x, globals.viewport_size.y - Globals.pip_offset.y)
	_menu_buttons.position = globals.viewport_center()

func _on_main_menu_pressed() -> void:
	main_menu_pressed.emit()
