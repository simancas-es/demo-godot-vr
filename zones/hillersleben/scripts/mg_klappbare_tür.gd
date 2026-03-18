extends Node3D
#Folds as the door opens

var original_angle : float
var parent: Node3D

func _ready() -> void:
	parent = get_parent()
	original_angle = parent.rotation.y

	

func _process(delta: float) -> void:
	self.rotation.y =  (original_angle - parent.rotation.y) * 2
