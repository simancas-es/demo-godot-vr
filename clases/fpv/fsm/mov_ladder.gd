extends StateBase
const StateBase := FSM_UIDCLASSREF.StateBase

var gc : ControllerBase
var fpv : FPV

@onready var camera : FPVCamera = %Camera3D
@onready var area_ladder = (%LadderCheck) ##Ladder check
@onready var state_movphysics = %mov_physics

func enter() -> void:
	fpv.velocity = Vector3.ZERO
	
	
##Check for ladders to change state
func is_atleast_one_ladder(array : Array[Area3D]) -> bool:
	if array.size() > 0:
		for _area_collision in array:
			if _area_collision is Ladder:
				var angle = UTILS.get_angle_between_forward_vectors(fpv, _area_collision)
				if angle < deg_to_rad(90) or angle >(deg_to_rad(150)):
					return true
	return false
	
	

##Gets the angle with respect to the direction of the ladder.
##TODO For now assume all ladders go only upwards +Y
func get_looking_angle_degrees(_fpv : FPV) -> float:
	var forward = -camera.global_transform.basis.z.normalized()
	var horizontal_forward = Vector3(forward.x, 0.0, forward.z).normalized()
	
	# Angle between full forward and horizontal projection
	var angle_rad = forward.angle_to(horizontal_forward)

	if forward.y < 0:
		angle_rad *= -1
	return rad_to_deg(angle_rad)
	
	
var movedir : Vector3 = Vector3.ZERO
var ladder_check_overlapping_areas : Array[Area3D]

##a=move_forward : float, b=cosinefw : float, c=looks_up : float
##Ints must be -1 or 1
static func get_upwards_factor(a: int, b : int, c : int) -> int:
	return int(2 * ((1 + a) * (1 + b) / 4 + (1 - a) * (1 - b) * (1 + c) / 8) - 1)

##Moves up and down
func process_physics(_delta : float) -> StateBase:
	movedir = gc.movedir #No need to rotate it.rotated(Vector3(0, 1, 0), fpv.rotation.y)
	
	#Check for ladders
	ladder_check_overlapping_areas = area_ladder.get_overlapping_areas()
	if not is_atleast_one_ladder(ladder_check_overlapping_areas):
		return state_movphysics
	
	##TODO Not deterministic
	var _first_ladder = ladder_check_overlapping_areas[0]
	var cos_forward = UTILS.get_cosine_two_forwards(fpv, _first_ladder)
	##If 1: fpv looking away from ladder = Same direction as ladder front
	## If -1: fpv looking towards ladder front
	
	var angle_degrees = get_looking_angle_degrees(fpv)
	var looking_up_direction = 2*float(angle_degrees < 45) - 1
	##cos fw1: s: up, w: down
	##cos fw-1: s: down, w : looking_up
	if cos_forward > 0: #Looking away from the ladder
		fpv.velocity.y = movedir.z * fpv.SPEED
	elif looking_up_direction > 0: #Looking towards the ladder
		fpv.velocity.y = looking_up_direction * -movedir.z * fpv.SPEED
	else:
		fpv.velocity.y = -looking_up_direction * abs(movedir.z) * fpv.SPEED
			
	fpv.move_and_slide()
	
	if fpv.is_on_floor() and fpv.get_real_velocity() == Vector3.ZERO:
		if abs(movedir.z) > 0 : return state_movphysics #Wants to leave the stairs
	
	return null
	
	
