@tool
class_name NormalCardInfo
extends CardInfo

enum Character {
	ZERO, ONE, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE, TEN, ELEVEN, TWELVE, THIRTEEN, BANNER, JACK, CAVALIER, QUEEN, KING, ACE
}

const highest_character: Character = Character.ACE

@export var character: Character

const characters: Array[Texture2D] = [
	preload("res://Assets/Characters/0.svg"),
	preload("res://Assets/Characters/1.svg"),
	preload("res://Assets/Characters/2.svg"),
	preload("res://Assets/Characters/3.svg"),
	preload("res://Assets/Characters/4.svg"),
	preload("res://Assets/Characters/5.svg"),
	preload("res://Assets/Characters/6.svg"),
	preload("res://Assets/Characters/7.svg"),
	preload("res://Assets/Characters/8.svg"),
	preload("res://Assets/Characters/9.svg"),
	preload("res://Assets/Characters/10.svg"),
	preload("res://Assets/Characters/11.svg"),
	preload("res://Assets/Characters/12.svg"),
	preload("res://Assets/Characters/13.svg"),
	preload("res://Assets/Characters/B.svg"),
	preload("res://Assets/Characters/J.svg"),
	preload("res://Assets/Characters/C.svg"),
	preload("res://Assets/Characters/Q.svg"),
	preload("res://Assets/Characters/K.svg"),
	preload("res://Assets/Characters/A.svg"),
]

const ordinal_character: Array[Card.Ordinal] = [
	Card.Ordinal.ZERO,
	Card.Ordinal.ONE,
	Card.Ordinal.TWO,
	Card.Ordinal.THREE,
	Card.Ordinal.FOUR,
	Card.Ordinal.FIVE,
	Card.Ordinal.SIX,
	Card.Ordinal.SEVEN,
	Card.Ordinal.EIGHT,
	Card.Ordinal.NINE,
	Card.Ordinal.TEN,
	Card.Ordinal.ELEVEN,
	Card.Ordinal.TWELVE,
	Card.Ordinal.THIRTEEN,
	Card.Ordinal.BANNER,
	Card.Ordinal.JACK,
	Card.Ordinal.CAVALIER,
	Card.Ordinal.QUEEN,
	Card.Ordinal.KING,
	Card.Ordinal.ACE
]


func get_image() -> Texture2D:
	return characters[character]

func get_ordinal() -> Card.Ordinal:
	return ordinal_character[character]
