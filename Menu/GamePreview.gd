class_name GamePreview
extends Node2D

@onready var _pips: Array[Sprite2D] = [$Pips/Pip1, $Pips/Pip2, $Pips/Pip3, $Pips/Pip4]
@onready var _info_contaier: Node2D = $Info
@onready var _deck_name: Label = %DeckName
@onready var _deck_order: Label = %DeckOrder
@onready var _card_names: Control = %CardNames
@onready var _win_condition: Label = %WinCondition
@onready var _rounds: Label = %Rounds
@onready var _tricks: Label = %Tricks

signal start_pressed()

func _ready() -> void:
	globals.viewport_resize.connect(_on_viewport_resize)
	_on_viewport_resize()

func _on_viewport_resize() -> void:
	_pips[0].position = Globals.pip_offset
	_pips[1].position = Vector2(globals.viewport_size.x - Globals.pip_offset.x, Globals.pip_offset.y)
	_pips[2].position = Vector2(Globals.pip_offset.x, globals.viewport_size.y - Globals.pip_offset.y)
	_pips[3].position = Vector2(globals.viewport_size.x - Globals.pip_offset.x, globals.viewport_size.y - Globals.pip_offset.y)
	_info_contaier.position = globals.viewport_center()

func _on_start_pressed() -> void:
	start_pressed.emit()

func set_game_info(game_info: GameInfo) -> void:
	_deck_name.text = game_info.deck_info.name
	_deck_order.text = game_info.deck_info.deck_order

	for child: Node in _card_names.get_children():
		_card_names.remove_child(child)
	var suit_containers: Dictionary[Suit, VBoxContainer]
	for card: CardInfo in game_info.deck_info.cards:
		suit_containers.get_or_add(card.suit, VBoxContainer.new())
		var card_name = RichTextLabel.new()
		card_name.bbcode_enabled = true
		card_name.fit_content = true
		card_name.autowrap_mode = TextServer.AUTOWRAP_OFF
		card_name.text = card.get_display_name()
		suit_containers[card.suit].add_child(card_name)
	for suit_container: VBoxContainer in suit_containers.values():
		_card_names.add_child(suit_container)

	_win_condition.text = game_info.win_condition.to_label()
	_rounds.text = str(game_info.rounds)
	_tricks.text = str(game_info.tricks)
