class_name ExcuseInfo
extends CardInfo

var _image: Texture2D = preload("res://Assets/Characters/Empty.svg")

func get_image() -> Texture2D:
	return _image

func get_ordinal() -> Card.Ordinal:
	return Card.Ordinal.BOTTOM

func get_excuse() -> bool:
	return true

func get_display_name() -> String:
	return "Excuse"

