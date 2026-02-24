extends Node
const GarageState = preload("uid://d2x1a26haj0vt")
const GarageSystem = preload("uid://b6e83lkv2jy1t")
const DoorController = preload("uid://jgo7k1ecvdjx")
const ContainerController = preload("uid://dfx637qtcm1wm")

# --- State & system ---
@export var state : GarageState = GarageState.new()
@export var system : GarageSystem = GarageSystem.new()

# --- Door ---
@export var door_controller : DoorController

# --- Containers ---
@export var container_controllers : Array[ContainerController] = []

# --- Buttons ---
@export var container_out_buttons : Array[MachineToggleable] = []
@export var container_in_buttons : Array[MachineToggleable] = []
@export var halt_buttons : Array[MachineToggleable] = []
@export var door_button : MachineToggleable

func _ready() -> void:
	if state == null or system == null:
		push_error("GarageController: state or system not assigned!")
		return
	
	system.state = state
	add_child(system)
	
	# Ensure arrays match number of containers
	if container_controllers.size() != state.container_states.size():
		push_error("ContainerControllers array must match container_states array length!")
		return
	if container_out_buttons.size() != state.container_states.size() or container_in_buttons.size() != state.container_states.size():
		push_error("Button arrays must match container count!")
		return

	# Inject state & system into controllers
	door_controller.state = state
	door_controller.system = system
	door_controller.init()
	if door_button:
		door_button.turned_on.connect(_on_door_button_on)	
		door_button.turned_off.connect(_on_door_button_off)
		
	for i in range(container_controllers.size()):
		container_controllers[i].state = state
		container_controllers[i].system = system
		container_controllers[i].container_index = i
		container_controllers[i].init()
	
	var num_conts = state.container_states.size()
	state.container_requested_out.resize(num_conts)
	state.container_requested_in.resize(num_conts)

	for i in range(num_conts):
		state.container_requested_out[i] = false
		state.container_requested_in[i] = false

	# Connect button signals
	for i in range(state.container_states.size()):
		if container_out_buttons[i]:
			container_out_buttons[i].turned_on.connect(	_on_container_out_pressed.bind(i))
		if container_in_buttons[i]:
			container_in_buttons[i].turned_on.connect(_on_container_in_pressed.bind(i))
		if halt_buttons[i]:
			halt_buttons[i].turned_on.connect(_on_halt_button_pressed.bind(i))

	# Start system processing
	set_process(true)
	
func _on_door_button_on() -> void:
	state.door_requested_open = true
func _on_door_button_off() -> void:
	state.door_requested_close = true
	
func _on_container_out_pressed(index: int) -> void:
	state.container_requested_out[index] = true
	
func _on_container_in_pressed(index: int) -> void:
	state.container_requested_in[index] = true
	
func _on_halt_button_pressed(index: int) -> void:
	if container_controllers[index]._moving:
		#container_controllers[index]._moving = false
		container_controllers[index]._goal = container_controllers[index]._progress
		
		

func _process(delta: float) -> void:
	system.step(delta)
