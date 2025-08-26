@tool
class_name Suit
extends Resource

enum SuitColour {
	BLACK, RED, YELLOW, GREEN
}

const colours: Array[Color] = [
	Globals.BLACK, Globals.RED, Globals.YELLOW, Globals.GREEN,
]

@export var name: String
@export var colour: SuitColour
@export var texture: Texture2D

@export_tool_button("GenerateNormalCardInfo", "Callable") var generate_normal_card_info_action : Callable = generate_normal_card_info

func generate_normal_card_info() -> void:
	for character_index in NormalCardInfo.highest_character + 1:
		var character_name = NormalCardInfo.Character.keys()[character_index]
		prints("Generating:", character_name + name)

		var card_info := NormalCardInfo.new()
		card_info.suit = self
		card_info.character = character_index as NormalCardInfo.Character
		ResourceSaver.save(card_info, "res://Resources/Cards/" + name + "/" + character_name + name + ".tres")


