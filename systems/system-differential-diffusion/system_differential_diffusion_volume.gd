extends Node
class_name SystemDifferentialDiffusionVolume

signal changed_values #Controller will listen to this
signal updated_concentration(value : float) #Not listened to by controller

#Concentration doesnt trigger the changed values signal
##Use set_concentration to change this. TODO Read only with get
var current_concentration : float = 0.0: # Units/m3. Current concentration. ##DO NOT SET MANUALLY. Use set_concentration
	set(value):
		current_concentration = value
		updated_concentration.emit(value)


@export var current_diffusivity = SYSTEMDIFFERENTIALDIFFUSIONSETTINGS.DEFAULT_DIFFUSIVITY:#m2/s. Accounts for turbulence at edges.
	set(value):
		current_diffusivity = value
		changed_values.emit() 
@export var current_generation = 0.0: #Generation in volume. Units/m3/second
	set(value):
		current_generation = value
		changed_values.emit() 		
@export var volume : float = 1.0: # m3 Volume of control
	set(value):
		volume = value
		changed_values.emit()
		
var connections : Array[SystemDifferentialDiffusionVolume] = [] #Other control volumes linked to this one
var _areas : Array[float] = [] #m2. Interface area to other volumes. Same index.
var _distances : Array[float] = [] #m. Distance from volume1 to volume 2


func _init(init_concentration : float = 0.0,
			init_volume_m3 : float = 1.0,
			init_generation_udm3s : float = 0.0,
			init_diffusivity_m2s : float = SYSTEMDIFFERENTIALDIFFUSIONSETTINGS.DEFAULT_DIFFUSIVITY) -> void:
	current_concentration = init_concentration
	volume = init_volume_m3
	current_generation = init_generation_udm3s
	current_diffusivity = init_diffusivity_m2s
	
##Use this function to set concentration. This emits the changed parameter value
func set_concentration(concentration_ : float, emits_signal : bool = false) -> void:
	current_concentration = concentration_
	if emits_signal: changed_values.emit()	

func _ready() -> void:
	add_to_group(SYSTEMDIFFERENTIALDIFFUSIONSETTINGS.GROUP_LABEL)
	pass

##Adds volume 1 and volume 2 to each other lists of connections
static func join_volumes(vol1 : SystemDifferentialDiffusionVolume, vol2 : SystemDifferentialDiffusionVolume, area : float, distance : float) -> void:
	if not (vol2 in vol1.connections):
		vol1.connections.append(vol2)
		vol1._areas.append(area)
		vol1._distances.append(distance)		
		vol1.changed_values.emit()
	if not (vol1 in vol2.connections):
		vol2.connections.append(vol1)
		vol2._areas.append(area)
		vol2._distances.append(distance)
		vol2.changed_values.emit()
	
	pass
