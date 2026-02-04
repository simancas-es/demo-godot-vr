extends Node

#Click on the 3D Meshes to change concentrations

@onready var camera : Camera3D = $Camera3D


	
func _ready() -> void:
	assert(test_math())	
	test_grid(25.0)
	
	
func test_math() -> bool:
	var vol1 = SystemDifferentialDiffusionVolume.new(5.0, 1.0, 0.0, 0.05)
	var vol2 = SystemDifferentialDiffusionVolume.new(0.0, 1.0, 0.0, 0.05)
	var vol3 = SystemDifferentialDiffusionVolume.new(6.0, 1.0, 0.0, 0.05)
	
	SystemDifferentialDiffusionVolume.join_volumes(vol1, vol2, 1.0, 1.0)
	SystemDifferentialDiffusionVolume.join_volumes(vol2, vol3, 5.0, 5.0)
	
	var td = SystemDifferentialDiffusionController.get_suggested_time_deltas([vol1, vol2, vol3], 0.25)
	
	var controller = SystemDifferentialDiffusionController.new(td)
	controller.add_volume([vol1, vol2, vol3])
	add_child(controller)
	
	assert(td <= 5.0)
	var lineqs = controller._current_lineq_system
	assert(lineqs[0] == PackedFloat32Array([0.25, -0.05, 0.0]) )
	assert(lineqs[1] == PackedFloat32Array([-0.05, 0.3, -0.05]))
	assert(lineqs[2] == PackedFloat32Array([0.0, -0.05, 0.25]) )
	
	#Measuring calculation time
	var start_time = Time.get_ticks_usec()
		
	var b = controller.get_generated_b()
	var solution : Array[float]
	var cycles := 30
	for n in range(cycles):
		#b = Ca * V/dt + Generated ...		
		#b
		#Forward elimination, back substitution
		solution = controller.solve(b)
		#Concentrations = solution
		print("Test solution should converge at 3.6:", solution)
		b = controller.get_generated_b(solution)
		pass
		
	var end_time = Time.get_ticks_usec()
	var duration_ms = float(end_time - start_time) / 1000.0
	print("Time to calculate %s steps took " % cycles, duration_ms, " ms")
	
	#After 150 seconds the quantities should have converged under the data above
	assert(solution[0] > 3.5)
	assert(solution[1] > 3.5)
	assert(solution[2] > 3.5)
	assert(solution[0]/solution[1] < 1.05)
	assert(solution[1]/solution[2] < 1.05)
	
	stress_test(10)
	stress_test(50)
	stress_test(100)
	
	#React to changes
	print("Lineq before changes: ", controller._current_lineq_system)
	vol1.current_diffusivity *= 1.2
	print("Lineq after changes: ", controller._current_lineq_system)
	vol1.current_diffusivity /= 1.2
	print("Lineq after changes: ", controller._current_lineq_system)
	
	
	###Setup for constant running
	#controller.activate_difussion(true)
	##get_tree().create_timer(10.0).timeout.connect(controller.queue_free)
	controller.queue_free()
	
	return true

	
	
	
func stress_test(num_connections : int) -> void:
	#Generates randomly that many connections, each connected to another 6 (Average grid)
	var connections : Array[SystemDifferentialDiffusionVolume] = []
	for i in range(num_connections):
		var random_volume = SystemDifferentialDiffusionVolume.new(0.0,1.0,0.0)
		connections.append(random_volume)
		if i>0:
			SystemDifferentialDiffusionVolume.join_volumes(connections[i], connections[i-1], 1.0, 1.0)
	
	var td = SystemDifferentialDiffusionController.get_suggested_time_deltas(connections)
	var controller = SystemDifferentialDiffusionController.new(td)
	controller.add_volume(connections)
	add_child(controller)
	
	
	var start_time = Time.get_ticks_usec()
		
	var b : Array[float] = controller.get_generated_b()
	var solution : Array[float]
	var cycles := 100
	for n in range(cycles):
		solution = controller.solve(b)
		b = controller.get_generated_b(solution)
		pass
		
	var end_time = Time.get_ticks_usec()
	var duration_ms = float(end_time - start_time) / 1000.0
	print("%s Connections: Time to calculate %s steps took " % [num_connections, cycles], duration_ms, " ms")
	remove_child(controller)
	controller.queue_free()
	

	
#Inits a volume with that concentration
func test_grid(init_concentration : float) -> void:
	var a1 = $A1/Volume1 as SystemDifferentialDiffusionVolume
	a1.set_concentration(init_concentration)
	
	var a2 = $A2/Volume2 as SystemDifferentialDiffusionVolume
	var a3 = $A3/Volume3 as SystemDifferentialDiffusionVolume
	var a4 = $A4/Volume4 as SystemDifferentialDiffusionVolume
	var b1 = $B1/Volume5 as SystemDifferentialDiffusionVolume
	var b2 = $B2/Volume6 as SystemDifferentialDiffusionVolume
	var b3 = $B3/Volume7 as SystemDifferentialDiffusionVolume
	var b4 = $B4/Volume8 as SystemDifferentialDiffusionVolume
	var c1 = $C1/Volume9 as SystemDifferentialDiffusionVolume
	var c2 = $C2/Volume10 as SystemDifferentialDiffusionVolume
	var c3 = $C3/Volume11 as SystemDifferentialDiffusionVolume
	var c4 = $C4/Volume12 as SystemDifferentialDiffusionVolume
	
	#Connections
	#v with v1, v5...
	var grid_connections : Dictionary = {}
	grid_connections[a1] = [a2, b1]
	grid_connections[a2] = [a1, b2, a3]
	grid_connections[a3] = [a2, a4, b3]
	grid_connections[a4] = [a3, b4]
	grid_connections[b1] = [a1, b2, c1]
	grid_connections[b2] = [b1, b3, a2, c2]
	grid_connections[b3] = [b2, b4, a3, c3]
	grid_connections[b4] = [a4, c4, b3]
	grid_connections[c1] = [b1, c2]
	grid_connections[c2] = [c1, c3, b2]
	grid_connections[c3] = [c2, c4, b3]
	grid_connections[c4] = [c3, b4]	
	
	var collection : Array[SystemDifferentialDiffusionVolume] = []
	for k in grid_connections.keys():
		for c in grid_connections[k]:
			SystemDifferentialDiffusionVolume.join_volumes(k, c, 1.0, 2.0)
			if not k in collection: collection.append(k)
			if not c in collection: collection.append(c)
	
	var td = SystemDifferentialDiffusionController.get_suggested_time_deltas(collection)
	var controller = SystemDifferentialDiffusionController.new(td)
	#TODO Time delta automatico
	controller.add_volume(collection)
	add_child(controller)
	controller.activate_difussion(true)
	
	pass
	
	
	

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var from = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * 1000  # Cast 1000 units ahead

		var space_state = camera.get_world_3d().direct_space_state
		var params = PhysicsRayQueryParameters3D.new()
		params.to = to
		params.from = from
		var result = space_state.intersect_ray(params)

		if result:
			var col = result.collider
			if col is StaticBody3D:
				col.get_parent().on_clicked() #Test scene
