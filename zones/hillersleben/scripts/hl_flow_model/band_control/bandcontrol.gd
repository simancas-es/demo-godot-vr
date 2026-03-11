#BandControl

class Band extends RefCounted:
	var floorl: float
	var ceilingl: float
	var output: float
	func _init(_floorl: float, _ceilingl: float, _output: float) -> void:
		floorl = _floorl
		ceilingl = _ceilingl
		output = _output


class Controller extends RefCounted:
	var bands: Array = []
	var current_band: Band = null
	var measurement_func: Callable
	var output_func: Callable

	func _init(_measurement_func: Callable, _output_func: Callable, ...argbands):
		self.measurement_func = _measurement_func
		self.output_func = _output_func
		for b in argbands:
			if is_instance_of(b, Band):
				bands.append(b)
	
	func add_bands(_bands : Array[Band]) -> void:
		for b in _bands:
			if not b in bands:
				bands.append(b)
		return
		
	func add_band(_floorl: float, _ceilingl: float, output: float) -> void:
		var band = Band.new(_floorl, _ceilingl, output)
		bands.append(band)

	func update() -> void:
		var value = measurement_func.call()
		
		# pick current band if none
		if current_band == null:
			current_band = _band_for_value(value)
			if current_band == null:
				current_band = _closest_band(value)
		
		# check if still inside the band with overlap
		if current_band != null:
			var _floor = current_band.floorl
			var _ceiling = current_band.ceilingl
			
			if value < _floor or value > _ceiling:
				var next_band = _band_for_value(value) # First one that falls within it
				if next_band != null:
					current_band = next_band
				else:
					current_band = _closest_band(value)
		
		# set output
		if current_band != null:
			output_func.call(current_band.output)

	# helper to find a band that contains the value
	func _band_for_value(value: float) -> Band:
		for b in bands:
			if value >= b.floorl and value <= b.ceilingl:
				return b
		return null

	func _closest_band(value: float) -> Band:
		var closest: Band = null
		var min_distance = INF
		for b in bands:
			var center = (b.floorl + b.ceilingl) * 0.5
			var dist = abs(value - center)
			if dist < min_distance:
				min_distance = dist
				closest = b
		return closest
