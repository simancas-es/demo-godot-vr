extends Node
const Ref = preload("uid://b6alvcbiyby3g")

func _ready():
	test_basic_transfer()
	test_source_limit()
	test_target_capacity_limit()
	test_rate_limit()
	test_multiple_edges_to_same_target()
	test_infinite_capacity()
	test_no_flow_when_empty()
	test_multimaterial_transfer()
	test_flow_chain_propagation()
	test_circular_network()
	test_source_reservation_competing_edges()
	test_source_edge()
	test_splitter_edge()

	print("All tests executed")


func assert_float(a: float, b: float, eps: float = 0.0001):
	if abs(a - b) > eps:
		push_error("Assertion failed: %f != %f" % [a, b])
		assert(false)

func test_basic_transfer():
	var s := Ref.SimContainer.new()
	var t := Ref.SimContainer.new()
	s.add_material("water", 5.0)
	t.add_material("water", 0.0)

	var e := Ref.SimEdge.new()
	e.source = s
	e.targets = [t] as Array[Ref.SimContainer]
	e.fractions = [1.0] as Array[float]
	e.throughput = 2.0

	var c = Ref.SimController.new()
	c.register_edge(e)
	c.step(1.0)

	assert_float(s.get_volume("water"), 3.0)
	assert_float(t.get_volume("water"), 2.0)

# ----------------------------------------
func test_source_limit():
	var s = Ref.SimContainer.new()
	var t = Ref.SimContainer.new()
	s.add_material("water", 1.0)

	var e = Ref.SimEdge.new()
	e.source = s
	e.targets = [t] as Array[Ref.SimContainer]
	e.fractions = [1.0] as Array[float]
	e.throughput = 5.0

	var c = Ref.SimController.new()
	c.register_edge(e)
	c.step(1.0)

	assert_float(s.get_volume("water"), 0.0)
	assert_float(t.get_volume("water"), 1.0)

# ----------------------------------------
func test_target_capacity_limit():
	var s = Ref.SimContainer.new()
	var t = Ref.SimContainer.new()
	s.add_material("water", 10.0)
	t.max_volume_m3 = 3.0
	t.add_material("water", 2.0)

	var e = Ref.SimEdge.new()
	e.source = s
	e.targets = [t] as Array[Ref.SimContainer]
	e.fractions = [1.0] as Array[float]
	e.throughput = 5.0

	var c = Ref.SimController.new()
	c.register_edge(e)
	c.step(1.0)

	assert_float(t.get_volume("water"), 3.0)

# ----------------------------------------
func test_rate_limit():
	var s = Ref.SimContainer.new()
	var t = Ref.SimContainer.new()
	s.add_material("water", 10.0)
	t.add_material("water", 0.0)

	var e = Ref.SimEdge.new()
	e.source = s
	e.targets = [t] as Array[Ref.SimContainer]
	e.fractions = [1.0] as Array[float]
	e.throughput = 2.0

	var c = Ref.SimController.new()
	c.register_edge(e)
	c.step(1.0)

	assert_float(t.get_volume("water"), 2.0)

# ----------------------------------------
func test_multiple_edges_to_same_target():
	var s1 = Ref.SimContainer.new()
	var s2 = Ref.SimContainer.new()
	var t = Ref.SimContainer.new()

	s1.add_material("water", 3.0)
	s2.add_material("water", 4.0)
	t.add_material("water", 0.0)

	var e1 = Ref.SimEdge.new()
	e1.source = s1
	e1.targets = [t] as Array[Ref.SimContainer]
	e1.fractions = [1.0] as Array[float]
	e1.throughput = 5.0

	var e2 = Ref.SimEdge.new()
	e2.source = s2
	e2.targets = [t] as Array[Ref.SimContainer]
	e2.fractions = [1.0] as Array[float]
	e2.throughput = 5.0

	var c = Ref.SimController.new()
	c.register_edge(e1)
	c.register_edge(e2)
	c.step(1.0)

	assert_float(t.get_volume("water"), 7.0)

# ----------------------------------------
func test_infinite_capacity():
	var s = Ref.SimContainer.new()
	var t = Ref.SimContainer.new()

	# Source and target setup
	s.add_material("water", 5.0)
	t.add_material("water", 0.0)

	# Activate infinite capacity on target
	t.infinite_capacity = true

	var e = Ref.SimEdge.new()
	e.source = s
	e.targets = [t] as Array[Ref.SimContainer]
	e.fractions = [1.0] as Array[float]
	e.throughput = 10.0

	var c = Ref.SimController.new()
	c.register_edge(e)
	c.step(1.0)

	# All water should flow to target since it has "infinite" capacity
	assert_float(t.get_volume("water"), 5.0)
	
	
# ----------------------------------------
func test_no_flow_when_empty():
	var s = Ref.SimContainer.new()
	var t = Ref.SimContainer.new()

	s.add_material("water", 0.0)
	t.add_material("water", 0.0)

	var e = Ref.SimEdge.new()
	e.source = s
	e.targets = [t] as Array[Ref.SimContainer]
	e.fractions = [1.0] as Array[float]
	e.throughput = 5.0

	var c = Ref.SimController.new()
	c.register_edge(e)
	c.step(1.0)

	assert_float(t.get_volume("water"), 0.0)

