@tool
class_name DeckGenerator
extends Resource

@export var name: String
@export var suits: Array[Suit]
@export var characters: Array[NormalCardInfo.Character]

@export_tool_button("GenerateDeck", "Callable") var generate_deck_action : Callable = generate_deck

func generate_deck() -> void:
	prints("Generating:", name)
	var deck = DeckInfo.new()
	deck.name = name

	for suit in suits:
		for character_index in characters:
			var character_name = NormalCardInfo.Character.keys()[character_index]
			prints("	Adding:", character_name + suit.name)
			var card_info = load("res://Resources/Cards/" + suit.name + "/" + character_name + suit.name + ".tres")
			deck.cards.push_back(card_info)


	ResourceSaver.save(deck, "res://Resources/Decks/" + name + ".tres")
