extends Label3D
class_name Label3DFixedsize

var fixed_size_x : float

##Size in  world meters for the x axis
func _init(size_x : float) -> void:
	fixed_size_x = size_x
	self.pixel_size = 0.0005
	pass


func _ready() -> void:
	adjust.call_deferred()
	pass

func adjust() -> void:
	var _noerror = fit_label3dfont(self, fixed_size_x)
	#if not noerror:
		#for i in range(10):
			#self.pixel_size *= i+1
			#noerror = fit_label3dfont(self, fixed_size_x)
	#pass

static func fit_label3dfont(label3d : Label3D, maxsizex : float, fontsize :int = 56) -> bool:
	
	
	var line = TextLine.new()
	line.direction = label3d.text_direction
	line.flags = label3d.justification_flags
	line.alignment = label3d.horizontal_alignment
	line.clear()
	
	var scaling : float
	
	for i in range(1, fontsize):
		line.clear()
		label3d.font_size = i
		var noerror = line.add_string( label3d.text, label3d.font, label3d.font_size )
		if not noerror:
			push_error("Couldn't create Textline...")
			return false
		var linewidth = line.get_line_width()
		var linewidth_m = linewidth * label3d.pixel_size
		var sizediff = maxsizex - linewidth_m
		scaling = sizediff/linewidth_m + 1
		if linewidth_m > maxsizex:			
			##Adjust pixel size
			var pxsize = label3d.pixel_size #m per pixel			
			label3d.pixel_size = pxsize * scaling

			return true
	#Not there yet?
	label3d.scale = Vector3(scaling, scaling, 1)
	
	push_error("Couldn't find a solution with pixel_size ", label3d.pixel_size, " for Text: ", label3d.text)
	return false
		

static func align_x_basis_to_vector(label3d : Node3D, target_vector: Vector3):
	var target_dir = target_vector.normalized()
  # Get current transform
	var t = label3d.transform

	#X basis
	var current_x = t.basis.x

	# Step 1: Rotate around global Y to bring X closer to target direction
	var y_axis = t.basis.y
	var angle_y = current_x.signed_angle_to(target_dir, y_axis)
	t.basis = Basis(y_axis, angle_y) * t.basis

	# Step 2: Recalculate current_x after Y rotation
	current_x = t.basis.x

	# Step 3: Rotate around global Z
	var z_axis = t.basis.z
	var angle_z = current_x.signed_angle_to(target_dir, z_axis)
	t.basis = Basis(z_axis, angle_z) * t.basis

	# Apply the modified transform back
	label3d.transform = t
