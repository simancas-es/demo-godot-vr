extends Node3D
#empty
var root : GameRoot
@onready var hingeddoor : Node3D = $HingedDoor

func _ready() -> void:
	root = get_tree().current_scene
	root.updated.connect(check_xr)
	check_xr()
	
func check_xr() -> void:
	if root is GameRoot:
		if not root.is_xr():
			if (hingeddoor != null) :
				hingeddoor.queue_free()
				return
		else:
			var t = $"Door2m"
			if (t != null) and not t.is_queued_for_deletion() : t.queue_free()
	pass
