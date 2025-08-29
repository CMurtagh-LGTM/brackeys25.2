extends Node

@onready var _mute_button: Button = $MuteButton
@onready var _music_player: AudioStreamPlayer = $MusicPlayer

func _handle_mute_changed() -> void:
	_music_player.stream_paused = globals.muted
	if globals.muted:
		_mute_button.text = "Unmute"
	else:
		_mute_button.text = "Mute"

func _on_mute_button_pressed() -> void:
	globals.muted = not globals.muted
	_handle_mute_changed()

func _ready() -> void:
	globals.viewport_resize.connect(_on_viewport_resize)
	_on_viewport_resize()
	_handle_mute_changed()

func _on_viewport_resize() -> void:
	_mute_button.position.y = globals.viewport_size.y - _mute_button.size.y
	_mute_button.position.x = 0
