@tool
class_name Card
extends Node2D

enum Ordinal {
	BOTTOM, ZERO, ONE, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE, TEN, ELEVEN, TWELVE, THIRTEEN, BANNER, JACK, CAVALIER, QUEEN, KING, ACE, TOP
}

enum CanPlay {
	NONE, YES, NO
}

enum Bower {
	NONE, LEFT, RIGHT, BEST
}

@export var _info: CardInfo

@onready var _pips: Array[Sprite2D] = [$Face/Pip, $Face/Pip2]
@onready var _character_sprite: Sprite2D = $Face/Character
@onready var _face: Node2D = $Face
@onready var _back: Node2D = $Back
@onready var _front: Node2D = $Front
@onready var _front_border: Node2D = $FrontBorder

const width: float = 58
const height: float = 92

var _revealed: bool = false
var _active: bool = false
var _can_play: CanPlay = CanPlay.NONE
var _highlight: Color
var _highlighted: bool = false
var _transient: bool = false

signal clicked
signal hovered

func get_bower(trump: Suit) -> Bower:
	# If card is intrinsic bower
	if _info.get_bower() != Bower.NONE:
		return _info.get_bower()
	
	# NT has no right or left
	if trump == null:
		return Bower.NONE

	# Right or LEFT
	if trump.colour == _info.get_suit_colour() and _info.get_ordinal() == Ordinal.JACK:
		if trump == _info.suit:
			return Bower.RIGHT
		return Bower.LEFT
	return Bower.NONE

func get_bower_colour() -> Color:
	return _info.bower_colour

func suit(trump: Suit) -> Suit:
	if get_bower(trump) != Bower.NONE:
		return trump
	return _info.suit

func ordinal() -> Ordinal:
	return _info.get_ordinal()

func conceal() -> void:
	reveal(false)

func reveal(value: bool = true) -> void:
	_revealed = value
	_update_revealed()

func highlight(colour: Color) -> void:
	_highlighted = true
	_highlight = colour
	_colour_card()

func unhighlight() -> void:
	_highlighted = false
	_colour_card()

func set_active(value: bool) -> void:
	_active = value
	_update_revealed()

func set_can_play(can_play: CanPlay) -> void:
	_can_play = can_play
	_on_update_can_play()

func move_to(node: Node2D, dest_position: Vector2, dest_rotation: float, duration: float = Globals.card_move_time) -> void:
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(self, "global_position", dest_position + node.global_position, duration)
	tween.tween_property(self, "global_rotation", dest_rotation + node.rotation, duration)
	await tween.finished
	self.get_parent().remove_child(self)
	node.add_child(self)
	self.position = dest_position
	self.rotation = dest_rotation

func reset_state() -> void:
	rotation = 0
	position = Vector2.ZERO
	_revealed = false
	_active = false
	_can_play = CanPlay.NONE
	_highlighted = false
	_update_revealed()

## Transient cards cannot be added to the deck
func transient() -> bool:
	return _transient

func info() -> CardInfo:
	return _info

func _update_revealed() -> void:
	_face.visible = _revealed
	_back.visible = !_revealed
	_on_update_can_play()

func _update_image() -> void:
	for pip: Sprite2D in _pips:
		pip.texture = _info.get_pip()
		pip.modulate = _info.get_colour()
	_character_sprite.texture = _info.get_image()
	_character_sprite.modulate = _info.get_colour()

func _on_update_can_play() -> void:
	_colour_card()

func _colour_card() -> void:
	if _revealed and _active:
		if _can_play == CanPlay.YES:
			_front.modulate = _info.front_can_play_colour
		elif _can_play == CanPlay.NO:
			_front.modulate = _info.front_cant_play_colour
		elif _highlighted:
			_front.modulate = _highlight
		else:
			_front.modulate = _info.front_colour
	elif _highlighted:
		_front.modulate = _highlight
	else:
		_front.modulate = _info.front_colour
	_front_border.modulate = _info.border_colour

func _ready() -> void:
	_update_image()
	_update_revealed()
	_on_update_can_play()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint() and _info:
		_update_image()
		_on_update_can_play()
		return

const card_scene: PackedScene = preload("res://Card/Card.tscn")
static func instantiate(card_info: CardInfo, transient_: bool = false) -> Card:
	var card: Card = card_scene.instantiate()
	card._info = card_info
	card._transient = transient_
	return card

func _on_mouse_area_input_event(_viewport:Node, event:InputEvent, _shape_idx:int) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_mask == MOUSE_BUTTON_LEFT:
				clicked.emit()

func _on_mouse_area_mouse_entered() -> void:
	hovered.emit()
