class_name SignalGroup
extends RefCounted

signal _s(int)

## when one of the signals is emit returns the index
func one(signals: Array) -> int:
	if signals.is_empty():
		return 0
	
	for signal_index: int in signals.size():
		signals[signal_index].connect(_one_s.bind(signal_index), CONNECT_ONE_SHOT)

	var index = await _s

	for signal_index: int in signals.size():
		if signal_index != index:
			signals[signal_index].disconnect(_one_s)
	
	return index

func _one_s(x: int) -> void:
	_s.emit(x)

