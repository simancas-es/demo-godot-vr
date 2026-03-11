# Controller.gd
extends Node
const Ref = preload("uid://b6alvcbiyby3g")

var containers: Array[Ref.SimContainer] = []
var edges: Array[Ref.SimEdge] = []

func register_container(c: Ref.SimContainer) -> void:
	containers.append(c)

func register_edge(e: Ref.SimEdge) -> void:
	edges.append(e)
func step(dt: float) -> void:

	var transfers := []

	var remaining_source := {}

	# initialize source availability
	for e in edges:
		if not e.active:
			continue
		if not remaining_source.has(e.source):
			remaining_source[e.source] = {}
		if not remaining_source[e.source].has(e.material):
			if e.source == null: push_error("Missing source for edge! %s" % e); continue;
			remaining_source[e.source][e.material] = e.source.get_volume(e.material)

	# compute flows with reservation
	for e in edges:
		if not e.active: continue
		if not e.source: continue

		var available = remaining_source[e.source][e.material]
		var requested = e.compute_flow(dt)
		var flow = min(requested, available)

		if flow <= 0:
			continue

		transfers.append({"edge": e, "amount": flow})

		remaining_source[e.source][e.material] -= flow

	# apply flows to targets
	for t in transfers:
		var e: Ref.SimEdge = t.edge
		var flow: float = t.amount

		# subtract from source
		e.source.add_material(e.material, -flow)
		# distribute to targets safely
		e.apply_flow(flow)
