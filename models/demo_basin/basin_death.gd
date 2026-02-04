extends Node

@export var state: DEMO_BASIN.BasinState
@onready var death_floor1: Area3D = %death_floor1
@onready var death_floor2: Area3D = %death_floor2

@onready var death_floor : Area3D = %death_floor
const death_text := "You drowned! Don't just jump into a basin..."

func _ready():
	death_floor.area_entered.connect(_on_entered_basin)
	death_floor1.area_entered.connect(_on_entered_df1)
	death_floor2.area_entered.connect(_on_entered_df2)

func _on_entered_basin(area: Area3D):
	if state.water_volume <= 0.1:
		return
	if area is FPVAreaController:
		area.kill(tr(death_text))
		
func _on_entered_df1(area: Area3D):
	if state.water_volume <= 0.1:
		return
	if state.blower_target_on[0]:
		if area is FPVAreaController:
			area.kill(tr(death_text))

func _on_entered_df2(area: Area3D):
	if state.water_volume <= 0.1:
		return
	if state.blower_target_on[1]:
		if area is FPVAreaController:
			area.kill(tr(death_text))
