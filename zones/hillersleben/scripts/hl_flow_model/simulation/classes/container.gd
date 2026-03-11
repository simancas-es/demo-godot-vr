extends Node
const Ref = preload("uid://b6alvcbiyby3g")


@export var name_c: String
@export var max_volume_m3: float = 10.0
@export var infinite_capacity: bool = false
@export var infinite_volume : bool = false


var storage: Dictionary = {}
var overflow : Dictionary = {}

func _init(_name: String = ""):
	name_c = _name

func fill(fraction : float, material = "water") -> void:
	storage[material] = fraction * max_volume_m3

func get_volume(material: String) -> float:
	if infinite_volume:
		return INF
	return storage.get(material, 0.0)


func add_material(material: String, amount: float) -> void:
	if infinite_volume: storage[material] = INF
	if not storage.has(material):
		storage[material] = 0.0

	storage[material] += amount

	if storage[material] < 0.0:
		storage[material] = 0.0
		
	
func add_overflow(material : String, amount : float) -> void:
	if not storage.has(material):
		storage[material] = 0.0

	storage[material] += amount


func total_volume() -> float:
	if infinite_volume: return INF
	var total := 0.0
	for m in storage:
		total += storage[m]
	return total


func free_capacity() -> float:
	if infinite_capacity or infinite_volume:
		return INF

	return max(max_volume_m3 - total_volume(), 0.0)	
