@tool
extends XRToolsPickable

@onready var sniper_handle : XRToolsInteractableHandle = $body/FirearmSlide/HandleOrigin/InteractableHandle

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()

	# Disable by default
	sniper_handle.enabled = false


func _on_picked_up(_pickable):
	# Enable on pickup
	sniper_handle.enabled = true


func _on_dropped(_pickable):
	# Disable on drop
	sniper_handle.enabled = false
