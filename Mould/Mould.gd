extends ColorRect

func _ready() -> void:
	material.set_shader_parameter("offset", Vector2(randf_range(-1, 1), randf_range(-1, 1)))

