class_name Triumph
extends Node2D

const _triumphs_scene: PackedScene = preload("res://Triumph/Triumph.tscn")

var _info: TriumphInfo

static func instantiate(info: TriumphInfo) -> Triumph:
	var triumph = _triumphs_scene.instantiate()
	triumph._info = info
	return triumph

func description() -> String:
	return _info.description
