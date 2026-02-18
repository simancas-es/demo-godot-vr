extends Label3D

@export var object : CollisionObject3D = null

static func layer_to_binary_str(layer: int) -> String:
	var s = ""
	for i in range(31, -1, -1):  # Check each bit from high to low
		s += str((layer >> i) & 1)
	# Remove leading zeros for clean output
	s = s.lstrip("0")
	if s == "":
		s = "0"
	return s

static func mask_to_bit_indices(mask: int) -> Array[int]:
	var bits: Array[int] = []
	for i in range(32):
		if mask & (1 << i):
			bits.append(i + 1) # 1-based like Godot editor
	return bits

func _process(_delta):
		text = "Name:%s\nLayer: %s\nMask: %s" % [
		object.name,
		mask_to_bit_indices(object.collision_layer),
		mask_to_bit_indices(object.collision_mask)
		]
