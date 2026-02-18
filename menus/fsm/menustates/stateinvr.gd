extends StateMenus
#Making this compatible with VR
#Make it so that it is not possible to go from VR to normal menus, as that would break immersion.



@onready var signals_fs : Dictionary[Signal, Callable] = {
	#Signal : function 
}

@export var entry_point : PackedScene = preload("res://XR/demo_staging.tscn")#Default Staging
@export var XR_DEBUG : bool = false
@export var intro_map : PackedScene = preload("res://XR/zones_xr/zone_xr_hochschule.tscn")

func connect_signals() -> void:	
	for s in signals_fs.keys():
		if not s.is_connected(signals_fs[s]):
			s.connect(signals_fs[s])
	pass
	
func disconnect_signals() -> void:
	for s in signals_fs.keys():
		if s.is_connected(signals_fs[s]):
			s.disconnect(signals_fs[s])
	pass

func enter() -> void:
	print("VR: From now on we are inside the VR branch of the program...")
	remove_menus()
	load_staging()
	pass
	
func exit() -> void:
	print("VR: Exiting VR branch...")


func remove_menus() -> void:
	var cl : CanvasLayer = %UI_CanvasLayer
	cl.queue_free()
	
func load_staging() -> void:
	if not entry_point:
		push_error("VR: Missing entry point in InVR state!!!");
		return
	var staging : XRToolsStaging = entry_point.instantiate()
	parent.current_scene = staging
	
	if not XR_DEBUG:
		staging.main_scene = intro_map.resource_path
		
	parent.add_child(staging)
	
	
