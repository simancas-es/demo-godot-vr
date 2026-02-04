extends Resource
#class_name BasinState

# Tank
@export var water_volume: float = 0.0
@export var max_volume: float = 10.0

# Valve control
@export var valve_fraction: float = 0.5 # 0..1

# Blower targets
@export var blower_target_on : Array[bool] = []
@export var safety_blower_volume_fraction = 0.1 # Under this water volume fraction it cant turn on

# Aerator status
@export var aerator_ok : Array[bool] = []
