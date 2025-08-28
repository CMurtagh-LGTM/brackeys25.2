class_name JokerInfo
extends CardInfo

var _image: Texture2D = preload("res://Assets/Characters/Joker.svg")

func get_image() -> Texture2D:
	return _image

func get_ordinal() -> Card.Ordinal:
	return Card.Ordinal.TOP

func get_bower() -> Card.Bower:
	return Card.Bower.BEST

func get_display_name() -> String:
	return "Joker"

