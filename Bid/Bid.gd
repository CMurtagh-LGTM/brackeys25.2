class_name Bid
extends Node2D

signal bid(int)

@onready var _bid_buttons: Array[Button] = [
	$"HBoxContainer/0",
	$"HBoxContainer/1",
	$"HBoxContainer/2",
	$"HBoxContainer/3",
	$"HBoxContainer/4",
	$"HBoxContainer/5",
	$"HBoxContainer/6",
	$"HBoxContainer/7",
	$"HBoxContainer/8",
	$"HBoxContainer/9",
]

func disable_button(index: int) -> void:
	if index > -1 and index < _bid_buttons.size():
		for button_index: int in index + 1:
			_bid_buttons[button_index].disabled = true

func reset_state() -> void:
	for bid_button: Button in _bid_buttons:
		bid_button.disabled = false

func _on_10_pressed() -> void:
	bid.emit(10)

func _on_9_pressed() -> void:
	bid.emit(9)

func _on_8_pressed() -> void:
	bid.emit(8)

func _on_7_pressed() -> void:
	bid.emit(7)

func _on_6_pressed() -> void:
	bid.emit(6)

func _on_5_pressed() -> void:
	bid.emit(5)

func _on_4_pressed() -> void:
	bid.emit(4)

func _on_3_pressed() -> void:
	bid.emit(3)

func _on_2_pressed() -> void:
	bid.emit(2)

func _on_1_pressed() -> void:
	bid.emit(1)

func _on_0_pressed() -> void:
	bid.emit(0)
