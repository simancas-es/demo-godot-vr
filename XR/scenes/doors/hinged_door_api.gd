extends XR_DOORS_UID_CLASSREF.DoorAPI


##
## Hinged Door API script
##
## @desc:
##     This script exposes the public API for hinged doors. It contains all the
##     configuration parameters and the public signals the door can emit.
##


## Minimum angle the door can swing to (0 is closed)
@export var door_minimum_angle := -90.0 # (float, -180.0, 180.0, 1.0)

## Maximum angle the door can swing to (0 is closed)
@export var door_maximum_angle := 0.0 # (float, -180.0, 180.0, 1.0)

## Minium angle the door handle can swing to (0 is flat)
@export var handle_minimum_angle := 0.0 # (float, -180.0, 180.0, 1.0)

## Maximum angle the door handle can swing to (0 is flat)
@export var handle_maximum_angle := 70.0 # (float, -180.0, 180.0, 1.0)

## Unsigned door handle angle to open the door
@export var handle_open_angle := 40.0 # (float, 0.0, 180.0, 1.0)

## Unsigned door angle to latch the door
@export var latch_angle := 3.0 # (float, 0.0, 180.0, 1.0)
