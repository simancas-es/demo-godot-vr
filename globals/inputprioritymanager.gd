extends Node
class_name InputPriorityManager

#This will decide who has the priority when processing input
#var process_input : Callable = Callable(func(event : InputEvent) -> void : return)
var _input_candidates : Dictionary[Callable, int] = {}
var _copy_functions : Array[Callable] = []

var _len_functions : int = 0

func _ready():
	Signals.register_input_processing.connect(_add_input_process)
	Signals.end_input_processing.connect(_remove_input_process)
	
#CONNECTING INPUTS
func _add_input_process(function : Callable, priority : int):
	_input_candidates[function] = priority
	_update_order()
		
func _remove_input_process(function : Callable):
	_input_candidates.erase(function) #resizes
	_update_order()
	
	
func _update_order():
	_len_functions = _input_candidates.size()
	_copy_functions.resize(_len_functions)
	var c = 0
	
	var priority_array = [] #Store priorities
	var function_array = [] #Store the functions in the same order
	priority_array.resize(_len_functions)
	function_array.resize(_len_functions)
	var i = 0
	for key in _input_candidates:
		var prio = _input_candidates[key]
		priority_array[i] = prio
		function_array[i] = key
		i += 1
	
	#Haphazardly sort this...
	var _min = priority_array.min()
	var _max = priority_array.max()
	for n in range(_min,_max + 1, 1):
		if priority_array.has(n):
			var f = n
			while f < _len_functions:
				f = priority_array.find(n, f)
				_copy_functions[c] = function_array[f]
				c += 1
				f += 1
	pass
	
func _input(event: InputEvent) -> void:
	for n in range(_len_functions):
		if _copy_functions[n].call(event):
			break
