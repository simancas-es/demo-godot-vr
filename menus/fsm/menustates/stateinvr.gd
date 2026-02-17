extends StateMenus
#Making this compatible with VR
#Make it so that it is not possible to go from VR to normal menus, as that would break immersion.



@onready var signals_fs : Dictionary[Signal, Callable] = {
	#Signal : function 
}

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
