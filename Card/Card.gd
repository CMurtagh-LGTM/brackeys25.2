@tool
class_name Card
extends Node2D

enum Ordinal {
	BOTTOM, ZERO, ONE, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE, TEN, ELEVEN, TWELVE, THIRTEEN, BANNER, JACK, CAVALIER, QUEEN, KING, ACE, TOP
}

enum CanPlay {
	NONE, YES, NO
}

@export var info: CardInfo

@onready var _pips: Array[Sprite2D] = [$Face/Pip, $Face/Pip2]
@onready var _character_sprite: Sprite2D = $Face/Character
@onready var _face: Node2D = $Face
@onready var _back: Node2D = $Back
@onready var _front: Node2D = $Front
@onready var _front_border: Node2D = $FrontBorder

const width: float = 58
const height: float = 92

var _revealed: bool = true
var _active: bool = false
var _can_play: CanPlay = CanPlay.NONE

signal clicked
signal hovered

func conceal() -> void:
	reveal(false)

func reveal(value: bool = true) -> void:
	_revealed = value
	_update_revealed()

func set_active(value: bool) -> void:
	_active = value
	_update_revealed()

func set_can_play(can_play: CanPlay) -> void:
	_can_play = can_play
	_on_update_can_play()

func _update_revealed() -> void:
	_face.visible = _revealed
	_back.visible = !_revealed
	_on_update_can_play()

func _update_image() -> void:
	for pip: Sprite2D in _pips:
		pip.texture = info.get_pip()
		pip.modulate = info.get_colour()
	_character_sprite.texture = info.get_image()
	_character_sprite.modulate = info.get_colour()

func _on_update_can_play() -> void:
	if _revealed and _active:
		if _can_play == CanPlay.YES:
			_front.modulate = info.front_can_play_colour
		elif _can_play == CanPlay.NO:
			_front.modulate = info.front_cant_play_colour
		else:
			_front.modulate = info.front_colour
	else:
		_front.modulate = info.front_colour
	_front_border.modulate = info.border_colour

func _ready() -> void:
	_update_image()
	_update_revealed()
	_on_update_can_play()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint() and info:
		_update_image()
		_on_update_can_play()
		return

const card_scene: PackedScene = preload("res://Card/Card.tscn")
static func instantiate(card_info: CardInfo) -> Card:
	var card: Card = card_scene.instantiate()
	card.info = card_info
	return card

func _on_mouse_area_input_event(_viewport:Node, event:InputEvent, _shape_idx:int) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_mask == MOUSE_BUTTON_LEFT:
				clicked.emit()

func _on_mouse_area_mouse_entered() -> void:
	hovered.emit()
