class_name GameState
extends RefCounted

var deck_info: DeckInfo

var _trump: Suit
var _trick: Trick
var _hand_count: int
var _turnup: Card

signal trump_changed
signal turnup_changed

func _init(deck_info_: DeckInfo, trick_: Trick, hand_count: int):
	deck_info = deck_info_
	_trick = trick_
	_hand_count = hand_count

func lead_suit() -> Suit:
	return _trick.lead_suit(_trump)

func trump() -> Suit:
	return _trump

func set_trump(trump_: Suit) -> void:
	_trump = trump_
	trump_changed.emit()

func players() -> int:
	return _hand_count

func last_play() -> bool:
	return _trick.card_count() == _hand_count - 1

func trick() -> Array[Card]:
	return _trick.get_cards()

func turnup() -> Card:
	return _turnup

func set_turnup(card: Card) -> void:
	if card == _turnup:
		return
	_turnup = card
	if _turnup != null:
		_turnup.reveal()
	turnup_changed.emit()
