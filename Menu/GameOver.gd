class_name GameOver
extends Node2D

@onready var _menu_buttons: Node2D = $MenuButtons

@onready var _score_label: Label = %Score
@onready var _place_label: Label = %Place
@onready var _win_condition_label: Label = %WinCondition

signal main_menu_pressed

func set_score(score: int) -> void:
	_score_label.text = str(score)

func set_place(place: int) -> void:
	_place_label.text = str(place + 1) + Utils.nth(place + 1)

func set_win_condition(condition: String) -> void:
	_win_condition_label.text = condition

func _ready() -> void:
	globals.viewport_resize.connect(_on_viewport_resize)
	_on_viewport_resize()

func _on_viewport_resize() -> void:
	_menu_buttons.position = globals.viewport_center()

func _on_main_menu_pressed() -> void:
	main_menu_pressed.emit()
