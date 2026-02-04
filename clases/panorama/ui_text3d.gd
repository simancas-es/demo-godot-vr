extends Label
class_name UI_TEXT3D

##Text placed on the Panorama2D that ends up looking horizontal or vertical
##when inside a Room360.

##Careful that Transform is set to 0, 0 if it's empty.
##Line text has to fit inside the Rectangle #TODO Bug

##TODO How to implement this effect
enum ORIENTATION {HORIZONTAL, VERTICAL}
@export var oriented : ORIENTATION = ORIENTATION.VERTICAL

func _ready() ->void:
	
	pass

##Generates a label3d reescaled for proportionality and aligned with center view
##L: vertical of panorama, pixels, W : horizontal length
func generate_label3d(baseL : float, baseW : float) -> Label3DFixedsize:
	##Get geometrical informaton
	var rect : Rect2 = self.get_rect()
	var rot_deg = self.rotation_degrees
	
	var l2size = self.size

	var posx2 = rect.position.x + l2size.x*cos(deg_to_rad(rot_deg))
	var posy2 = rect.position.y + l2size.x*sin(deg_to_rad(rot_deg))
	##pos0 center point.
	var pos0 : Vector3 = UTILS.get_polygon_points_3d([position], baseL, baseW)[0]
	var pos1 : Vector3 = UTILS.get_polygon_points_3d([Vector2(posx2, posy2)], baseL, baseW)[0]
	var meter_len : float = (pos1-pos0).length() ##Distance between points.

	
	
	var label3d : Label3DFixedsize = Label3DFixedsize.new(meter_len)
	label3d.text = self.text
	label3d.horizontal_alignment = self.horizontal_alignment
	label3d.vertical_alignment = self.vertical_alignment
	if self.label_settings != null:
		label3d.font = self.label_settings.font
		label3d.outline_size = self.label_settings.outline_size
	else:
		label3d.font = self.get_theme_default_font()
		label3d.outline_size = 0
		
	label3d.fixed_size = true

	var pos_diff = (pos1 - pos0)
	Label3DFixedsize.align_x_basis_to_vector(label3d, pos_diff)
	label3d.position = pos0	
	return label3d

	
###Creates a MeshText instance that correctly follows a spherical shape.
#func get_meshtext() -> MeshInstance3D:
	##TODO
	##Get font points from canvas into 3D space
	##Then generate the mesh TextMesh ?	
	#return null
