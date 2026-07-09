extends Area3D

#breaks ice

const ICEWEDGE := preload("uid://tkkfmgm7bgqe")

signal found_ice
signal no_ice

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func update_signals() -> void:
	var areas = self.get_overlapping_areas()
	for area in areas:
		if is_instance_of(area, ICEWEDGE) and area.current_state == ICEWEDGE.STATE.NORMAL:
			return
	no_ice.emit()	

func _on_area_entered(area: Node3D) -> void:
	if is_instance_of(area, ICEWEDGE):
		#area.try_break()
		if area.current_state == ICEWEDGE.STATE.NORMAL:
			#stop
			found_ice.emit()
		elif area.current_state == ICEWEDGE.STATE.BROKEN:
			pass
	pass

#Check whether it is still blocked
var time_delta_s : float = 0.0
func _process(delta: float) -> void:
	time_delta_s += delta
	if time_delta_s >= 3.0:
		time_delta_s = 0.0
		update_signals()
