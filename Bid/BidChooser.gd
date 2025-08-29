class_name BidChooser
extends Node2D

signal bid_pressed(Bid)

const bid_scene: PackedScene = preload("res://Bid/BidButton.tscn")

@onready var _bids_container: Container = $BidsContainer

func choose_bid(game_state: GameState, min_allowed_bid: int) -> Bid:
	for bid: Bid in game_state.bids():
		var bid_button: Button = bid_scene.instantiate()
		bid_button.pressed.connect(_on_pressed.bind(bid))
		if bid.target < min_allowed_bid:
			bid_button.disabled = true
		bid_button.text = bid.character
		_bids_container.add_child(bid_button)

	var selected_bid: Bid =  await bid_pressed

	while _bids_container.get_child_count() > 0:
		_bids_container.remove_child(_bids_container.get_child(0))

	return selected_bid

func _on_pressed(bid: Bid) -> void:
	bid_pressed.emit(bid)

