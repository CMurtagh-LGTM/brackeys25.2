class_name TriumphChooser
extends Node2D

@onready var _menu_buttons: Node2D = $MenuButtons
@onready var _triumph_list: Container = %TriumphList
@onready var _skip_button: Button = %Skip
@onready var _hide_button: Button = %Hide

var _hidden: bool = false

signal chosen(triumph: Triumph)

func choose(triumphs: Array[Triumph], scale_: float = 1.0, hide_able: bool = false) -> Triumph:
	_menu_buttons.scale = scale_ * Vector2.ONE
	for triumph: Triumph in triumphs:
		var triumph_choice = TriumphChoice.instantiate(triumph)
		triumph_choice.chosen.connect(_on_choose)
		_triumph_list.add_child(triumph_choice)

	_skip_button.pressed.connect(_on_choose.bind(null))
	if hide_able:
		_hide_button.pressed.connect(_oh_hide_pressed)
		_hide_button.visible = true
	
	var chosen_triumph = await chosen
	for triumph: Triumph in triumphs:
		triumph.get_parent().remove_child(triumph)
	for child: Node in _triumph_list.get_children():
		_triumph_list.remove_child(child)

	_skip_button.pressed.disconnect(_on_choose)
	if hide_able:
		_hide_button.pressed.disconnect(_oh_hide_pressed)
		_hide_button.visible = false

	return chosen_triumph

func _on_choose(triumph: Triumph) -> void:
	chosen.emit(triumph)

func _oh_hide_pressed() -> void:
	_hidden = not _hidden
	_triumph_list.modulate.a = float(not _hidden)

func _ready() -> void:
	_hide_button.visible = false
	globals.viewport_resize.connect(_on_viewport_resize)
	_on_viewport_resize()

func _on_viewport_resize() -> void:
	_menu_buttons.position = globals.viewport_center()
