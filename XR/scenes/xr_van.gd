extends Node3D

@export_file("*.tscn") var target_scene : String = "res://XR/zones_xr/zone_xr_hochschule.tscn"
@export var labeltext_text : String = "Somewhere!"

func _ready() -> void:
	if target_scene:
		$Portal.scene = target_scene
		$Label3D.text = labeltext_text
