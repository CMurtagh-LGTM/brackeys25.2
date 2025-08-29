class_name MisereModifier
extends TriumphGameModifier

func change_game(state: TriumphGameState) -> void:
	state.game_state.add_bid(MisereBid.new())

