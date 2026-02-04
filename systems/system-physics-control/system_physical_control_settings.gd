extends Node
class_name SYSTEMPHYSICALCONTROLSETTINGS

#Full URL to scenes.
const GRAB_AVAILABLE_ICON : PackedScene = preload("uid://bfeweum4tuf81")
const GRAB_ACTIVATED_ICON : PackedScene = preload("uid://dpguvlxb6iavg")


const ACTION_GRAB_NAME : String = "grab"
const ACTION_SEND_FURTHER : String = "system_physics_control_further" 
const ACTION_SEND_CLOSER : String = "system_physics_control_closer"

const ACTION_MOVE_UP : String = "ui_up"
const ACTION_MOVE_DOWN : String = "ui_down"
const ACTION_MOVE_LEFT : String = "ui_left"
const ACTION_MOVE_RIGHT : String = "ui_right"

const DEFAULT_MAX_DISTANCE_GRAB : float = 2.5 #Meters to grab

#Physics layers
const COLLISION_LAYER : int = ENUMS.COLLISION_LAYER.SYSTEMPHYSICALCONTROL
const LAYER_WALLS : int =  ENUMS.COLLISION_LAYER.WALLS
const LAYER_FLOOR : int = ENUMS.COLLISION_LAYER.FLOOR
const LAYER_FPVPLAYER : int = ENUMS.COLLISION_LAYER.FPVPLAYER

##Grabber collision mask (Player)
#Grabable items will have these bits set to true in the collision layer and mask.
const OTHER_COLLISION_LAYER_MASK : int = LAYER_FLOOR + LAYER_WALLS + LAYER_FPVPLAYER + 0
