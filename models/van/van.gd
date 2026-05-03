extends Interaction
class_name SelectEnvironmentVan


@onready var lights : Array[SpotLight3D] = [%SpotlightR, %SpotlightL, %SpotlightR2, %SpotlightL2]
@onready var audioplayer : AudioStreamPlayer3D = %AudioStreamPlayer3D

var active : bool = false
var id_from : ENVIRONMENTS.ID
var recently_activated : bool = false

const interact_text = "Press [{key}] to travel!"

func _ready() -> void:
	hint_text[ENUMS.ACTION.INTERACT] = tr(interact_text)

	idle()
	
	#Signals.entered_room.connect(mute_audio)
	activated.connect(on_activated)
	looked_at.connect(on_lookedat)
	dropped_looked_at.connect(on_droppedlook)
	
	
func mute_audio():
	#print("Muting van audio")
	audioplayer.stop()
	
func on_activated(_context: InteractionContext) -> void:
	activate()
	pass
	
func on_lookedat(_context: InteractionContext) -> void:
	if !active: semi_selected()
	#Signals.hint_text.emit("Fahren")
	pass
	
func on_droppedlook() -> void:
	#print("dropped look, act", active)
	idle()
	#Signals.hint_text.emit("")
	pass
	
	
func activate():
	if recently_activated : return
	recently_activated = true
	Signals.ui_msg_top.emit(tr("You clicked on the van"))
	Signals.select_env.emit(id_from)
	await get_tree().create_timer(1.0)
	recently_activated = false
	pass
	
func semi_selected():
	#turns lights on a bit
	lights_on(3)
	motor(true)
	#audioplayer.stop()
	active = false
	
func idle():
	#Turn off lights and noise
	lights_on(1.0)
	motor(false)
	pass
	
func lights_on(fraction : float):
	for l in lights:
		l.light_energy = 1 * fraction
	pass
	
func motor(active_ : bool) -> void:
	if active_:
		audioplayer.stream = AudioManager.cache_sound(RESOURCES.SOUND_VAN_ENGINE)
		audioplayer.play()
		audioplayer.finished.connect(func(): audioplayer.play()) #Loop...
	else:
		audioplayer.stop()
