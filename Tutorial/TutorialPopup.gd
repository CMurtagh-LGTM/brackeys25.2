class_name TutorialPopup
extends Node2D

@onready var _tutorial_text: RichTextLabel = %TutorialText
@onready var _ok_button: Button = %Ok
@onready var _ok_container: Container = %OkContainer

func show_popup(text: String, use_ok: bool) -> void:
	_tutorial_text.text = text
	_ok_container.visible = use_ok
	if use_ok:
		await _ok_button.pressed
