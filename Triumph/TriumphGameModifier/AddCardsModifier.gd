class_name AddCardsModifier
extends TriumphGameModifier

@export var card: NormalCardInfo.Character

func _find_card_info(suit: Suit, character: NormalCardInfo.Character) -> CardInfo:
	var character_name: String = NormalCardInfo.Character.keys()[character]
	var info: CardInfo = load("res://Resources/Cards/" + suit.name + "/" + character_name + suit.name + ".tres")
	assert(info != null)
	return info

func change_game(state: TriumphGameState) -> void:
	for suit: Suit in state.deck.deck_info.suits():
		var card_to_add := Card.instantiate(_find_card_info(suit, card))
		state.origin.add_child(card_to_add)
		state.deck.add_card(card_to_add)
