extends Node
##ControllerManager
var gcs : Array[ControllerBase]
var i : int = 0

func _init() -> void:
	var gc = ControllerKB1.new()
	add_child(gc)
	gcs.append(gc)
	
##Enables or disables all controls
func enable_ctrls(enable_ : bool) -> void:
	for gc in gcs:
		gc.enable(enable_)

##TODO Controller assignment?
func get_next_controller() -> ControllerBase:
	return gcs[i]
