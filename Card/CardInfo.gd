@tool
class_name CardInfo
extends Resource

@export var suit: Suit

@export var front_colour: Color = Globals.WHITE
@export var border_colour: Color = Globals.BLACK

@export var front_can_play_colour: Color = Globals.LIGHT_GREEN
@export var front_cant_play_colour: Color = Globals.LIGHT_RED

@export var bower_colour: Color = Globals.LIGHT_BLUE

func get_image() -> Texture2D:
	return Texture2D.new()

func get_pip() -> Texture2D:
	if suit == null:
		return null
	return suit.texture

func get_colour() -> Color:
	return Suit.colours[get_suit_colour()]

func get_suit_colour() -> Suit.SuitColour:
	if suit == null:
		return Suit.SuitColour.BLACK
	return suit.colour 

func get_ordinal() -> Card.Ordinal:
	return Card.Ordinal.BOTTOM

func get_bower() -> Card.Bower:
	return Card.Bower.NONE

func get_display_name() -> String:
	return ""

