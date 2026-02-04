extends Button

signal closed

func _ready() -> void:
	button_up.connect(_on_buttonclose_button_up)
	button_down.connect(_on_buttonclose_button_down)
	mouse_exited.connect(_on_mouse_exit)
	
func _on_mouse_exit():
	Signals.play_sound.emit(RESOURCES.SOUND_CLICK_OUT)
	button_pressed = false
	
func _on_buttonclose_button_up():
	if button_pressed:
		Signals.play_sound.emit(RESOURCES.SOUND_CLICK_OUT)
	if self.is_hovered():
		UTILS.create_timer(self, 0.08, true, on_close).start()
		
func on_close():
	closed.emit()
	
func _on_buttonclose_button_down():
	Signals.play_sound.emit(RESOURCES.SOUND_CLICK_IN)
