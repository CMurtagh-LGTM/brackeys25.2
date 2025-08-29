class_name Triumph
extends Node2D

const _triumphs_scene: PackedScene = preload("res://Triumph/Triumph.tscn")

var _info: TriumphInfo

var _exhausted: bool = false

@onready var _image: Sprite2D = $Image

func unexhaust() -> void:
	_exhausted = false

func before_bid(state: TriumphGameState) -> void:
	@warning_ignore("redundant_await")
	await _info.action.before_bid(state)
	_exhausted = _info.exhausts

func has_before_bid(state: TriumphGameState) -> bool:
	return not _exhausted and _info.action.has_before_bid(state)

func description() -> String:
	return _info.description

static func instantiate(info: TriumphInfo) -> Triumph:
	var triumph = _triumphs_scene.instantiate()
	triumph._info = info
	return triumph

func _ready() -> void:
	_image.texture = _info.texture

