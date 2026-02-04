extends Node

@export var state: DEMO_BASIN.BasinState
@export var fill_tank: FillableTank

func sync_fill() -> void:
	var fraction = state.water_volume / state.max_volume
	fill_tank.fill_level(fraction, 0.5)  #TODO Time

func sync_aeration() -> void:
	var idx_on : Array[bool] = state.blower_target_on
	toggle_bubbles(idx_on)






@export_category("Aeration") ##Activates and deactivates the aeration
@export var aerates : bool = false
@export var bubble_strength : Array[float] ##Strength of each bubble patch
@export var bubble_duration_s : float = 1.0 ##Time between activation and deactivation
@export var reversible_aeration : bool = true ##On multiple activations it goes back to previous state


func toggle_bubbles(enable : Array[bool]) -> void:
	if !aerates : return
	var bubble_strength_mod = bubble_strength.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	for s in bubble_strength_mod.size():
		bubble_strength_mod[s] = float(enable[s]) # x = 2*x -1 is a toggle
	await turn_bubbles_on(bubble_strength_mod, bubble_duration_s)
	
	pass
##Turns bubbles on if applicable.
func turn_bubbles_on(strength : Array[float], time_s : float) -> void:
	var count = fill_tank.get_water_bubble_count()
	var array : Array[float] = strength.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	array.resize(count)
	fill_tank.set_water_bubbles_strength(array, time_s)
	#state_updated.emit()
