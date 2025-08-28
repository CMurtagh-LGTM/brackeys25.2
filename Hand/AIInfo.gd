class_name AIInfo
extends Resource

@export var trump_bonus: float = 0.4

# TODO calculate the threshold based on the deck
@export var singleton_threshold: Card.Ordinal = Card.Ordinal.QUEEN
@export var offsuit_threshold: Card.Ordinal = Card.Ordinal.ACE

@export var stash_threshold: float = 1.5
@export var high_bid: int = 3
# How much to reduce score (highest_bid - high_bid + 1) * high_bid_penalty 
@export var high_bid_penalty = 0.25
@export var turnup_score_threshold: float = 0.5
@export var turnup_reveal_threshold: float = 0.75
