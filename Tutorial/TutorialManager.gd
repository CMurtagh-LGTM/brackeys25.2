class_name TutorialManager
extends Node2D

const _scene: PackedScene = preload("res://Tutorial/TutorialManager.tscn")

@onready var _popup: TutorialPopup = $TutorialPopup

var _tutorials: Array[TutorialStep] = [
	TutorialStep.new(
	"""Here you place your bid, I'll explain later. Press 1 for now.""", TutorialStep.Step.BID, false
	),
	TutorialStep.new(
	"""You now will play 2 tricks. To take the trick you must play the highest card.""", TutorialStep.Step.TRICK, true
	),
	TutorialStep.new(
	"""Play any card for now.""", TutorialStep.Step.PLAY, false
	),
	TutorialStep.new(
	"""Notice that [img=16 color=#37322D]res://Assets/Characters/Joker.svg[/img] and \
[img=16 color=#37322D]res://Assets/Suits/Spade.svg[/img]J will beat all other cards. \
These are the Best Bower and Right Bower respectively. \
Play another card.""", TutorialStep.Step.PLAY, false
	),
	TutorialStep.new(
	"""You will now choose a triumph, these are abilities to help you win. \
They can only be used once per match - unless stated otherwise. \
Do not press pass, you will not get a triumph if you do so.""", TutorialStep.Step.TRIUMPH, true
	),
	TutorialStep.new(
	"""You can now choose what triumphs you wish to play. \
You can play any number of triumphs each round but most triumphs can only be played once a match. \
Press pass if you want to save the remaining triumphs for a later round.""", TutorialStep.Step.TRIUMPH_BID, true # TODO make work
	),
	TutorialStep.new(
	"""Placing a bid is important. This sets the minimum amount of tricks you need to take this round, so lower bids are good. \
If you meet it you gain that much score, but if you fail you will lose that much score.
To pass this match you must place at least 3rd, if you manage to meet each bid you place this match you should acheive that, \
so place the minimum bid each round.""", TutorialStep.Step.BID, false
	),
	TutorialStep.new(
	"""Now there are 2 suits. If you have cards of the same suit that the leading player played you must play one of them.""", TutorialStep.Step.PLAY, false
	),
	TutorialStep.new(
	"""You see that the pips in the center and corners of the screen show the suit of the card turned up before players placed their bids. \
This is the trump suit, the trump suit will always beat cards of other suits.""", TutorialStep.Step.PLAY, false
	),
	TutorialStep.new(
	"""The player who scored the highest is given the turned up card - ties are broken by turn order. \
They then discard a card to the bonus pile.""", TutorialStep.Step.BID, false
	),
	TutorialStep.new(
	"""You see that the pips in the center and corners of the screen show the suit of the card turned up before players placed their bids. \
This is the trump suit, the trump suit will always beat cards of other suits.""", TutorialStep.Step.PLAY, false
	),
	TutorialStep.new(
	"""The J that doesn't show the trump suit is the Left Bower and only loses to other bowers. \
This card is not of the suit shown but is of the trump suit.""", TutorialStep.Step.PLAY, false
	),
	TutorialStep.new(
	"""Now there are four suits. If you play a card that isn't of the leading suit or trump suit it can not win. \
Onlt the Js of the trump colour are bowers, the other 2 Js behave normally.""", TutorialStep.Step.BID, false
	),
	TutorialStep.new(
	"""The player who takes the most tricks each round gains bonus score depending on cards in the bonus pile.
Trump number cards are worth 1, trump letter cards of the trump suit are worth 2 and bowers are worth 3, \
cards not of the trump suit are worthless.""", TutorialStep.Step.BID, false
	),
	TutorialStep.new(
	"""The total bid must exceed the total number of tricks playerd - at least one player will not meet their bid. \
Each player's minimum bid is the target bid minus the culmative bid total divided by players yet to bid. \
So if you bid high future players can bid lower this round.""", TutorialStep.Step.BID, false
	),
]

var _tutorial_index: int = 0

func is_bid() -> bool:
	if _tutorial_index >= _tutorials.size():
		return false
	return _tutorials[_tutorial_index].step == TutorialStep.Step.BID

func is_trick() -> bool:
	if _tutorial_index >= _tutorials.size():
		return false
	return _tutorials[_tutorial_index].step == TutorialStep.Step.TRICK

func is_play() -> bool:
	if _tutorial_index >= _tutorials.size():
		return false
	return _tutorials[_tutorial_index].step == TutorialStep.Step.PLAY

func is_triumph() -> bool:
	if _tutorial_index >= _tutorials.size():
		return false
	return _tutorials[_tutorial_index].step == TutorialStep.Step.TRIUMPH

func is_triumph_bid() -> bool:
	if _tutorial_index >= _tutorials.size():
		return false
	return _tutorials[_tutorial_index].step == TutorialStep.Step.TRIUMPH_BID

func show_next() -> void:
	_popup.visible = true
	var tutorial: TutorialStep = _tutorials[_tutorial_index]
	await _popup.show_popup(tutorial.popup_text, tutorial.ok_button)
	_tutorial_index += 1

func dismiss_popup() -> void:
	_popup.visible = false

func _ready() -> void:
	_popup.visible = false

static func instantiate() -> TutorialManager:
	return _scene.instantiate()
