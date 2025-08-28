class_name TriumphChoice
extends Control

const _scene: PackedScene = preload("res://Menu/TriumphChoice.tscn")

@onready var _triumph_container: Container = %TriumphContainer
@onready var _triumph_description: RichTextLabel = %Description

var _triumph: Triumph

signal chosen(triumph: Triumph)

func _ready() -> void:
	_triumph_container.add_child(_triumph)
	_triumph_container.custom_minimum_size = Vector2(Card.width * 1.32, Card.height)
	_triumph.scale = Vector2.ONE * 2
	_triumph.position = _triumph_container.custom_minimum_size/2
	_triumph_description.text = _triumph.description()

static func instantiate(triumph: Triumph) -> TriumphChoice:
	var triumph_choice: TriumphChoice = _scene.instantiate()
	triumph_choice._triumph = triumph
	return triumph_choice

func _on_choose_pressed():
	_triumph.scale = Vector2.ONE
	chosen.emit(_triumph)
