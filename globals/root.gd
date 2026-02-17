extends Node
class_name GameRoot

var current_scene : Node = null
#@export var start_button : Button
#@export var canvas : MenuManager

@export var state_machine_menus : StateMachineMenus

@onready var debug_label_state = %DebugStateText

func init_root():
	#Clean Slate
	if current_scene != null:
		current_scene.call_deferred("queue_free")
		
		
func _ready():
		
	#Check if there is a VR headset
	var xrstart : XRToolsStartXR = $StartXR
	#if xrstart.xr_interface:
	if xrstart.xr_interface:
		state_machine_menus.starting_state = $StateMachine/InVR
	#else:
		#xrstart.queue_free()
	state_machine_menus.init(self)
	#if get_tree().current_scene :
		#_on_introscreen()

	
func change_environment(id : ENVIRONMENTS.ID) -> BaseZone:
	var scene = Cache.get_environment(id)
	if scene == null:
		scene = await Cache.load_environment(id)
	
	#TODO REFACTOR
	if scene is BaseZone:
		scene.ENV_ID = id
			
	await load_environment(scene)
	return scene



func _process(delta : float):
	state_machine_menus.process_frame(delta)
	if debug_label_state: debug_label_state.text = "State: %s  - Topic: %s" % [state_machine_menus.current_state.name, GameState._current_topic]
#func _physics_process(delta: float) -> void:
	#state_machine_menus.process_physics(delta)
	
func _input(event: InputEvent) -> void:
	state_machine_menus.process_input(event)

##Pauses the current_scene in the Root object. Menus are not direct children
## so they aren't affected.
func pause_game(pause : bool) -> void:
	if current_scene == null : return
	
	if pause and current_scene.process_mode == current_scene.PROCESS_MODE_INHERIT:
		current_scene.process_mode = current_scene.PROCESS_MODE_DISABLED
	
	elif !pause and current_scene.process_mode == current_scene.PROCESS_MODE_DISABLED:
		current_scene.process_mode = current_scene.PROCESS_MODE_INHERIT


func load_environment(environment : Node):
	"""Loads the environment into the current scene AKA Zone."""
	if current_scene != null:
		remove_child(current_scene)
		current_scene.set_process(false)
	current_scene = environment
	# Add the next level
	current_scene.set_process(true)
	#current_scene.request_ready()
	add_child(current_scene)
	
	#entry animation

func exit_game() -> void:
	get_tree().quit()
		

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()
