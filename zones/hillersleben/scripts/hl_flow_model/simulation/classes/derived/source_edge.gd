extends Ref.SimEdge
const Ref = preload("uid://b6alvcbiyby3g")

func _init():
	var sc = Ref.SimContainer.new()
	sc.infinite_volume = true
	source = sc
	super()
	
func compute_flow(dt: float) -> float:
	return throughput * dt

func apply_flow(flow: float) -> void:
	for i in range(targets.size()):
		var t = targets[i]
		var frac = fractions[i] if i < fractions.size() else 1.0
		var actual_flow = flow * frac

		if t == null:
			continue

		# No need to check source, target capacity handled inside add_material
		t.add_material(material, actual_flow)
