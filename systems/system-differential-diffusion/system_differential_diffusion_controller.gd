extends Node
class_name SystemDifferentialDiffusionController

##Class that controls a domain of volumes
## And calculates the solutions for the differential eqs
##Uses the finite volume diffusion discretized Fick's Law with 
##fully implicit backward Euler scheme.
##No convection
##Fab = Gab * Aab / Lab *(Cb(n+1) - Ca(n+1)
##Va( Ca(n+1) - Ca(n) )/deltaT = Sum all Fab  (Fab + Fac + Fad...)

var current_volumes : Array[SystemDifferentialDiffusionVolume] = []
var time_delta : float = 1.0 ##Time delta has to be much less than the least distance^2/diffusion
var _current_lineq_system : Array[PackedFloat32Array] = []
var _sparse_equations : Array[Dictionary] = [] ##Dictionary of int: float for variable index and coefficients

var active_diffusion : bool = false ##Actively updates the volumes
##Updating the volumes just means giving the volumes a new list of values
##From which they may or may not interpolate in ticks as required.

func _init(timedelta : float) -> void:
	time_delta = timedelta
	
func _ready() -> void:
	if current_volumes:
		_current_lineq_system = build_linear_equation_system(current_volumes, time_delta )


##Adds a volume to the managed systems.
##Assumes that the connections have been already made.
##
func add_volume(vols : Array[SystemDifferentialDiffusionVolume]) -> void:
	var updated_vols : Array[SystemDifferentialDiffusionVolume] = []
	for vol in vols:
		if not vol in current_volumes:
			current_volumes.append(vol)
			if not (vol in updated_vols): updated_vols.append(vol)
			for c in vol.connections: #Has to update not only the new one but the ones it references.
				if not (c in updated_vols): updated_vols.append(c)
		vol.changed_values.connect(on_changed_values.bind(vol))
	#Recalculate System,
	var _l = modify_linear_equation_system(_current_lineq_system, updated_vols, current_volumes, time_delta)
	_sparse_equations = get_sparse_array_dict_from(_current_lineq_system)

func on_changed_values(vol : SystemDifferentialDiffusionVolume) -> void:
	var _l = modify_linear_equation_system(_current_lineq_system, [vol], current_volumes, time_delta)
	_sparse_equations = get_sparse_array_dict_from(_current_lineq_system)
	
	#Change recommended td
	var new_td = get_suggested_time_deltas(current_volumes)
	time_delta = new_td
	
	pass

##Calculates a timedelta based on the t << L^2/Diffusivity recommendation.
static func get_suggested_time_deltas(volumes : Array[SystemDifferentialDiffusionVolume], factor : float = 0.25) -> float:
	var min_distance : float = 1.0
	var max_diffusivity : float = 0.001
	
	for vol in volumes:
		max_diffusivity = max(max_diffusivity, vol.current_diffusivity)
		min_distance = min(min_distance, vol._distances.min())
	return min_distance**2 / max_diffusivity * factor

static func build_linear_equation(vol : SystemDifferentialDiffusionVolume, volumes : Array[SystemDifferentialDiffusionVolume], timedelta : float) -> PackedFloat32Array:
	var variable_index = volumes.find(vol)
	var eq = []; eq.resize(volumes.size()); eq.fill(0.0)
	
	##Adds the V/deltaT coeficient of Ca(n+1)
	eq[variable_index] += vol.volume / timedelta	
	for local_idx in range(vol.connections.size()):
		var v = vol.connections[local_idx]
		var global_idx = volumes.find(v) #Finds the variable number of the connected volume
		if global_idx == -1:
			push_error("Connection volume not found in all_vols")
			continue
			
		#Ca(n+1)(V/Difft + Rab + Rac) - Rab*Cb(n+1) - Rac*Cc(n+1)... = Ca(n) * V/Difft + V*Sa(generation)
		#Rab is a constant for each pair of volumes.
		var Rab = (
			0.5 * vol.current_diffusivity + 0.5 * v.current_diffusivity #TODO: Weighted average of coefficients by distance/volume
			) * vol._areas[local_idx] / vol._distances[local_idx]

		eq[variable_index] += Rab
		eq[global_idx] -= Rab	
	return PackedFloat32Array(eq)
	
	
##Modifies a given linear equation system by altering only the needed indices
##WARNING! Modified inplace
static func modify_linear_equation_system(lineqs : Array[PackedFloat32Array], updated_volumes : Array[SystemDifferentialDiffusionVolume], volumes : Array[SystemDifferentialDiffusionVolume], timedelta : float) -> Array[PackedFloat32Array]:
	for vol in updated_volumes:
		var variable_index = volumes.find(vol)
		if variable_index == -1:
			volumes.append(vol)
			variable_index = volumes.size()-1
		
		if variable_index >= lineqs.size():	
			lineqs.resize(variable_index + 1)	
		lineqs[variable_index] = build_linear_equation(vol, volumes, timedelta)	
	return lineqs
	
	
