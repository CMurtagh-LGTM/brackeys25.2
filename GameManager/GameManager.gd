class_name GameManager
extends Node2D

@export var deck_info: DeckInfo = preload("res://Resources/Decks/French52.tres")

@onready var _hand_scene: PackedScene = preload("res://Hand/Hand.tscn")
@onready var _deck_scene: PackedScene = preload("res://Deck/Deck.tscn")
@onready var _trick_scene: PackedScene = preload("res://Trick/Trick.tscn")

@onready var _arrow: Node2D = $Arrow
@onready var _next: Button = $Next

@onready var _pips_container: Node2D = $Pips
@onready var _pips: Array[Sprite2D] = [$Pips/Pip0, $Pips/Pip1, $Pips/Pip2, $Pips/Pip3, $Pips/Pip4]

const _arrow_offsets: Array[Vector2] = [
	Vector2.DOWN * -Card.height,
	Vector2.LEFT * -Card.height,
	Vector2.UP * -Card.height,
	Vector2.RIGHT * -Card.height,
]

var _deal_size: int = 7

var _deck: Deck
var _hands: Array[Hand]
var _trick: Trick
var _trump: Suit
var _current_hand: int = 0
var _dealer: int = 3 # TODO

func _ready() -> void:
	_deck = _deck_scene.instantiate()
	_deck.deck_info = deck_info
	add_child(_deck)

	_trick = _trick_scene.instantiate()
	_trick.position = get_viewport().size/2
	add_child(_trick)

	for compass: Hand.Compass in Globals.hand_compasses:
		var hand: Hand = _hand_scene.instantiate()

		hand.position = globals.hand_positions[compass]
		hand.rotation = Globals.hand_rotations[compass]

		_hands.push_back(hand)
		add_child(hand)
		hand.play.connect(_on_hand_play)

	_hands[0].set_is_player()
	_deal()

func _calculate_game_state() -> GameState:
	return GameState.new(_trump, _trick.lead_suit())

func _on_hand_play(card: Card) -> void:
	_hands[_current_hand].lose_turn()
	card.reveal()
	_trick.add_card(card, _hand_index_to_compass(_current_hand))
	_current_hand += 1
	_current_hand %= _hands.size()
	if _trick.card_count() >= _hands.size():
		_end_trick()
		return
	_hands[_current_hand].gain_turn(_calculate_game_state())
	_point_to_hand(_hand_index_to_compass(_current_hand))

func _end_trick() -> void:
	var winner: Hand.Compass = _trick.get_winner(_trump)
	_point_to_hand(winner)
	_current_hand = _compass_to_hand_index(winner)
	_arrow.modulate = Globals.LIGHT_GREEN
	_next.visible = true
	await _next.pressed
	_next.visible = false
	_start_trick()

func _deal() -> void:
	for hand: Hand in _hands:
		for _i in range(_deal_size):
			hand.add_card(_deck.draw_card())
	_dealer += 1
	_dealer %= _hands.size()
	_current_hand = _dealer
	_trump = _deck.draw_card().info.suit
	_on_update_trump()
	_start_trick()

func _start_trick() -> void:
	_trick.clear()
	_hands[_current_hand].gain_turn(_calculate_game_state())
	_point_to_hand(_hand_index_to_compass(_current_hand))

func _on_update_trump() -> void:
	_pips_container.visible = _trump != null
	if _trump == null:
		return
	for pip: Sprite2D in _pips:
		pip.texture = _trump.texture
		pip.modulate = Suit.colours[_trump.colour]

func _compass_to_hand_index(compass: Hand.Compass) -> int:
	return compass as int

func _hand_index_to_compass(index: int) -> Hand.Compass:
	return Globals.hand_compasses[index]

func _point_to_hand(hand: Hand.Compass) -> void:
	_arrow.modulate = Globals.BLACK
	_arrow.position = Globals.hand_positions[hand] + _arrow_offsets[hand]
	_arrow.rotation = Globals.hand_rotations[hand]
