extends Node
const Ref = preload("uid://b6alvcbiyby3g")

@export var source: Ref.SimContainer
@export var targets: Array[Ref.SimContainer] = []   # default: single target
@export var fractions: Array[float] = []            # fractions per target, sum <= 1.0

@export var material: String = "water"
@export var throughput: float = 0.0   # m3/s
@export var active: bool = true

func add_target(container : Ref.SimContainer, fraction : float = 1.0) -> void:
	if not (container in targets):
		targets.append(container)
		fractions.append(fraction)
	return
	
func add_targets(...containers) -> void:
	for c in containers:
		if is_instance_of(c, Ref.SimContainer):
			add_target(c)
	pass
		
func link(_source : Ref.SimContainer, target : Ref.SimContainer, fraction : float = 1.0) -> void:
	source = _source
	add_target(target, fraction)
	
func set_throughput(value : float) -> void:
	throughput = value

static func edge_from_connection(_source : Ref.SimContainer, target : Ref.SimContainer, fraction : float = 1.0, _material = "water") -> Ref.SimEdge:
	var edge = Ref.SimEdge.new()
	edge.source = _source
	edge.add_target(target, fraction)
	edge.material = _material
	
	return edge 
		
func _init():
	# ensure defaults
	if targets.size() == 0 and source != null:
		targets.append(source)
	if fractions.size() != targets.size():
		fractions.resize(targets.size())
		for i in range(fractions.size()):
			fractions[i] = 1.0 / targets.size() if targets.size() > 0 else 1.0

func compute_flow(dt: float) -> float:
	if source == null or targets.size() == 0:
		return 0.0

	# Available volume and total throughput
	var source_available := source.get_volume(material)
	var max_transfer := throughput * dt

	# Limit flow by source
	return min(source_available, max_transfer)

func apply_flow(flow: float) -> void:
	# flow is distributed according to fractions and target capacities
	for i in range(targets.size()):
		var t = targets[i]
		var frac = fractions[i]

		if t == null: continue

		var desired = flow * frac
		var space = t.free_capacity()

		var actual = min(desired, space)

		if actual > 0:
			t.add_material(material, actual)
		t.add_overflow(material, max(0, desired - space))



static func add_source_to_edges(csource : Ref.SimContainer, ...edges) -> void:
	for e in edges:
		if e is Ref.SimEdge:
			e.source = csource

static func add_target_to_edges(ctarget : Ref.SimContainer, ...edges) -> void:
	for e in edges:
		if e is Ref.SimEdge:
			e.add_target(ctarget)
		
