extends Node

const games: Array[GameInfo] = [
	preload("res://Resources/Games/One.tres")
]

@onready var _main_menu: MainMenu = $MainMenu
@onready var _game_preview: GamePreview = $GamePreview
@onready var _game_over: GameOver = $GameOver

const _game_scene: PackedScene = preload("res://GameManager/GameManager.tscn")

func _ready() -> void:
	_game_preview.visible = false
	while true:
		await _show_main_menu()
		if await _play():
			pass # Win
		else:
			await _show_game_over()

func _show_main_menu() -> void:
	_main_menu.visible = true
	await _main_menu.start_pressed
	_main_menu.visible = false

func _play() -> bool:
	for game: GameInfo in games:
		_game_preview.set_game_info(game)
		_game_preview.visible = true
		await _game_preview.start_pressed
		_game_preview.visible = false

		var game_manager = _game_scene.instantiate()
		game_manager.deck_info = game.deck_info
		game_manager.set_deal_count(game.tricks)

		add_child(game_manager)
		var result: Array = await game_manager.finished
		remove_child(game_manager)

		if result[1] < game.par:
			return false
	return true

func _show_game_over() -> void:
	_game_over.visible = true
	await _game_over.main_menu_pressed
	_game_over.visible = false
	
	_show_main_menu()
