extends XR_DOORS_UID_CLASSREF.DoorAPI
const XR_DOORS_UID_CLASSREF = preload("uid://dbtdc5f1qkd3m")

##
## Sliding Door API script
##
## @desc:
##     This script exposes the public API for sliding doors. It contains all the
##     configuration parameters and the public signals the door can emit.
##


## Sliding door linear range
@export var door_range := 1.0

## Sliding door latch position
@export var latch_position := 0.02
