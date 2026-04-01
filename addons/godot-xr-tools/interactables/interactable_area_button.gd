@tool
class_name XRToolsInteractableAreaButton
extends Area3D


## XR Tools Interactable Area Button script
##
## The interactable area button detects objects and areas intering its
## area, and moves an associated button object using a tween to animate
## the movement.


## Button pressed event
signal button_pressed(button)

## Button released event
signal button_released(button)


## Button object
@export var button := NodePath()

## Displacement when pressed
@export var displacement : Vector3 = Vector3(0.0, -0.02, 0.0)
var _displacement_toggle_distance := displacement * 0.5

## Displacement toggled
@export var displacement_toggle : bool = false

## Displacement duration
@export var duration : float = 0.1


## If true, the button is pressed
var pressed : bool = false

## Dictionary of trigger items pressing the button
var _trigger_items := {}

var _tween: Tween

# Node references
@onready var _button: Node3D = get_node(button)

# Button positions
@onready var _button_up := _button.transform.origin
@onready var _button_down := _button_up + displacement
@onready var _button_down_half := _button_up + _displacement_toggle_distance


# Add support for is_xr_class on XRTools classes
func is_xr_class(xr_name:  String) -> bool:
	return xr_name == "XRToolsInteractableAreaButton"


# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect area signals
	if area_entered.connect(_on_button_entered):
		push_error("Unable to connect button area signal")
	if area_exited.connect(_on_button_exited):
		push_error("Unable to connect button area signal")
	if body_entered.connect(_on_button_entered):
		push_error("Unable to connect button area signal")
	if body_exited.connect(_on_button_exited):
		push_error("Unable to connect button area signal")

func _set_button_target(target_pos: Vector3) -> void:
	if _tween:
		_tween.kill()  # stop current tween
	_tween = create_tween()
	_tween.tween_property(_button, "position", target_pos, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	#print("Target pos %s. Button_down %s, button_up %s, button_half %s" % [target_pos, _button_down, _button_up, _button_down_half])
	
# Called when an area or body enters the button area
func _on_button_entered(item: Node3D) -> void:
	if not _trigger_items.is_empty(): return #If something is still inside then its blocking the mechanism
	_trigger_items[item] = item
	
	# Toggle logic
	if displacement_toggle:
		# Toggle buttons: pressing flips state
		_set_button_target(_button_down)		
		pressed = not pressed
		if pressed:
			button_pressed.emit(self)
		#print("Target down, p %s, target: %s" % [pressed, _button_down])
	else:
		# Standard button: pressing always goes down
		if not pressed:
			pressed = true
			_set_button_target(_button_down)
			button_pressed.emit(self)
		
	

# Called when an area or body exits the button area
func _on_button_exited(item: Node3D) -> void:
	_trigger_items.erase(item)

	# Only react if no more triggers
	if _trigger_items.is_empty(): # Can only release if there is nothing pushing
		if displacement_toggle:
			# Bounce-back logic: half or up depending on pressed state
			var target := _button_down_half
			if pressed:
				target = _button_down_half
			else:
				target =_button_up
				button_released.emit(self)
			_set_button_target(target)

			#print("Target up  , p %s, target: %s" % [pressed, target])
		else:
			# Standard button: release to UP
			pressed = false
			_set_button_target(_button_up)
			button_released.emit(self)

# Check button configuration
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()

	# Ensure a button has been specified
	if not get_node_or_null(button):
		warnings.append("Button node to animate must be specified")

	# Ensure a valid duration
	if duration <= 0.0:
		warnings.append("Duration must be a positive number")

	return warnings
