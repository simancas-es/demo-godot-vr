extends SystemPhysicalControlGrabber

var parent : FPV

func _ready() -> void:
	super()
	##highjack gc camera and movement on grabbing stationary	
	grabbed_stationary.connect(on_grabbed_stationary)
	stopped_grabbing.connect(on_stopped_grabbing)
	
	parent = get_parent()
	parent.ready.connect(init_from_fpv)
	pass
	
func init_from_fpv() -> void:
	init(parent.get_camera())

func on_grabbed_stationary() -> void:
	var gc = parent.gc
	gc.disable_movement()
	pass
	
func on_stopped_grabbing() -> void:
	var gc = parent.gc
	gc.enable_movement()
	pass
