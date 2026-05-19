extends "res://zones/hillersleben/scripts/tasks/sequence_consumer.gd"
const CONTROLLER := preload("uid://dowywdoia8in2")

@onready var controller : CONTROLLER = $"../TaskController"

func _ready() -> void:
	sequencer = $TaskSequencer

func start():
	if !started: controller.start_low()
	super()
