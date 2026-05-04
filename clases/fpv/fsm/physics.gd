extends StateBase
const StateBase := FSM_UIDCLASSREF.StateBase
const StateMachineBase := FSM_UIDCLASSREF.StateMachineBase

var gc : ControllerBase

const MovLadder := preload("uid://cknc20whxaqec")

@onready var camera : FPVCamera = %Camera3D
@onready var raycast_center = %RayCast3D
@onready var raycast_fixed = (%Camera3D).raycast_fixed
@onready var center_aim_x = (%Camera3D).center_aim_x
#@onready var area_check = (%AreaCheck)

@onready var area_ladder = (%LadderCheck) ##Ladder check. Scans the ladder layer.
@onready var state_movladder = %mov_ladder 

@onready var il : FPVInteractionLogic = %InteractionLogic
var fpv : FPV

@onready var state_env : StateBase = %Environment
@onready var fsm_ix : StateMachineBase = %StateMachineInteraction

enum SUBSTATE {STANDING, CROUCHING}
var current_substate = SUBSTATE.STANDING

func enter() -> void:
	fpv.velocity = Vector3.ZERO
	return
	
##Check for ladders to change state
func is_looking_at_ladder(area : Area3D) -> bool:
	if area is Ladder:
		##Check if its looking at it
		var angle_deg = rad_to_deg(UTILS.get_angle_between_forward_vectors(fpv, area))
		if angle_deg < (30):
			return true
	return false
	
func is_moving_toward_ladder(fpv: Node3D, ladder: Node3D, movedir_z: float) -> bool:
	var dist : float = fpv.global_position.z - ladder.global_position.z
	return (sign(dist) != sign(movedir_z))
	#Positive distance -> player higher than ladder in z axis, forward = negative z, closes distance
	#Negative distance -> player lower than ladder in z axis, forward = negative z, makes distance even bigger.
	
#---------------PHYSICS MOVEMENT--------------

#Tweak constants
const GRAV = 9.8 

#JUMPING.
#Max height = 1/2 v2/g
const JUMP_VELOCITY_MAX = 4.5 # Max jump speed
const JUMP_VELOCITY_MIN = 3.5 
const JUMP_TIME = 0.2 #TIME from a weak jump to a big jump
var jump_buildup_s = 0.0 #buildup time between 0.0 to JUMP_TIME
##How much of the jump velocity you get
func jumping_vel(total_s : float) -> float:
	return lerp(JUMP_VELOCITY_MIN, JUMP_VELOCITY_MAX, total_s/JUMP_TIME)

const MAX_SPEED = 7
const MAX_SPEED_TIME = 0.7 #Time sprinting to max speed
var fraction_gap = 0.0 #Fraction of the gap between SPEED and MAX_SPEED
var current_speed = 0.0 #Current speed

##Falling controls
const FALLING_SPEED = 2.0
const FALLING_SPEED_TIME = 0.5 #Seconds from SPEED to falling speed
var falling_time_s = 0.0 #Time falling already
const TIME_TO_TURN_FALLING = 3 #Time s to change direction while in the air

#Calculation variables
var movedir : Vector3 = Vector3.ZERO
var bobbing_track_s : float = 0.0
var converge_bob_to_zero : bool = false
var velocity_len : float

