@tool
class_name Portal
extends Node3D

const ALLOWED_CLASS := XR_UIDREF.PlayerXROrigin3D

## Type of spawn-point data
enum SpawnDataType {
	## No data provided
	NONE,

	## Name of spawn-point node provided
	NODE_NAME,

	## Vector3 of spawn-point provided
	VECTOR3,

	## Transform3D of spawn-point provided
	TRANSFORM3D
}


## Target scene file
@export_file('*.tscn') var scene : String

## Spawn point data
@export var spawn_data := SpawnDataType.NONE: set = _set_spawn_data

## Can Teleporter be used
@export var active: bool = true: set = _set_active

# Spawn point node-name
var spawn_point_name := ""

# Spawn point position
var spawn_point_position := Vector3.ZERO

# Spawn point transform
var spawn_point_transform := Transform3D.IDENTITY

# Scene base
var _scene_base : XRToolsSceneBase


func _ready():
	_scene_base = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")



# Called when the player enters the teleport area
func _on_TeleportArea_body_entered(body: Node3D):
	# Skip if scene base is not known
	if not _scene_base:
		return

	# Skip if not the player body
	if not body is ALLOWED_CLASS:
		return

	# Skip if not active
	if not active:
		return

	# Teleport
	if scene == "":
		_scene_base.exit_to_main_menu()
	elif spawn_data == SpawnDataType.NODE_NAME:
		_scene_base.load_scene(scene, spawn_point_name)
	elif spawn_data == SpawnDataType.VECTOR3:
		_scene_base.load_scene(scene, spawn_point_position)
	elif spawn_data == SpawnDataType.TRANSFORM3D:
		_scene_base.load_scene(scene, spawn_point_transform)
	else:
		_scene_base.load_scene(scene)


# Provide custom property information
func _get_property_list() -> Array[Dictionary]:
	# Return extra properties
	return [
		{
			name = "Portal",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_GROUP
		},
		{
			name = "spawn_point_name",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT \
					if spawn_data == SpawnDataType.NODE_NAME \
					else PROPERTY_USAGE_NO_EDITOR
		},
		{
			name = "spawn_point_position",
			type = TYPE_VECTOR3,
			usage = PROPERTY_USAGE_DEFAULT \
					if spawn_data == SpawnDataType.VECTOR3 \
					else PROPERTY_USAGE_NO_EDITOR
		},
		{
			name = "spawn_point_transform",
			type = TYPE_TRANSFORM3D,
			usage = PROPERTY_USAGE_DEFAULT \
					if spawn_data == SpawnDataType.TRANSFORM3D \
					else PROPERTY_USAGE_NO_EDITOR
		}
	]


# Allow revert of custom properties
func _property_can_revert(property : StringName) -> bool:
	match property:
		"spawn_point_name":
			return true
		"spawn_point_position":
			return true
		"spawn_point_transform":
			return true
		_:
			return false


# Provide revert values for custom properties
func _property_get_revert(property : StringName): # Variant
	match property:
		"spawn_point_name":
			return ""
		"spawn_point_position":
			return Vector3.ZERO
		"spawn_point_transform":
			return Transform3D.IDENTITY


func set_collision_disabled(p_disable : bool) -> void:
	if Engine.is_editor_hint():
		return

	# Update processing (PROCESS_MODE_DISABLED turns off physics)
	if p_disable:
		process_mode = PROCESS_MODE_DISABLED
	else:
		process_mode = PROCESS_MODE_INHERIT


func _set_spawn_data(p_spawn_data : SpawnDataType) -> void:
	spawn_data = p_spawn_data
	notify_property_list_changed()

func _set_active(value):
	active = value
