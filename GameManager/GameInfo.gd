class_name GameInfo
extends Resource

@export var deck_info: DeckInfo
@export var ai_info: AIInfo

@export var rounds: int = 3
@export var tricks: int = 7
@export var win_condition: WinCondition
@export var hands: int = 4

## Select -1 for a random dealer
@export_range(-1, 3) var dealer: int = -1
