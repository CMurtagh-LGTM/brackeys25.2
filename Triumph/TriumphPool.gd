class_name TriumphPool
extends RefCounted

var _triumph_infos: Array[TriumphInfo]
var _triumphs: Array[Triumph]

func _init() -> void:
	for file: String in ResourceLoader.list_directory("res://Resources/Triumph/"):
		_triumph_infos.append(load("res://Resources/Triumph/" + file))

func reset() -> void:
	_triumphs.clear()
	for triumph_info: TriumphInfo in _triumph_infos:
		_triumphs.append(Triumph.instantiate(triumph_info))
	shuffle()

func shuffle() -> void:
	_triumphs.shuffle()

func choices(n: int) -> Array[Triumph]:
	var triumphs: Array[Triumph] = []
	var amount = min(_triumphs.size(), n)
	for index: int in amount:
		triumphs.append(_triumphs[index])
	return triumphs

func remove_choice(triumph: Triumph) -> void:
	_triumphs.erase(triumph)

func is_empty() -> bool:
	return _triumphs.is_empty()

