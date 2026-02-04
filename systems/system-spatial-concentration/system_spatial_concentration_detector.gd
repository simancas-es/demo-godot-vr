@tool
extends Node3D
class_name SystemSpatialConcentrationDetector

@export var concentration_type : SYSTEMSPATIALCONCENTRATIONSETTINGS.TYPE = SYSTEMSPATIALCONCENTRATIONSETTINGS.TYPE.DEFAULT ##Kind of concentration. Not used

var concentration_nodes : Array[SystemSpatialConcentrationSource] = []
var current_concentration : float = 0.0

func _ready() -> void:
	#_init_detector_shape()
	init_concentration_nodes()
	scan_concentration()


func init_concentration_nodes() -> void:
	concentration_nodes = []
	var nodes = get_tree().get_nodes_in_group(SYSTEMSPATIALCONCENTRATIONSETTINGS.BASE_GROUP)
	for n in nodes:
		var nt : SystemSpatialConcentrationSource = n
		if nt.concentration_type != concentration_type: continue
		concentration_nodes.append(n) #TODO Possible bug if new items come into the scene.
		

func scan_concentration() -> void: #Takes highest concentration
	var current_conc = SystemSpatialConcentrationSource.get_max_concentration(concentration_nodes, self)
	current_concentration = current_conc
