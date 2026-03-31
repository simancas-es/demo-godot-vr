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
static func is_atleast_one_ladder(array : Array[Area3D], fpv_ : Node3D) -> bool:
    if array.size() > 0:
        for _area_collision in array:
            if _area_collision is Ladder:
                var angle := UTILS.get_angle_between_forward_vectors(fpv_, _area_collision)
                if not((angle < deg_to_rad(_area_collision.minimum_horizontal_angle)) or (angle > (deg_to_rad(150))) ):
                    return false
                #Is the player behind the ladder?
                var V := fpv_.global_transform.origin - _area_collision.global_transform.origin
                V.y = 0
                var cos_positioning := _area_collision.global_transform.basis.z.normalized().dot(V)
                if (cos_positioning > 0) and (not _area_collision.allowed_from_behind):
                    return false
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

func is_moving_away_from_ladder(fpv: Node3D, ladder: Node3D, movedir_z: float) -> bool:
    #var cos := UTILS.get_horizontal_cos_to_node2(fpv, ladder)
    #return (cos < 0 and movedir_z > 0) or (cos > 0 and movedir_z < 0)
    var dist : float = fpv.global_position.z - ladder.global_position.z
    return (sign(dist) == sign(movedir_z))
    #Positive distance -> player higher than ladder in z axis, forward = negative z, closes distance
    #Negative distance -> player lower than ladder in z axis, forward = negative z, makes distance even bigger.

func is_moving_toward_ladder(fpv: Node3D, ladder: Node3D, movedir_z: float) -> bool:
    var dist : float = fpv.global_position.z - ladder.global_position.z
    return (sign(dist) != sign(movedir_z))
    
    
var movedir : Vector3 = Vector3.ZERO
var ladder_check_overlapping_areas : Array[Area3D]

##a=move_forward : float, b=cosinefw : float, c=looks_up : float
##Ints must be -1 or 1
static func get_upwards_factor(a: int, b : int, c : int) -> int:
    return int(2 * ((1 + a) * (1 + b) / 4 + (1 - a) * (1 - b) * (1 + c) / 8) - 1)

##Moves up and down
func process_physics(_delta : float) -> StateBase:
    movedir = gc.movedir #No need to rotate it.rotated(Vector3(0, 1, 0), fpv.rotation.y)
    if movedir == Vector3.ZERO : return null
    
    #Check for ladders
    ladder_check_overlapping_areas = area_ladder.get_overlapping_areas()
    if not is_atleast_one_ladder(ladder_check_overlapping_areas, fpv):
        return state_movphysics
    
    ##TODO Not deterministic
    var _first_ladder : Ladder = ladder_check_overlapping_areas[0]
    var cos_forward := UTILS.get_cosine_two_forwards(fpv, _first_ladder)
    ##If 1: fpv looking away from ladder = Same direction as ladder front
    ## If -1: fpv looking in the direction opposite to ladder Z vector, back to the ladder.
    
    if not _first_ladder.allowed_backwards: movedir.z = min(0, movedir.z) # -z is forward for the fpv
        
    var angle_degrees = get_looking_angle_degrees(fpv)
    var looking_up_direction = 2*float(angle_degrees > 0) - 1
            
    ##cos fw1: s: up, w: down
    ##cos fw-1: s: down, w : looking_up
    if cos_forward > 0: #Player Z and ladder Z are aligned
        fpv.velocity.y = movedir.z * fpv.SPEED
    elif cos_forward <0:
        if looking_up_direction > 0: #Looking towards the ladder
            fpv.velocity.y = looking_up_direction * -movedir.z * fpv.SPEED
        else:
            fpv.velocity.y = -looking_up_direction * abs(movedir.z) * fpv.SPEED
    
   
            
    fpv.move_and_slide()
    
    if fpv.is_on_floor() and fpv.get_real_velocity() == Vector3.ZERO:
        return state_movphysics
    if is_moving_away_from_ladder(fpv, _first_ladder, movedir.z):
        return state_movphysics
    
    return null
    
    
