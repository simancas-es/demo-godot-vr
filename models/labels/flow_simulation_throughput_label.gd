extends Node3D

const SimulationMain := preload("uid://novqlqgqjj6t")
const Containers = SimulationMain.Simulation.Containers
const Edges = SimulationMain.Simulation.Edges
const SimContainer = SimulationMain.Simulation.Ref.SimContainer
const SimEdge = SimulationMain.Simulation.Ref.SimEdge

@onready var title = $Title	
@onready var stats_vol = $Stats_vol

@export var title_name_en_text : String = "PUMP XXXX" #Translate later automatically

@export var flow_simulation_edge : Edges.ID
@export var flow_simulation_main : SimulationMain = null

const t_current_throughput : String = "Current Throughput: "


func _ready() -> void:
	if title:
		title.text = tr(title_name_en_text)
	set_numbers(0)
	
	#HACK: avoid adding manually, but crashes if not found
	for node in get_tree().get_nodes_in_group("FLOWSIMULATION"):
		if node is SimulationMain:
			flow_simulation_main = node
	
func set_numbers(throughput_m3s : float) -> void:
	if stats_vol:
		if throughput_m3s > 1.0:
			stats_vol.text = tr(t_current_throughput) + "%d m3/s" % throughput_m3s
		else:
			stats_vol.text = tr(t_current_throughput) + "%d L/s" % (throughput_m3s*1000)
		
	pass


func update() -> void:
	if !flow_simulation_main: return
	# Finds the appropiate container and pulls the information
	var edge : SimEdge = flow_simulation_main.sim.es.LIST[flow_simulation_edge]
	var flow : float = edge.throughput
	set_numbers(flow) #Prevent 0
	pass


var update_interval : float = 5.0 # seconds
var time_accum : float = 0.0
func _process(delta: float) -> void: #TODO: Disable when not in view
	if not flow_simulation_main : return
	time_accum += delta
	if time_accum >= update_interval:
		time_accum = 0.0
		update() 
		
		

func update_language() -> void:
	if title: title.text = tr(title_name_en_text)
	update()
##Listen to changes in the locale
func _notification(what):
	if what == NOTIFICATION_TRANSLATION_CHANGED :
		update_language()
