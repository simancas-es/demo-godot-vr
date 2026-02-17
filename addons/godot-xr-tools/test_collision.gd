extends Node
#Checks that none of the items in the demo have layers set that could collide with the external layers

@export var forbidden_layers = XR_LAYER_SETTINGS.EXTERNAL_LAYERS

func init(layers : Array[int]): #Initializes the thing
	forbidden_layers = layers

func _ready() -> void:
	test_collision_layer_checker()
	check_scene_collision_layers()
	
func test_collision_layer_checker() -> void:
	# Step 1: Create a CollisionLayerChecker instance
	var checker = get_script().new()
	checker.init([2, 3] as Array[int]) # forbid layers 2 and 3

	# Step 2: Create dummy collision objects
	var obj1 := StaticBody3D.new()
	obj1.name = "AllowedObject"
	obj1.collision_layer = 1 << (1-1) # layer 1  allowed

	var obj2 := StaticBody3D.new()
	obj2.name = "ForbiddenObject1"
	obj2.collision_layer = 1 << (2-1) # layer 2  forbidden

	var obj3 := Area3D.new()
	obj3.name = "ForbiddenObject2"
	obj3.collision_layer = 1 << (3-1) # layer 3  forbidden

	# Step 3: Add objects to the scene tree temporarily
	add_child(obj1)
	add_child(obj2)
	add_child(obj3)

	# Step 4: Run the check
	var mask = forbidden_mask([2,3] as Array[int])
	assert(not is_layer_colliding(obj1, mask))
	assert(is_layer_colliding(obj2, mask))
	assert(is_layer_colliding(obj3, mask))


	# Step 5: Clean up
	obj1.queue_free()
	obj2.queue_free()
	obj3.queue_free()
	
	print("TestCollision: Test passed")
	

# Converts array of bit indices to a mask
static func forbidden_mask(array : Array[int]) -> int:
	var mask := 0
	for bit_idx in array:
		mask |= 1 << (bit_idx - 1) # Godot bits are 1<<0, 1<<1, ...
	return mask
	
static func is_layer_colliding(node : Node, forbidden_bits : int) -> bool:
		var layer : int = node.collision_layer
		if layer & forbidden_bits != 0:
			return true
		return false

static func get_all_children_recursive(node: Node) -> Array:
	var all_nodes := []
	for child in node.get_children():
		all_nodes.append(child)
		all_nodes += get_all_children_recursive(child) # recursive call
	return all_nodes

static func layer_to_binary_str(layer: int) -> String:
	var s = ""
	for i in range(31, -1, -1):  # Check each bit from high to low
		s += str((layer >> i) & 1)
	# Remove leading zeros for clean output
	s = s.lstrip("0")
	if s == "":
		s = "0"
	return s
	
	
func check_scene_collision_layers() -> void:
	var mask := forbidden_mask(forbidden_layers)
	# Get all nodes recursively
	var nodes = get_all_children_recursive(get_tree().get_root()) #HACK, waste of Array
	for node in nodes:
		if not node is CollisionObject3D: continue
		if not is_layer_colliding(node, mask): continue
		var layer : int = node.collision_layer
		# Node has a forbidden collision bit
		var scene_name := ""
		if "filename" in node:
			scene_name = node.filename
		push_warning("Forbidden layer detected! Node class: %s Node name: %s ... Scene: %s ... Layer mask: 0b%s" %
						[node.get_class(), node.name, scene_name, layer_to_binary_str(layer)])
