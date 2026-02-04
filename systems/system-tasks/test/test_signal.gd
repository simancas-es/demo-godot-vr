extends MeshInstance3D

signal clicked

signal test_signal
var signal_emitted = false

func _ready() -> void:
	test_signal.connect(func(): signal_emitted = true)
