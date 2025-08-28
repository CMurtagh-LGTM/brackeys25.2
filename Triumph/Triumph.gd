class_name Triumph
extends Node2D

const _triumphs_scene: PackedScene = preload("res://Triumph/Triumph.tscn")

var _info: TriumphInfo

@onready var _image: Sprite2D = $Image

func description() -> String:
	return _info.description

static func instantiate(info: TriumphInfo) -> Triumph:
	var triumph = _triumphs_scene.instantiate()
	triumph._info = info
	return triumph

func _ready() -> void:
	_image.texture = _info.texture

