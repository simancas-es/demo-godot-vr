extends Control
#Label updating
#Hooks up label text with corresponding volumes and throughput in model
const Ref := preload("uid://b6alvcbiyby3g")
const Containers := preload("uid://bddvcs80xee0d")
const Edges := preload("uid://c05ncsd4hvera")

var containers : Containers
var edges : Edges

@onready var ved1 : Label = $Containers/VED1
@onready var ved2 : Label = $Containers/VED2
@onready var ved3 : Label = $Containers/VED3
@onready var ned1 : Label = $Containers/NED1
@onready var ff : Label = $Containers/FF
@onready var psb : Label = $Containers/PSB
@onready var bb1 : Label = $Containers/BB1
@onready var bb2 : Label = $Containers/BB2
@onready var nb1 : Label = $Containers/NB1
@onready var nb2 : Label = $Containers/NB2
@onready var sspw : Label = $Containers/SSPW
@onready var rlspw : Label = $Containers/RLSPW	
@onready var twswpw : Label = $Containers/TWSWPW
@onready var msb : Label = $Containers/MSB
@onready var kwpw : Label = $Containers/KWPW

static func update_from_container(label : Label, container : Ref.SimContainer) -> void:
	var m3 = container.get_volume("water")
	var pct = 0.0
	if container.max_volume_m3>0.0:
		pct = m3/container.max_volume_m3 * 100
	label.text = "%s: %d m3 %d%% " % [label.name, m3, pct]
	pass
	
func init(_containers : Containers, _edges : Edges) -> void:
	containers = _containers
	edges = _edges
	set_process(true)


func _ready() -> void:
	set_process(false)
	update()
	
func start() -> void:
	set_process(true)
func stop() -> void:
	set_process(false)
	
func update() -> void:
	if containers == null : return
	#Update containers
	update_from_container(ved1, containers.ed.ved1)
	update_from_container(ved2, containers.ed.ved2)
	update_from_container(ved3, containers.ed.ved3)
	update_from_container(ned1, containers.ed.ned1)
	update_from_container(ff, containers.fettfang.sc)
	update_from_container(psb, containers.psb.sc)
	update_from_container(bb1, containers.bb1.sc)
	update_from_container(bb2, containers.bb2.sc)
	update_from_container(nb1, containers.nb1.sc)
	update_from_container(nb2, containers.nb2.sc)
	update_from_container(sspw, containers.sspw.sc)
	update_from_container(rlspw, containers.rlspw.sc)
	update_from_container(twswpw, containers.twswpw.sc)
	update_from_container(msb, containers.msb.sc)
	update_from_container(kwpw, containers.kwpw.sc)
	
	var control_edges  = $Edges.get_children()
	for ce in control_edges:
		if edges.get(ce.name):
			ce.text = "%s %d L/s" % [ce.name, edges.get(ce.name).throughput*1000]
	$Edges/fmds_bb1.text = "%s %0.2f L/s" % ["fmds_bb1", edges.get("fmds_bb1").throughput*1000] 
	$Edges/fmds_bb2.text = "%s %0.2f L/s" % ["fmds_bb2", edges.get("fmds_bb2").throughput*1000] 
	pass
	
	
var _timer = 0.0
var _interval = 1.0  # seconds
func _process(delta):
	_timer -= delta
	if _timer <= 0.0:
		update()
		_timer += _interval  # reset countdown

	
