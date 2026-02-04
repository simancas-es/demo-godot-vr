extends DEMO_BASIN.BasinController

func _init() -> void:
	super()
	state.aerator_ok = [true, false]
	state.water_volume = 5.0
	state.blower_target_on = [true, false]
	
