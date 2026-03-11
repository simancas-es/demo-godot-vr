extends Node3D

const SimulationMain := preload("uid://novqlqgqjj6t")
const Containers = SimulationMain.Simulation.Containers
const SimContainer = SimulationMain.Simulation.Ref.SimContainer

@onready var title = $Title	
@onready var stats_vol = $Stats_vol
@onready var stats_fl = $Stats_fl

@export var title_name_en : String = "BASIN XXXX" #Translate later automatically

@export var flow_simulation_container : Containers.ID
@export var flow_simulation_main : SimulationMain = null

const t_current_volume : String = "Current Volume (m3): "
const t_current_fill_level : String = "Current Fill Level (%): "


func _ready() -> void:
	if title:
		title.text = tr(title_name_en)
	set_numbers(0, 0)
	
func set_numbers(volume, fill_level) -> void:
	if stats_vol:
		stats_vol.text = tr(t_current_volume) + "%d m3" % volume
	
	if stats_fl:
		stats_fl.text = tr(t_current_fill_level) + "%d%%" % fill_level
	pass


func update() -> void:
	# Finds the appropiate container and pulls the information
	var cont : SimContainer = flow_simulation_main.sim.cs.LIST[flow_simulation_container]
	var vol : float = cont.total_volume()
	set_numbers(vol, 100*vol/(cont.max_volume_m3+0.00001)) #Prevent 0
	pass


var update_interval : float = 5.0 # seconds
var time_accum : float = 0.0
func _process(delta: float) -> void: #TODO: Disable when not in view
	time_accum += delta
	if time_accum >= update_interval:
		time_accum = 0.0
		update() 
