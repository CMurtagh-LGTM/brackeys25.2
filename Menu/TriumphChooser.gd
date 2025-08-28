class_name TriumphChooser
extends Node2D

@onready var _menu_buttons: Node2D = $MenuButtons
@onready var _triumph_list: HBoxContainer = %TriumphList
@onready var _skip_button: Button = %Skip

signal chosen(triumph: Triumph)

func choose(triumphs: Array[Triumph], scale_: float = 1.0) -> Triumph:
	_menu_buttons.scale = scale_ * Vector2.ONE
	for triumph: Triumph in triumphs:
		var triumph_choice = TriumphChoice.instantiate(triumph)
		triumph_choice.chosen.connect(_on_choose)
		_triumph_list.add_child(triumph_choice)

	_skip_button.pressed.connect(_on_choose.bind(null))
	
	var chosen_triumph = await chosen
	for triumph: Triumph in triumphs:
		triumph.get_parent().remove_child(triumph)
	for child: Node in _triumph_list.get_children():
		_triumph_list.remove_child(child)
	_skip_button.pressed.disconnect(_on_choose)
	return chosen_triumph

func _on_choose(triumph: Triumph) -> void:
	chosen.emit(triumph)

func _ready() -> void:
	globals.viewport_resize.connect(_on_viewport_resize)
	_on_viewport_resize()

func _on_viewport_resize() -> void:
	_menu_buttons.position = globals.viewport_center()
