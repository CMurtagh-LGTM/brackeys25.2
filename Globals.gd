class_name Globals
extends Node

const viewport_size := Vector2(1152, 648)

const hand_compasses: Array[Hand.Compass] = [
	Hand.Compass.SOUTH,
	Hand.Compass.WEST,
	Hand.Compass.NORTH,
	Hand.Compass.EAST,
]
const hand_positions: Array[Vector2] = [
	Vector2(viewport_size.x/2, viewport_size.y - viewport_size.y/8),
	Vector2(viewport_size.y/8, viewport_size.y/2),
	Vector2(viewport_size.x/2, viewport_size.y/8),
	Vector2(viewport_size.x - viewport_size.y/8, viewport_size.y/2),
]
const hand_rotations: Array[float] = [
	0, PI/2, PI, -PI/2
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
