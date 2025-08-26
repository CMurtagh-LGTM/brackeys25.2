@tool
class_name CardInfo
extends Resource

@export var suit: Suit

@export var front_colour: Color = Globals.WHITE
@export var border_colour: Color = Globals.BLACK

@export var front_can_play_colour: Color = Globals.LIGHT_GREEN
@export var front_cant_play_colour: Color = Globals.LIGHT_RED

func get_image() -> Texture2D:
	return Texture2D.new()

func get_pip() -> Texture2D:
	return Texture2D.new()

func get_colour() -> Color:
	return Color()

func get_suit_colour() -> Suit.SuitColour:
	return Suit.SuitColour.BLACK

func get_ordinal() -> Card.Ordinal:
	return Card.Ordinal.BOTTOM
