class_name TriumphChooser
extends Node2D

@onready var _pips: Array[Sprite2D] = [$Pips/Pip1, $Pips/Pip2, $Pips/Pip3, $Pips/Pip4]
@onready var _menu_buttons: Node2D = $MenuButtons
@onready var _triumph_list: HBoxContainer = %TriumphList

signal chosen(triumph: Triumph)

var _initialised: bool = false

var _triumph_infos: Array[TriumphInfo]
var _triumphs: Array[Triumph]

func initialise() -> void:
	assert(not _initialised)
	for file: String in ResourceLoader.list_directory("res://Resources/Triumph/"):
		_triumph_infos.append(load("res://Resources/Triumph/" + file))
	_initialised = true

func reset() -> void:
	assert(_initialised)
	for triumph_info: TriumphInfo in _triumph_infos:
		_triumphs.append(Triumph.instantiate(triumph_info))

func choose() -> Triumph:
	assert(_initialised)
	var amount = min(_triumphs.size(), 3)
	_triumphs.shuffle()
	for index: int in amount:
		var _triumph_choice: TriumphChoice = TriumphChoice.instantiate(_triumphs[index])
		_triumph_choice.chosen.connect(_on_choose)
		_triumph_list.add_child(_triumph_choice)
	
	return await chosen

func _on_choose(triumph: Triumph) -> void:
	for child: Node in _triumph_list.get_children():
		_triumph_list.remove_child(child)
	chosen.emit(triumph)

func _ready() -> void:
	globals.viewport_resize.connect(_on_viewport_resize)
	_on_viewport_resize()

func _on_viewport_resize() -> void:
	_pips[0].position = Globals.pip_offset
	_pips[1].position = Vector2(globals.viewport_size.x - Globals.pip_offset.x, Globals.pip_offset.y)
	_pips[2].position = Vector2(Globals.pip_offset.x, globals.viewport_size.y - Globals.pip_offset.y)
	_pips[3].position = Vector2(globals.viewport_size.x - Globals.pip_offset.x, globals.viewport_size.y - Globals.pip_offset.y)
	_menu_buttons.position = globals.viewport_center()
