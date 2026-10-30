extends ControllerBase
class_name ControllerKB1

func _ready() -> void:
	Signals.capture_mouse.connect(capture_mouse)
	Signals.release_mouse.connect(release_mouse)
	pass

func enable(enable_) -> void:
	set_process(enable_)
	set_process_unhandled_key_input(enable_)
	set_process_unhandled_input(enable_)
	set_process_shortcut_input(enable_)


func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	is_mouse_captured = true
	mouse_captured.emit()
	

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	is_mouse_captured = false
	mouse_released.emit()

func is_crouch_pressed() -> bool:
	return Input.is_action_pressed("crouch")

func is_panorama_exit_requested() -> bool:
	return Input.is_action_just_pressed("exit_panorama")


##HACK for web. Since you can't just capture the mouse in the browser...
func _input(event: InputEvent) -> void:
	if is_mouse_captured and (Input.mouse_mode != Input.MOUSE_MODE_CAPTURED) and event is InputEventMouseButton:
		capture_mouse()
		
		get_viewport().set_input_as_handled()		


func _unhandled_input(event: InputEvent) -> void:
	#Mouse motion
	if (event is InputEventMouseMotion) and (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		lookdir = event.relative * 0.001
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			#_conobj.mousewheelup()
			mousewheelup.emit()
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			#_conobj.mousewheeldown()
			mousewheeldown.emit()
			get_viewport().set_input_as_handled()
		return

##KEYS
func _unhandled_key_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		interact.emit() #Dont consume this
		get_viewport().set_input_as_handled()
	
	elif Input.is_physical_key_pressed(KEY_4):
		Signals.request_change_topic.emit(TOPICS.LAYER.ABWASSER)
	elif Input.is_physical_key_pressed(KEY_5):
		Signals.request_change_topic.emit(TOPICS.LAYER.ELEKTRIK)	
	
	elif Input.is_action_just_pressed("uidebug"):
		if is_mouse_captured: Signals.release_mouse.emit()
		else: Signals.capture_mouse.emit()
		get_viewport().set_input_as_handled()
		
	elif Input.is_action_just_pressed("tasks"):
		Signals.toggle_tasks_menu.emit()
		get_viewport().set_input_as_handled()
	elif _event is InputEventKey:
		if _event.keycode == KEY_V:
			pass	
	#Update some keys
	is_shift = Input.is_action_pressed("movement_shift")
	is_jumping = Input.is_action_pressed("movement_space")


func _process(_delta: float) -> void:
	if (Input.mouse_mode == Input.MOUSE_MODE_VISIBLE): #moved here from input
		mousepos = get_viewport().get_mouse_position()
	
	movedir = Vector3.ZERO
	_movedir_precalculation = Vector3.ZERO
	#_movedir.x = 0
	#_movedir.z = 0
	if reading_movement:
		if Input.is_action_pressed("up"):
			_movedir_precalculation.z += -1
		if Input.is_action_pressed("down"):
			_movedir_precalculation.z += +1
		if Input.is_action_pressed("left"):
			_movedir_precalculation.x += -1
		if Input.is_action_pressed("right"):
			_movedir_precalculation.x += +1

	movedir = _movedir_precalculation.normalized()
		
