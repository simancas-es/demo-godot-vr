extends Node

@onready var xr_ui : XRToolsViewport2DIn3D = $"../pivot/Viewport2Din3D"
const CONTROL := preload("uid://cf711ixjimsdh")

@onready var fpv_mesh = $"../pivot/Sprite3D_Blase/MeshInstance3D"
var root : GameRoot
const DIALOG := preload("uid://go8lcfvxa3df")
var parent : DIALOG

func _ready() -> void:
	root = get_tree().current_scene
	root.updated.connect(check_xr)
	parent = get_parent()
	check_xr()
	
	
	

func check_xr() -> void:
	if root is GameRoot:
		if not root.is_xr():
			if xr_ui and not xr_ui.is_queued_for_deletion(): xr_ui.queue_free(); return
		elif fpv_mesh and not fpv_mesh.is_queued_for_deletion():
			fpv_mesh.queue_free()			
			xr_ui.visible = true
			parent.ready.connect(set_signals)
			
	pass
	
func set_signals() -> void:
	var xr_control = xr_ui.scene_node #HACK TODO: set scene_node from node, not from packedscene.
	parent.set_control(xr_control) #HACK
	parent._apply_text()
