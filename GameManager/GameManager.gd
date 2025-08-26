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
const _pip_offset: Vector2 = Vector2(46.0, 49.0)

var _deal_size: int = 7

var _deck: Deck
var _hands: Array[Hand]
var _trick: Trick
var _trump: Suit
var _current_hand: int = 0
var _dealer: int = 3 # TODO
var _current_arrow_point: Hand.Compass

var _next_position_offset: Vector2 = Vector2(74, 56)

func _ready() -> void:
	globals.viewport_resize.connect(_on_viewport_resize)

	_deck = _deck_scene.instantiate()
	_deck.deck_info = deck_info
	add_child(_deck)

	_trick = _trick_scene.instantiate()
	add_child(_trick)

	for compass: Hand.Compass in Globals.hand_compasses:
		var hand: Hand = _hand_scene.instantiate()

		hand.rotation = Globals.hand_rotations[compass]

		_hands.push_back(hand)
		add_child(hand)
		hand.play.connect(_on_hand_play)

	_on_viewport_resize()

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
	_next.visible = false
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

func _point_to_hand(compass: Hand.Compass) -> void:
	_current_arrow_point = compass
	_arrow.modulate = Globals.BLACK
	_arrow.position = globals.hand_position(compass) + _arrow_offsets[compass]
	_arrow.rotation = Globals.hand_rotations[compass]

func _on_viewport_resize() -> void:
	_next.position = globals.viewport_center() + _next_position_offset
	for hand_index: int in _hands.size():
		_hands[hand_index].position = globals.hand_position(_hand_index_to_compass(hand_index))

	_trick.position = globals.viewport_center()
	_pips[0].position = globals.viewport_center()
	_pips[1].position = _pip_offset
	_pips[2].position = Vector2(globals.viewport_size.x - _pip_offset.x, _pip_offset.y)
	_pips[3].position = Vector2(_pip_offset.x, globals.viewport_size.y - _pip_offset.y)
	_pips[4].position = Vector2(globals.viewport_size.x - _pip_offset.x, globals.viewport_size.y - _pip_offset.y)

	_arrow.position = globals.hand_position(_current_arrow_point) + _arrow_offsets[_current_arrow_point]
