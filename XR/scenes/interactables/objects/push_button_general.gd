extends Node3D
class_name XRToolsInteractablePushbuttonGeneral

@onready var iab : XRToolsInteractableAreaButton = %InteractableAreaButton
@onready var rumbler : XRToolsRumbler = %Rumbler

## Button pressed event
signal button_pressed(button)

## Button released event
signal button_released(button)


@export var rumbles : bool = true
@export var only_once : bool = false

@export var toggle_displacement : bool = false ## Button as toggle


func _ready() -> void:
	if iab == null: return
	iab.displacement_toggle = toggle_displacement
	iab.button_pressed.connect(button_pressed.emit)
	iab.button_released.connect(button_released.emit)
	
	if not rumbles:
		if not rumbler: return
		rumbler.queue_free() #HACK
		

func modulate_color(color : Color) -> void:
	modulate($Button/MeshInstance3D, color)
	
	
static func modulate(meshinstance : MeshInstance3D, color : Color) -> void:
	var mat = meshinstance.get_active_material(0)
	if mat: 
		# If it's a StandardMaterial3D, change the albedo color
		if mat is StandardMaterial3D:
			mat.albedo_color = color
		else:
			print("Material is not a StandardMaterial3D")
	else:
		# If no material exists, create one
		var new_mat = StandardMaterial3D.new()
		new_mat.albedo_color = color
		meshinstance.set_surface_override_material(0, new_mat)
