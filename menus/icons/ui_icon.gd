extends Node2D
class_name UI_ICON

#Allows to quickly select the icon

@export var selected_icon : CompressedTexture2D
@onready var icon_sprite3d : Sprite3D = %Sprite3D
@onready var icon_sprite2d : Sprite2D = %Sprite2D

func _ready() -> void:
	pass
	
func init() -> void:
	if selected_icon != null:
		
		icon_sprite3d.texture = selected_icon
		icon_sprite2d.texture = selected_icon

func generate_sprite3d() -> Sprite3D:
	var sprite3d = Sprite3D.new()
	sprite3d.transparent = true
	sprite3d.no_depth_test = true	
	sprite3d.texture = selected_icon
	sprite3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite3d.scale = Vector3(self.scale.x, self.scale.y, 1)
	return sprite3d

##Gets scale of icons according to panorama
func get_panorama_scale() -> float:
	#if top to bottom is 1x PI. The height has to be proportional too
	var xy : Vector2 = icon_sprite2d.get_rect().size
	var proportion = xy.y / 2/ PI
	
	return proportion
