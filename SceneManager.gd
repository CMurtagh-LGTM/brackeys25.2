extends Node

const games: Array[GameInfo] = [
	preload("res://Resources/Games/One.tres"),
	preload("res://Resources/Games/Two.tres"),
	preload("res://Resources/Games/Three.tres"),
	preload("res://Resources/Games/Four.tres"),
	preload("res://Resources/Games/Five.tres"),
	preload("res://Resources/Games/Six.tres"),
	preload("res://Resources/Games/Seven.tres"),
]

@onready var _main_menu: MainMenu = $MainMenu
@onready var _game_preview: GamePreview = $GamePreview
@onready var _game_over: GameOver = $GameOver
@onready var _victory: Victory = $Victory
@onready var _triumph_chooser: TriumphChooser = $TriumphChooser

var _triumph_pool: TriumphPool

const _game_scene: PackedScene = preload("res://GameManager/GameManager.tscn")

func _ready() -> void:
	_game_preview.visible = false
	_triumph_pool = TriumphPool.new()
	while true:
		await _show_main_menu()
		await _play()

func _show_main_menu() -> void:
	_main_menu.visible = true
	await _main_menu.start_pressed
	_main_menu.visible = false

func _play() -> void:
	_triumph_pool.reset()
	var triumphs: Array[Triumph] = []
	for game: GameInfo in games:
		await _show_game_preview(game)

		for triumph_: Triumph in triumphs:
			triumph_.unexhaust()

		var game_manager: GameManager = _game_scene.instantiate()
		game_manager.set_deck_info(game.deck_info)
		game_manager.set_ai_info(game.ai_info)
		game_manager.set_deal_count(game.rounds)
		game_manager.set_trick_count(game.tricks)
		game_manager.set_win_condition(game.win_condition.to_label())
		game_manager.set_hand_count(game.hands)
		game_manager.set_triumphs(triumphs)

		add_child(game_manager)
		# Can't be Array[int], as much as I'd like that
		var result: Array = await game_manager.finished
		# var result := [0, 100]
		remove_child(game_manager)

		var place: int = result[0]
		var score: int = result[1]

		if not game.win_condition.has_won(place, score):
			await _show_game_over(place, score, game.win_condition.to_label())
			return

		await _show_triumph_chooser(triumphs)

	await _show_victory()

func _show_game_preview(game: GameInfo) -> void:
	_game_preview.set_game_info(game)
	_game_preview.visible = true
	await _game_preview.start_pressed
	_game_preview.visible = false

func _show_triumph_chooser(triumphs: Array[Triumph]) -> void:
	if not _triumph_pool.is_empty():
		_triumph_chooser.visible = true
		var triumph = await _triumph_chooser.choose(_triumph_pool.choices(3))
		if triumph != null:
			_triumph_pool.remove_choice(triumph)
			triumphs.append(triumph)
		_triumph_chooser.visible = false

func _show_game_over(place: int, score: int, win_label: String) -> void:
	_game_over.set_score(score)
	_game_over.set_place(place)
	_game_over.set_win_condition(win_label)
	_game_over.visible = true
	await _game_over.main_menu_pressed
	_game_over.visible = false

func _show_victory() -> void:
	_victory.visible = true
	await _victory.main_menu_pressed
	_victory.visible = false
	
