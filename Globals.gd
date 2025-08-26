class_name Globals
extends Node

var viewport_size := Vector2(1152, 648)

signal viewport_resize

func viewport_center() -> Vector2:
	return viewport_size/2

func hand_position(compass: Hand.Compass) -> Vector2:
	return viewport_center() + compass_direction[compass] * (viewport_size/2 - viewport_size/8)

const hand_rotations: Array[float] = [
	0, PI/2, PI, -PI/2
]

const hand_compasses: Array[Hand.Compass] = [
	Hand.Compass.SOUTH,
	Hand.Compass.WEST,
	Hand.Compass.NORTH,
	Hand.Compass.EAST,
]
const compass_direction: Array[Vector2] = [
	Vector2.DOWN,
	Vector2.LEFT,
	Vector2.UP,
	Vector2.RIGHT,
]

const WHITE: Color = 0xF5DEB3FF #0.96, 0.87, 0.70
const BLACK: Color = 0x37322DFF
const RED: Color = 0xDC645AFF

const LIGHT_RED: Color = 0xF4BCB2FF
const LIGHT_GREEN: Color = 0xEAF4B2FF

var open_hands: bool = false

func _ready() -> void:
	var viewport = get_viewport()
	viewport_size = viewport.get_stretch_transform().affine_inverse() * Vector2(viewport.size)
	viewport.size_changed.connect(_on_viewport_size_changed)
	
func _on_viewport_size_changed() -> void:
	var viewport = get_viewport()
	viewport_size = viewport.get_stretch_transform().affine_inverse() * Vector2(viewport.size)
	viewport_resize.emit()
