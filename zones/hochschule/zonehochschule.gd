extends BaseZone


#52.14148259003399, 11.677246534668694

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	connect_signals()
	#Signals.set_fixed_camera.emit(false)

	
	pass

func connect_signals():
	#Special setup
	if not %FalconActivator.falcon_started.is_connected(activate_falcon):
		%FalconActivator.falcon_started.connect(activate_falcon)
	
	#if not finished_setup.connect(o)

func setup_introscreen():
	#reset_fpv()
	#set_fixed_camera.call_deferred(true)
	#Signals.release_mouse.emit.call_deferred()
	
	##Set fixscreen. TODO: BUG: Fragile, depends on FPV being a group...
	var group_nodes : Array[FPV] = get_fpvs() #NO_TRANSLATE
	for fpv : FPV in group_nodes:
		fpv.set_mode_fixed(true)
	pass
	
func activate_falcon() -> void:
	Signals.set_falcon_camera.emit()
	if falcon_view:
		var fpvs = get_fpvs()
		if fpvs.is_empty(): return
		falcon_view.activate_view(fpvs[0], fpvs[0].camera)
	

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("test_falcondrop"): #ç
		if falcon_view:
			falcon_view.deactivate_view()
			var fpvs = get_fpvs()
			if fpvs.is_empty(): return #TODO differently
			await FalconView.generate_follow_falcondrop(self, fpvs[0].camera, 2.0, starting_lookat, starting_lookat)
	pass
