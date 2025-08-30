class_name MainMenu
extends Node2D

@onready var _menu_buttons: Node2D = $MenuButtons
@onready var _menu_tabs: TabContainer = %MenuTabs

@onready var _start_button: Button = %Start
@onready var _continue_button: Button = %Continue

enum PlayState {
	TUTORIAL, START, CONTINUE
}

signal start_pressed(play_state: PlayState)

func enable_buttons(start: bool, continu: bool) -> void:
	_start_button.disabled = not start
	_continue_button.disabled = not continu
	
func _ready() -> void:
	globals.viewport_resize.connect(_on_viewport_resize)
	_on_viewport_resize()

func _on_viewport_resize() -> void:
	_menu_buttons.position = globals.viewport_center()

func _on_tutorial_pressed() -> void:
	start_pressed.emit(PlayState.TUTORIAL)

func _on_start_pressed() -> void:
	start_pressed.emit(PlayState.START)

func _on_continue_pressed() -> void:
	start_pressed.emit(PlayState.CONTINUE)

func _on_how_to_play_pressed():
	_menu_tabs.current_tab = 1

func _on_credits_pressed():
	_menu_tabs.current_tab = 2

func _on_back_pressed():
	_menu_tabs.current_tab = 0
