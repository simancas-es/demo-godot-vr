@tool
extends Area3D
class_name SystemSpatialConcentrationSource
#Ignore warnings...


#This module represents a point in space that has a certain concentration.
#The objective of this is to create an area so that a concentration reader
#can get a weighted concentration depending on the distance to the points.

##Used for discrimination from the detector
@export var concentration_type : SYSTEMSPATIALCONCENTRATIONSETTINGS.TYPE = SYSTEMSPATIALCONCENTRATIONSETTINGS.TYPE.DEFAULT ##Kind of concentration...
@export var core_concentration = 1.0 ##Concentration at center.
@export var falloff_radius_m : float = 1.0 ##Radius at which falls to 0
@export_exp_easing("positive_only") var falloff_curve : float = 1.0 ## 100% at center, 0% at falloff_radius

var fallout_shape : CollisionShape3D = null: ## Points outside this shape have concentration 0.0
	set(value):
		fallout_shape = value
		if Engine.is_editor_hint():
			update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	if not fallout_shape: return ["Add a CollisionShape3D as a children if you want to limit the effect!"]
	return []

func _editor_added_children(node : Node) -> void:
	if node is CollisionShape3D:
		fallout_shape = node
		update_configuration_warnings()


func _ready() -> void:
	if Engine.is_editor_hint():
		child_entered_tree.connect(_editor_added_children)
		child_exiting_tree.connect(_editor_added_children)
	#
	if not is_in_group(SYSTEMSPATIALCONCENTRATIONSETTINGS.BASE_GROUP):
		add_to_group(SYSTEMSPATIALCONCENTRATIONSETTINGS.BASE_GROUP)


	self.collision_layer = 0
	self.collision_mask = 0
	
	init_area_limits()


func init_area_limits() -> void:	
	var cs = get_children()
	for c in cs:
		if c is CollisionShape3D:
			fallout_shape = c
			break
	if not fallout_shape: return
	self.monitoring = false
	self.monitorable = true
	self.collision_layer = SYSTEMSPATIALCONCENTRATIONSETTINGS.COLLISION_LAYER
	self.collision_mask = 0

##Calculates the average concentration based on the sum of concentrations and falloffs
static func get_added_up_concentration(source_array : Array[SystemSpatialConcentrationSource], detector : SystemSpatialConcentrationDetector) -> float:
	var num = source_array.size()
	var concentrations : Array[float] = []; concentrations.resize(num)
	var dist : Array[float] = [] ; dist.resize(num)

	var point = detector.global_position
	var space : PhysicsDirectSpaceState3D = detector.get_world_3d().direct_space_state
	var query_intersect = intersect_area_point(space, point)
	var intersected_areas = []
	for d : Dictionary in query_intersect:
		if d.collider is SystemSpatialConcentrationSource:
			intersected_areas.append(d.collider)
			
	for i in range(num):
		var p = source_array[i]
		
		if p.fallout_shape: ##Restricted by area but point outside of area
			if not (p in intersected_areas): continue
		else: pass ##Not restricted and apply falloff normally.		
		
		dist[i] = p.global_position.distance_to(point)
		dist[i] = 1.0 - clampf(sqrt(dist[i])/p.falloff_radius_m, 0.0, 1.0)
		concentrations[i] = ease(dist[i], p.falloff_curve) * p.core_concentration
		
	##Adds all the concentrations
	var f : float = 0.0
	for c in concentrations: if c: f += c
	
	return f
	
##Calculates the average concentration based on the max of concentrations and falloffs
static func get_max_concentration(source_array : Array[SystemSpatialConcentrationSource], detector : SystemSpatialConcentrationDetector) -> float:
	var num = source_array.size()
	var concentrations : Array[float] = []; concentrations.resize(num)
	concentrations.fill(0.0)
	var dist : Array[float] = [] ; dist.resize(num)
	
	var point = detector.global_position
	var space : PhysicsDirectSpaceState3D = detector.get_world_3d().direct_space_state
	var query_intersect = intersect_area_point(space, point)
	var intersected_areas = []
	for d : Dictionary in query_intersect:
		if d.collider is SystemSpatialConcentrationSource:
			intersected_areas.append(d.collider)
	
	for i in range(num):
		var p = source_array[i]

		if p.fallout_shape: ##Restricted by area but point outside of area
			if not (p in intersected_areas): continue
		else: pass ##Not restricted and apply falloff normally.		
		dist[i] = p.global_position.distance_to(point)
		dist[i] = 1.0 - clampf(sqrt(dist[i])/p.falloff_radius_m, 0.0, 1.0)
		concentrations[i] = ease(dist[i], p.falloff_curve) * p.core_concentration
	
	##Adds all the concentrations
	return concentrations.max()
	

static func intersect_area_point(space : PhysicsDirectSpaceState3D, point : Vector3) -> Array[Dictionary]:
	var parameters = PhysicsPointQueryParameters3D.new()
	parameters.position = point
	parameters.collide_with_areas = true
	parameters.collide_with_bodies = false
	parameters.collision_mask = SYSTEMSPATIALCONCENTRATIONSETTINGS.COLLISION_LAYER
	
	var result : Array[Dictionary] = space.intersect_point(parameters)
	return result