# ----------------------------------------
func test_multimaterial_transfer():
	var s = Ref.SimContainer.new()
	var t = Ref.SimContainer.new()

	s.add_material("water", 3.0)
	s.add_material("oil", 4.0)
	t.add_material("water", 0.0)
	t.add_material("oil", 0.0)

	var e1 = Ref.SimEdge.new()
	e1.source = s
	e1.targets = [t] as Array[Ref.SimContainer]
	e1.fractions = [1.0] as Array[float]
	e1.material = "water"
	e1.throughput = 2.0

	var e2 = Ref.SimEdge.new()
	e2.source = s
	e2.targets = [t] as Array[Ref.SimContainer]
	e2.fractions = [1.0] as Array[float]
	e2.material = "oil"
	e2.throughput = 3.0

	var c = Ref.SimController.new()
	c.register_edge(e1)
	c.register_edge(e2)
	c.step(1.0)

	assert_float(t.get_volume("water"), 2.0)
	assert_float(t.get_volume("oil"), 3.0)

# ----------------------------------------
func test_flow_chain_propagation():
	var s = Ref.SimContainer.new()
	var m = Ref.SimContainer.new()
	var t = Ref.SimContainer.new()

	s.add_material("water", 5.0)
	m.add_material("water", 0.0)
	t.add_material("water", 0.0)

	var e1 = Ref.SimEdge.new()
	e1.source = s
	e1.targets = [m] as Array[Ref.SimContainer]
	e1.fractions = [1.0] as Array[float]
	e1.throughput = 2.0

	var e2 = Ref.SimEdge.new()
	e2.source = m
	e2.targets = [t] as Array[Ref.SimContainer]
	e2.fractions = [1.0] as Array[float]
	e2.throughput = 1.0

	var c = Ref.SimController.new()
	c.register_edge(e1)
	c.register_edge(e2)
	c.step(1.0)
	c.step(1.0)

	# s -> m = 2, m -> t = 1
	assert_float(s.get_volume("water"), 1.0)
	assert_float(m.get_volume("water"), 3.0)
	assert_float(t.get_volume("water"), 1.0)

# ----------------------------------------
func test_circular_network():
	var a = Ref.SimContainer.new()
	var b = Ref.SimContainer.new()
	var c = Ref.SimContainer.new()
	var d = Ref.SimContainer.new()

	a.add_material("water", 8.0)
	b.add_material("water", 0.0)
	c.add_material("water", 0.0)
	d.add_material("water", 0.0)

	var ab = Ref.SimEdge.new()
	ab.source = a
	ab.targets = [b] as Array[Ref.SimContainer]
	ab.fractions = [1.0] as Array[float]
	ab.throughput = 2.0

	var bc = Ref.SimEdge.new()
	bc.source = b
	bc.targets = [c] as Array[Ref.SimContainer]
	bc.fractions = [1.0] as Array[float]
	bc.throughput = 2.0

	var cd = Ref.SimEdge.new()
	cd.source = c
	cd.targets = [d] as Array[Ref.SimContainer]
	cd.fractions = [1.0] as Array[float]
	cd.throughput = 2.0

	var da = Ref.SimEdge.new()
	da.source = d
	da.targets = [a] as Array[Ref.SimContainer]
	da.fractions = [1.0] as Array[float]
	da.throughput = 2.0

	var controller = Ref.SimController.new()
	controller.register_edge(ab)
	controller.register_edge(bc)
	controller.register_edge(cd)
	controller.register_edge(da)

	# Step 1
	controller.step(1.0)
	assert_float(a.get_volume("water"), 6.0)
	assert_float(b.get_volume("water"), 2.0)
	assert_float(c.get_volume("water"), 0.0)
	assert_float(d.get_volume("water"), 0.0)

# ----------------------------------------
func test_source_reservation_competing_edges():
	var a = Ref.SimContainer.new()
	var b = Ref.SimContainer.new()
	var c = Ref.SimContainer.new()

	a.add_material("water", 2.0)
	b.add_material("water", 0.0)
	c.add_material("water", 0.0)

	var ab = Ref.SimEdge.new()
	ab.source = a
	ab.targets = [b] as Array[Ref.SimContainer]
	ab.fractions = [1.0] as Array[float]
	ab.throughput = 2.0

	var ac = Ref.SimEdge.new()
	ac.source = a
	ac.targets = [c] as Array[Ref.SimContainer]
	ac.fractions = [1.0] as Array[float]
	ac.throughput = 2.0

	var controller = Ref.SimController.new()
	controller.register_edge(ab)
	controller.register_edge(ac)
	controller.step(1.0)

	# One edge gets the full flow
	var total = b.get_volume("water") + c.get_volume("water")
	assert_float(total, 2.0)
	assert_float(a.get_volume("water"), 0.0)

# ----------------------------------------
func test_source_edge():
	var t = Ref.SimContainer.new()
	t.add_material("water", 0.0)

	var edge = Ref.SimEdgeSource.new()
	edge.targets = [t] as Array[Ref.SimContainer]
	edge.fractions = [1.0] as Array[float]
	edge.throughput = 3.0

	var controller = Ref.SimController.new()
	controller.register_edge(edge)
	controller.step(1.0)

	assert_float(t.get_volume("water"), 3.0)

# ----------------------------------------
func test_splitter_edge():
	var s = Ref.SimContainer.new(); s.infinite_volume = true;
	var t1 = Ref.SimContainer.new()
	var t2 = Ref.SimContainer.new()
	t1.add_material("water", 0.0)
	t2.add_material("water", 0.0)

	var edge = Ref.SimEdge.new()
	edge.source = s
	edge.targets = [t1, t2] as Array[Ref.SimContainer]
	edge.fractions = [0.25, 0.75] as Array[float]
	edge.throughput = 4.0

	var controller = Ref.SimController.new()
	controller.register_edge(edge)
	controller.step(1.0)

	assert_float(t1.get_volume("water"), 1.0)
	assert_float(t2.get_volume("water"), 3.0)
	
	