var ladder_check_overlapping_areas : Array[Area3D]
func process_physics(delta: float) -> StateBase:
	if !fpv : return null
	#if fsm_ix.current_state != state_env: return #Not needed
	
	camera.position = Vector3.ZERO #BUG 
	movedir = gc.get_movement_direction().rotated(Vector3(0, 1, 0), fpv.rotation.y)
	
	#Check for ladders
	ladder_check_overlapping_areas = area_ladder.get_overlapping_areas()
	if ladder_check_overlapping_areas.size() > 0:
		var ladder_check := MovLadder.is_atleast_one_ladder(ladder_check_overlapping_areas, fpv) #HACK
		if ladder_check:
			for _area_collision in ladder_check_overlapping_areas:
				if not (_area_collision is Ladder): continue
				if is_moving_toward_ladder(fpv, _area_collision, movedir.z) or fpv.velocity.y < 0:
					return state_movladder
			#//End check for ladders
	
	if not fpv.is_on_floor():
		fpv.velocity.y -= GRAV * delta
		fpv.velocity.y = clampf(fpv.velocity.y, -20, 200)
		
	if gc.is_jump_pressed() and fpv.is_on_floor():
		jump_buildup_s = clampf(jump_buildup_s + delta, 0.0, JUMP_TIME)

	if (jump_buildup_s > 0) and (not gc.is_jump_pressed() or jump_buildup_s >= JUMP_TIME):
		fpv.velocity.y = jumping_vel(jump_buildup_s)
		jump_buildup_s = 0.0
	
	if fpv.is_on_floor():
		if gc.is_sprint_pressed(): #TODO Lateral movementt
			#Tweak time to max		
			fraction_gap = min(1, fraction_gap + delta/MAX_SPEED_TIME) 
		else:
			fraction_gap = max(0, fraction_gap - delta/MAX_SPEED_TIME)
		
		current_speed = fpv.SPEED + fraction_gap * (MAX_SPEED - fpv.SPEED)	
		fpv.velocity.x = current_speed * movedir.x
		fpv.velocity.z = current_speed * movedir.z
		
	else: #not on the floor. BUG Velocity spikes up to a million
		falling_time_s += delta
		current_speed = max(FALLING_SPEED, current_speed - (fpv.SPEED - FALLING_SPEED)/FALLING_SPEED_TIME*delta)
		fpv.velocity.x = lerp(fpv.velocity.x, movedir.x * current_speed, min(1.0, falling_time_s/TIME_TO_TURN_FALLING)) #TODO BUG Wrong eq
		fpv.velocity.z = lerp(fpv.velocity.z, movedir.z * current_speed, min(1.0, falling_time_s/TIME_TO_TURN_FALLING))
	

	
	#This allows doors not to push it. see explanation below.
	#Required to also set the collision_layer to the collision_layer of the door.
	if not fpv.velocity.is_zero_approx(): 
		#Correction
		fpv.move_and_slide()
		#fpv.move_and_collide(fpv.velocity * delta) #Doesnt wor
		
	#fpv.max_slides = 0 #Doesn't work
	#move and slide: When the body touches a moving platform, the platform's velocity is automatically
 	#added to the body motion. If a collision occurs due to the platform's motion,
 	#it will always be first in the slide collisions.
	
	
	var real_vel = fpv.get_real_velocity()
	if abs(real_vel.y) < 0.01: fpv.velocity.y = 0.0
	#
	#if fpv.is_on_wall():
		#var wall_collision = fpv.get_wall_normal()
		#if (real_vel.length_squared() < 0.5):
			#fpv.global_position = fpv.global_position + wall_collision * delta
		
	#Moving camera up and down as we also move to simulate steps
	converge_bob_to_zero = (real_vel.length_squared() < 0.5)
	velocity_len = fpv.velocity.length()
	#print(("Wall %s, floor %s, vel target %s, vel real %s, get collisions %s" %
			#[fpv.is_on_wall(), fpv.is_on_floor(), fpv.velocity, fpv.get_real_velocity(), fpv.get_slide_collision_count()]))
	if fpv.is_on_floor():	
		if converge_bob_to_zero: ##Go down even if standing still until it converged.
			if calc_bobbing(bobbing_track_s).length_squared() < 0.1:
				pass
			else:
				bobbing_track_s += delta * fpv.velocity.length() ##Cycles
				camera.position += calc_bobbing(bobbing_track_s) * int(fpv.velocity.length_squared()>0.4)
		else:
			bobbing_track_s += delta * fpv.velocity.length() ##Cycles
			camera.position += calc_bobbing(bobbing_track_s)
	
	return null

const BOBBING_FREQ = 1.0
const BOBBING_AMP = 0.03
var bob_vec : Vector3 = Vector3.ZERO
func calc_bobbing(time_s : float) -> Vector3:
	bob_vec.y = sin(time_s * BOBBING_FREQ) * BOBBING_AMP
	return bob_vec


##---------CROUCHING
const crouching_time_down_s : float = 0.1 #Seconds to crouch
var standing_h_m : float = fpv.camera_base_height_m
var crouching_h_m : float = fpv.camera_crouch_height_m
##Changes between crouching and standing
func process_frame(delta : float) -> StateBase:
	var current_h = fpv.camerabaseposition.position.y
	if (current_h > crouching_h_m) and gc.is_crouch_pressed():
		#Start crouching: camera lowers, when at the end, new shape
		fpv.camerabaseposition.position.y -= (standing_h_m - crouching_h_m)/ crouching_time_down_s * delta
		pass
	
	#If stopped crouching
	elif (current_h < standing_h_m) and (not gc.is_crouch_pressed()):
		#Check that there is room above
		#TODO
		#Move upwards
		if true:
			fpv.camerabaseposition.position.y += (standing_h_m - crouching_h_m)/ crouching_time_down_s * delta
		
		pass
	
	fpv.camerabaseposition.position.y = clampf(fpv.camerabaseposition.position.y, crouching_h_m, standing_h_m)

	return null
