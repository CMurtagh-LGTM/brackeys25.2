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

		var tutorial_complete: bool = false
		if _has_save_file():
			tutorial_complete = _load_game().tutorial_complete

		var play_state: MainMenu.PlayState = await _show_main_menu(tutorial_complete)

		var save_file: SaveFile = SaveFile.new()
		save_file.tutorial_complete = tutorial_complete
		var tutorial_manager: TutorialManager = TutorialManager.instantiate()
		if play_state == MainMenu.PlayState.CONTINUE and _has_save_file():
			save_file = _load_game()
			tutorial_manager.set_index(save_file.tutorial_index)

		if play_state == MainMenu.PlayState.START:
			tutorial_manager.set_index(TutorialManager.end_index())

		await _play(tutorial_manager, save_file)

func _show_main_menu(tutorial_complete: bool) -> MainMenu.PlayState:
	var can_start: bool = false
	var can_continue: bool = false
	if _has_save_file():
		can_continue = true
		can_start = tutorial_complete

	_main_menu.enable_buttons(can_start, can_continue)
	_main_menu.visible = true
	var use_tutorial: MainMenu.PlayState = await _main_menu.start_pressed
	_main_menu.visible = false
	return use_tutorial

func _play(tutorial_manager: TutorialManager, save_file: SaveFile) -> void:
	_triumph_pool.reset()
	var triumphs: Array[Triumph] = []

	for triumph_info: TriumphInfo in save_file.triumph_infos:
		triumphs.push_back(_triumph_pool.retrieve_triumph(triumph_info))

	for index: int in range(save_file.current_level, games.size()):
		_save_game(tutorial_manager, save_file.tutorial_complete, index, triumphs)

		var game: GameInfo = games[index]
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
		game_manager.set_dealer(game.dealer)
		game_manager.set_triumphs(triumphs)
		game_manager.set_tutorial_manager(tutorial_manager)

		add_child(game_manager)
		# Can't be Array[int], as much as I'd like that
		var result: Array = await game_manager.finished
		# var result := [0, 100]
		remove_child(game_manager)

		var place: int = result[0]
		var score: int = result[1]

		if not game.win_condition.has_won(place, score):
			_save_game(tutorial_manager, save_file.tutorial_complete, 0, [])
			await _show_game_over(place, score, game.win_condition.to_label())
			return

		if tutorial_manager.is_triumph():
			add_child(tutorial_manager)
			tutorial_manager.position = globals.viewport_center()
			await tutorial_manager.show_next()
			tutorial_manager.dismiss_popup()
			remove_child(tutorial_manager)

		if index < games.size() - 1:
			await _show_triumph_chooser(triumphs)
	await _show_victory()

func _save_game(tutorial_manager: TutorialManager, tutorial_complete: bool, level_index: int, triumphs: Array[Triumph]) -> void:
	var triumph_infos: Array[TriumphInfo] = []
	for triumph: Triumph in triumphs:
		triumph_infos.push_back(triumph.info())

	var tutorial_manager_index: int = TutorialManager.end_index()
	if tutorial_manager != null:
		tutorial_manager_index = tutorial_manager.index()
		tutorial_complete = tutorial_complete or tutorial_manager.index() >= TutorialManager.end_index()

	var save_file: SaveFile = SaveFile.new(tutorial_manager_index, tutorial_complete, level_index, triumph_infos)
	ResourceSaver.save(save_file, "user://save.tres")

func _has_save_file() -> bool:
	return ResourceLoader.exists("user://save.tres")

func _load_game() -> SaveFile:
	return load("user://save.tres")

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
