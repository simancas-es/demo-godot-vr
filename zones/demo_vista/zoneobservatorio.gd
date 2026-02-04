extends BaseZone

#52.631639639934306, 11.815886435048386
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()

	pass # Replace with function body.


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("test_falcon"): #+]
		#Signals.set_fixed_camera.emit(true)
		var fpvs = get_fpvs()
		if fpvs.is_empty(): return
		falcon_view.activate_view(fpvs[0], fpvs[0].camera)
		
		pass
		
	elif Input.is_action_just_pressed("test_falcondrop"): #ç
		falcon_view.deactivate_view()		
		var fpvs = get_fpvs()
		if fpvs.is_empty(): return #TODO Exit to env animation
		await FalconView.generate_follow_falcondrop(self, fpvs[0].camera, 2.0, starting_lookat, starting_lookat)
	pass
