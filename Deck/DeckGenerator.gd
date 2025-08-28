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

	characters.sort_custom(func(a, b): return a > b)

	for suit: Suit in suits:
		for character: NormalCardInfo.Character in characters:
			var character_name = NormalCardInfo.Character.keys()[character]
			prints("	Adding:", character_name + suit.name)
			var card_info = load("res://Resources/Cards/" + suit.name + "/" + character_name + suit.name + ".tres")
			deck.cards.push_back(card_info)
	
	# TODO why does this not save?
	deck.deck_order = NormalCardInfo.character_names[characters[0]]
	for character_index:int in range(1, characters.size()):
		deck.deck_order += " > " + NormalCardInfo.character_names[characters[character_index]]
	print(deck.deck_order)

	name = name.replace(" ", "")
	ResourceSaver.save(deck, "res://Resources/Decks/" + name + ".tres")
