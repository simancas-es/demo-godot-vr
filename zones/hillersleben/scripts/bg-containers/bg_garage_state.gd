extends Resource
class_name HL_GarageState

enum DoorState { OPEN, CLOSED, OPENING, CLOSING }
enum ContainerState { INSIDE, OUTSIDE, INBETWEEN, MOVING_IN, MOVING_OUT }

@export var door_state : DoorState = DoorState.CLOSED
@export var door_requested_open: bool = false
@export var door_requested_close: bool = false

# Array of container states, one per container
@export var container_states : Array[ContainerState] = []  # [ContainerState, ContainerState, ...]

# Request flags, also arrays
@export var container_requested_in : Array = []
@export var container_requested_out : Array = []
