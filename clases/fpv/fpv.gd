class_name FPV extends CharacterBody3D
const StateMachineBase := FSM_UIDCLASSREF.StateMachineBase
const StateBase := FSM_UIDCLASSREF.StateBase
#FPV Object for movement and interaction with the environment.
#Check collision layers.
#Collision 16 is the world as an obstacle

@export_range(0.1, 2.0, 0.1) var sensitivity: float = 1
@export_range(1, 10, 1) var SPEED : float = 4

@onready var interaction_logic : FPVInteractionLogic = %InteractionLogic

@onready var camera: FPVCamera = %Camera3D
@onready var camerabaseposition : Node3D = %CameraBasePosition
const camera_base_height_m : float = 1.7
const camera_crouch_height_m : float = 1.0

@onready var collision_shape_standing : CollisionShape3D = $CollisionShape_Standing
@onready var collision_shape_crouching : CollisionShape3D = $CollisionShape_Crouching

##Game Information
var player_idx : int = 0
var playerdata : PlayerData = null
var inventory : INVENTORY_UIDCLASSREF.Inventory
var gc : ControllerBase
@onready var fsm_ix : StateMachineBase = %StateMachineInteraction
@onready var fsm_mov : StateMachineBase = %StateMachineMovement


@onready var state_fixed : StateBase = %Fixed
@onready var state_room : StateBase = %Room
@onready var state_environment : StateBase = %Environment
@onready var state_falcon : StateBase = %Falcon
@onready var state_nocam_control : StateBase = %SMNotControlled
@onready var state_still : StateBase = %mov_still
@onready var state_physics : StateBase = %mov_physics
@onready var state_ladder : StateBase = %mov_ladder
@onready var state_death : StateBase = %mov_death


#var navregion : NavigationRegion3D = null
#@onready var navagent : NavigationAgent3D = %NavigationAgent3D

##Debug
@onready var testlabel : Label = %Camera3D/TestLabel

signal entered_mode_room(id : ROOMS.ID)
signal entered_mode_env
signal entered_mode_falcon


func _ready() -> void:
	_on_enter_tree()	
	tree_entered.connect(_on_enter_tree)
	tree_exited.connect(_on_exit_tree)
	
	playerdata = GameState.get_player(player_idx)
	camera = %Camera3D
	interaction_logic = %InteractionLogic
	gc = playerdata.get_controller()
	inventory = playerdata.get_inventory() ##TODO: Refactor how they are assigned
	interaction_logic.playerdata = playerdata
	
	for st : StateBase in [state_fixed, state_environment, state_room, 
						state_still, state_physics, state_ladder]:
		st.fpv = self #HACK
		st.gc = gc #HACK
		
	camera.sensitivity = sensitivity
	
	gc.mousewheeldown.connect(camera.mousewheeldown)
	gc.mousewheelup.connect(camera.mousewheelup)
	gc.interact.connect(interaction_logic.interact)
	
	fsm_ix.init()
	fsm_mov.init()
	reset_camera()
	
	
func _on_enter_tree() -> void:
	
	interaction_logic.player_killed_by.connect(on_areacheck_killed_by) #TODO Decouple fsm...
	interaction_logic.sent_room_to_fpv.connect(on_sent_room360)
	pass
	
func _on_exit_tree() -> void:
	interaction_logic.player_killed_by.disconnect(on_areacheck_killed_by)
	interaction_logic.sent_room_to_fpv.disconnect(on_sent_room360)

	pass
	
func get_camera() -> FPVCamera:
	return camera
	
func reset_camera() -> void:
	camera.position = Vector3.ZERO
	camera.rotation = Vector3.ZERO
	camerabaseposition.position = Vector3(0, camera_base_height_m, 0)
	#Physics movement:
	#bobbing_track_s = 0.0
	
func set_background(texture : CompressedTexture2D):
	if texture == null : return
	camera.set_background(texture)

func rotate_sky(angle_rad : float, reset : bool = false) -> void:
	#Rotate the sky in radians. Adds to the rotation
	if not camera.environment:
		push_error("Missing camera environment!! at %s " % self)
		return
	if !reset:
		camera.environment.sky_rotation += Vector3(0, angle_rad, 0)
	if reset:
		camera.environment.sky_rotation = Vector3(0, angle_rad, 0)

func rotate_body_and_camera_to_lookdir(lookdir : Vector2, f: float = 1.0) -> void:
	camera.rotation.x = clamp(camera.rotation.x - lookdir.y * sensitivity * f, -1.5, 1.5)
	rotation.y -= lookdir.x * sensitivity * f
	#Reset
	lookdir = Vector2.ZERO
	#TODO Very interesting bobbing effect if it's set to random small values every frame.
	

func set_mode_panorama() -> void:
	#Locks fpv into place and lets you only rotate.
	#Hits are determined by the ray in the center forward.
	fsm_ix.change_state(state_room)
	fsm_mov.change_state(state_still)

func set_mode_environment() -> void:
	camera.environment = null
	fsm_ix.change_state(state_environment)
	fsm_mov.change_state(state_physics)
	pass
	
func set_mode_fixed(keep_background : bool) -> void:
	if not keep_background:
		camera.environment = load(RESOURCES.CAMERA_NORMAL_SKY)
	fsm_ix.change_state(state_fixed)
	fsm_mov.change_state(state_still)

func set_mode_falcon() -> void:
	fsm_ix.change_state(state_falcon)
	fsm_mov.change_state(state_still)

###Sets a navigation region that will constrain this node3d
###Movement will be only on this region
#func set_navregion(navregion_ : NavigationRegion3D) -> void:
	#navregion = navregion_
	#pass
	#
func on_areacheck_killed_by(bywhat : String) -> void:
	Signals.ui_msg_top.emit(bywhat)
	fsm_mov.change_state(state_death)
	fsm_ix.change_state(state_nocam_control)
	
func on_sent_room360(room360 : Room360) -> void:
	state_room.room360 = room360
	set_mode_panorama()
	
	
	
func activate_movement(activate : bool) -> void:
	if activate:
		fsm_mov.change_state(state_physics)
	else:
		fsm_mov.change_state(state_still)
	pass

func _process(delta: float) -> void:
	fsm_ix.process_frame(delta)
	fsm_mov.process_frame(delta)

func _physics_process(delta: float) -> void:
	fsm_ix.process_physics(delta)
	fsm_mov.process_physics(delta)
#
func _unhandled_input(event: InputEvent) -> void:
	fsm_ix.process_input(event)
	fsm_mov.process_input(event)
