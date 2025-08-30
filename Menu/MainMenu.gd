class_name MainMenu
extends Node2D

@onready var _menu_buttons: Node2D = $MenuButtons
@onready var _menu_tabs: TabContainer = %MenuTabs

signal start_pressed(use_tutorial: bool)

func _ready() -> void:
	globals.viewport_resize.connect(_on_viewport_resize)
	_on_viewport_resize()

func _on_viewport_resize() -> void:
	_menu_buttons.position = globals.viewport_center()

func _on_tutorial_pressed() -> void:
	_menu_tabs.current_tab = 0
	start_pressed.emit(true)

func _on_start_pressed() -> void:
	_menu_tabs.current_tab = 0
	start_pressed.emit(false)

func _on_how_to_play_pressed():
	_menu_tabs.current_tab = 1

func _on_credits_pressed():
	_menu_tabs.current_tab = 2

func _on_back_pressed():
	_menu_tabs.current_tab = 0

