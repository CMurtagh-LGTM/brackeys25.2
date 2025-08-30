class_name TutorialStep
extends Resource

enum Step {
	BID, # Before bid
	TRICK, # Before trick
	PLAY, # Before play
	TRIUMPH, # Before triumph choice
	TRIUMPH_BID, # Before triumph bid choice
}

@export var popup_text: String
@export var ok_button: bool
@export var step: Step

func _init(popup_text_: String = "", step_: Step = Step.BID, ok_button_: bool = false) -> void:
	popup_text = popup_text_
	ok_button = ok_button_
	step = step_