##Row wise for each volume, columnwise for each volume variable.
static func build_linear_equation_system(volumes: Array[SystemDifferentialDiffusionVolume], timedelta: float) -> Array[PackedFloat32Array]:
	var linear_eq_system: Array[PackedFloat32Array] = []
	for i in range(volumes.size()):
		var vol = volumes[i]
		var eq = build_linear_equation(vol, volumes, timedelta)
		linear_eq_system.append(eq)	
	return linear_eq_system


	

static func clone_sparse_matrix(A: Array[Dictionary]) -> Array[Dictionary]:
	var n : int = A.size()
	var A_copy : Array[Dictionary] = []; A_copy.resize(n)
	var base_n : int = 0
	for row in A:
		var new_row : Dictionary = row.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
		#var new_row : Dictionary[int, float] = {}
		#for key in row.keys():
			#new_row[key] = row[key]
		A_copy[base_n] = new_row
		base_n += 1
	return A_copy

##Transforms a lsit of vectors into a dictionary lookup
##[0, 0, 0, 2, 0, 3] -> {3:2, 5:3}
static func get_sparse_array_dict_from(array: Array[PackedFloat32Array]) -> Array[Dictionary]:
	var s = array.size()
	var list : Array[Dictionary] = []; list.resize(s)
	for i in range(s):
		list[i] = {}
		for n in range(array[i].size()):
			if array[i][n] != 0.0:
				list[i][n] = array[i][n] #Copy over only the values that are not zero
		
	return list


static func forward_elimination_sparse(A_orig: Array, b_orig: Array[float]) -> Dictionary:
	var n = A_orig.size()
	var A : Array[Dictionary] = clone_sparse_matrix(A_orig)
	var b = b_orig#.duplicate()
	
	for i in range(n):
		if not A[i].has(i) or abs(A[i][i]) < 1e-12:
			push_error("Missing or zero pivot at row %d" % i)
			return {}
		
		var pivot = A[i][i]
		
		for j in range(i + 1, n):
			if not A[j].has(i):
				continue
			
			var factor = A[j][i] / pivot
			
			# Subtract factor * row_i from row_j
			for k in A[i].keys():
				A[j][k] = A[j].get(k, 0.0) - factor * A[i][k]
				if abs(A[j][k]) < 1e-12:
					A[j].erase(k)
			
			b[j] -= factor * b[i]
			
			# Remove eliminated pivot element explicitly
			if A[j].has(i):
				A[j].erase(i)
	
	return {
		"A": A,
		"b": b
	}

static func back_substitution(A: Array, b: Array) -> Array[float]:
	var n = A.size()
	var x : Array[float] = []; x.resize(n); x.fill(0.0)

	for i in range(n - 1, -1, -1):
		var s = b[i]
		for j in A[i].keys():
			if j != i:
				s -= A[i][j] * x[j]
		x[i] = s / A[i][i]
	return x

##Generates the initial RHS of the system from:
## Concentration * Volume/Timedelta + Volume*Generation
func get_generated_b(from_concentrations : Array[float] = []) -> Array[float]:
	var n : int = current_volumes.size()
	var b : Array[float] = []; b.resize(n)
	if not from_concentrations:
		for i in range(n):
			var cv = current_volumes[i]
			b[i] = (cv.current_concentration * cv.volume / time_delta + cv.current_generation * cv.volume)
	else:
		for i in range(n):
			var cv = current_volumes[i]
			b[i] = (from_concentrations[i] * cv.volume / time_delta + cv.current_generation * cv.volume)
	return b

#Solves with the current linear equation system
func solve(b : Array[float]) -> Array[float]:
	var A_b : Dictionary = forward_elimination_sparse(_sparse_equations, b)
	var sol = back_substitution(A_b["A"], A_b["b"])
	return sol

##Calculates and updates the new concentration gradient in time for the volumes
##Based on the concentration that the volumes have at this moment in time
func calculate_and_update_volumes() -> void:
	var b : Array[float] = get_generated_b()
	var sol = solve(b)
	var current_volumes_size : int = current_volumes.size()
	if sol.size() != current_volumes_size:
			push_warning("Current volumes modified before ending calculation...")
			return
	for v in range(current_volumes_size):
		current_volumes[v].set_concentration(sol[v], false)

	

func activate_difussion(enable : bool) -> void:
	active_diffusion = enable
	set_process(enable) ##Requires being a children

#Updating the Volumes	
var _time_margin_s : float = 0.0 ##Time since last calculation

var _calculating : bool = false
func _process(delta: float) -> void:
	if _calculating: return
	_time_margin_s -= delta
	if _time_margin_s <= 0.0:
		_calculating = true
		calculate_and_update_volumes()
		_time_margin_s += time_delta
		_calculating = false		
		
	
	
		
	
