extends Node
const BandControl := preload("uid://dbpfeir5ks45a")

func _ready():
	test_add_band()
	test_add_bands()
	test_band_for_value_edges()
	test_closest_band()
	test_update_switching()
	test_overlapping_band_buffer()
	test_overlapping_band_step_up()
	test_overlap_starting_region()
	test_jump_across_multiple_bands()
	test_jump_down_across_multiple_bands()
	test_jump_outside_all_bands()
	
	print("All tests finished.")
	
	
	
func test_add_band():
	var measurement = func(): return 0.0
	var out_val = 0.0
	var output = func(v): out_val = v

	var c = BandControl.Controller.new(measurement, output)

	c.add_band(0, 10, 1.0)

	assert(c.bands.size() == 1)
	assert(c.bands[0].floorl == 0)
	assert(c.bands[0].ceilingl == 10)
	assert(c.bands[0].output == 1.0)

	print("test_add_band passed")
	
	
	
func test_add_bands():
	var measurement = func(): return 0.0
	var output = func(v): pass

	var c = BandControl.Controller.new(measurement, output)

	var b1 = BandControl.Band.new(0, 10, 1)
	var b2 = BandControl.Band.new(10, 20, 2)

	c.add_bands([b1, b2, b1]) # duplicate

	assert(c.bands.size() == 2)

	print("test_add_bands passed")
	
	
func test_band_for_value_edges():
	var measurement = func(): return 0.0
	var output = func(v): pass

	var c = BandControl.Controller.new(measurement, output)

	c.add_band(0, 10, 1)
	c.add_band(10, 20, 2)

	var b = c._band_for_value(10)

	# depending on band ordering, first band should catch it
	assert(b != null)
	assert(b.output == 1)

	print("test_band_for_value_edges passed")
	
	
	
func test_closest_band():
	var measurement = func(): return 0.0
	var output = func(v): pass

	var c = BandControl.Controller.new(measurement, output)

	c.add_band(0, 10, 1)
	c.add_band(20, 30, 2)

	var b = c._closest_band(15)

	assert(b != null)
	assert(b.output == 1 or b.output == 2)

	print("test_closest_band passed")
	
	
func test_update_switching():
	var value = [5.0]
	var out_val = [-1.0]

	var measurement = func(): return value[0]
	var output = func(v): out_val[0] = v

	var c = BandControl.Controller.new(measurement, output)

	c.add_band(0, 10, 1)
	c.add_band(10, 20, 2)

	c.update()

	assert(out_val[0] == 1)

	value[0] = 15
	c.update()

	assert(out_val[0] == 2)

	print("test_update_switching passed")
	
	
	
func test_overlapping_band_buffer():
	var value = [6.0]
	var out_val = [-1.0]

	var measurement = func(): return value[0]
	var output = func(v): out_val[0] = v

	var c = BandControl.Controller.new(measurement, output)

	# overlapping bands
	c.add_band(0, 10, 1)
	c.add_band(5, 20, 2)
	c.add_band(10, 40, 3)

	# initial value inside band A
	c.update()
	assert(out_val[0] == 1)

	# move upward into overlap with band B
	value[0] = 11
	c.update()
	assert(out_val[0] == 2)

	# move slightly down but still inside band B overlap
	value[0] = 9
	c.update()
	assert(out_val[0] == 2) # should NOT drop back to band A

	# drop far enough to exit band B
	value[0] = 4
	c.update()
	assert(out_val[0] == 1)

	print("test_overlapping_band_buffer passed")


func test_overlapping_band_step_up():
	var value = [3.0]
	var out_val = [-1.0]

	var measurement = func(): return value[0]
	var output = func(v): out_val[0] = v

	var c = BandControl.Controller.new(measurement, output)

	c.add_band(0, 10, 1)
	c.add_band(5, 20, 2)
	c.add_band(10, 40, 3)

	c.update()
	assert(out_val[0] == 1)

	value[0] = 12
	c.update()
	assert(out_val[0] == 2)

	value[0] = 25
	c.update()
	assert(out_val[0] == 3)

	print("test_overlapping_band_step_up passed")
	
	
func test_overlap_starting_region():
	var value = [7.0]
	var out_val = [-1.0]

	var measurement = func(): return value[0]
	var output = func(v): out_val[0] = v

	var c = BandControl.Controller.new(measurement, output)

	c.add_band(0, 10, 1)
	c.add_band(5, 20, 2)

	c.update()

	# first matching band wins due to iteration order
	assert(out_val[0] == 1)

	print("test_overlap_starting_region passed")
	
	
func test_jump_across_multiple_bands():
	var value = [3.0]
	var out_val = [-1.0]

	var measurement = func(): return value[0]
	var output = func(v): out_val[0] = v

	var c = BandControl.Controller.new(measurement, output)

	c.add_band(0, 10, 1)
	c.add_band(5, 20, 2)
	c.add_band(10, 40, 3)

	# start in band A
	c.update()
	assert(out_val[0] == 1)

	# jump across two bands
	value[0] = 35
	c.update()

	# should land directly in band C
	assert(out_val[0] == 3)

	print("test_jump_across_multiple_bands passed")
	
	
func test_jump_down_across_multiple_bands():
	var value = [35.0]
	var out_val = [-1.0]

	var measurement = func(): return value[0]
	var output = func(v): out_val[0] = v

	var c = BandControl.Controller.new(measurement, output)

	c.add_band(0, 10, 1)
	c.add_band(5, 20, 2)
	c.add_band(10, 40, 3)

	c.update()
	assert(out_val[0] == 3)

	value[0] = 3
	c.update()

	assert(out_val[0] == 1)

	print("test_jump_down_across_multiple_bands passed")

func test_jump_outside_all_bands():
	var value = [5.0]
	var out_val = [-1.0]

	var measurement = func(): return value[0]
	var output = func(v): out_val[0] = v

	var c = BandControl.Controller.new(measurement, output)

	c.add_band(0, 10, 1)
	c.add_band(20, 30, 2)

	c.update()
	assert(out_val[0] == 1)

	value[0] = 100
	c.update()

	assert(out_val[0] == 2)

	print("test_jump_outside_all_bands passed")
