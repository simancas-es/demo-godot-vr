extends Node
const Ref := preload("uid://b6alvcbiyby3g")
const Containers := preload("uid://bddvcs80xee0d")
const Edges := preload("uid://c05ncsd4hvera")

const PID := preload("uid://b56vhusy3ty4s")
const PIDBinding := preload("uid://dcimoti8vbbyo")
const BandControl := preload("uid://dbpfeir5ks45a")
const BandBinding := BandControl.Controller
const Band := BandControl.Band

var controller: Ref.SimController

var cs := Containers.new()
var es := Edges.new()

var _containers : Array[Ref.SimContainer]
var _edges : Array[Ref.SimEdge]

var pidbindings : Dictionary[Edges.ID, PIDBinding] = {}
var bandbindings : Dictionary[Edges.ID, BandControl.Controller] = {}
var manualbindings : Dictionary = {} # Edges.ID , [Array or Ref.SimEdge]
var _handledbindings : Array = []


func _init() -> void:
	controller = Ref.SimController.new()

	# Register containers in controller
	_containers = [cs.rechen.sc, cs.fettfang.sc, cs.psb.sc, cs.pspw.sc, cs.sspw.sc, cs.twswpw.sc, cs.rlspw.sc,
				 cs.ed.ved1, cs.ed.ved2, cs.ed.ved3, cs.ed.ned1,
			  	cs.fmds.sc, cs.bb1.sc, cs.bb2.sc, cs.nb1.sc, cs.nb2.sc, cs.ablauf.sc, cs.msb.sc, cs.kwpw.sc] as Array[Ref.SimContainer]
	for c in _containers:
		controller.register_container(c)

	es.initialize(cs)
	#Register edges in controller
	_edges = es.get_edges()
	for e in _edges: 
		controller.register_edge(e)
		
	_handledbindings.resize(_edges.size())
	
	init_state()
	init_pid()
	
	#INIT
	#controller.step(1.0)
	#print_flows()
	
	return

func _ready() -> void:
	set_process(false)
	
func start() -> void:
	set_process(true)
	
func stop() -> void:
	set_process(false)
	
#Sets the speed of the simulation, this can lead to inconsistencies and overflows for small elements.
func set_speed(multiplier : float) -> void:
	speed = multiplier
	
	pass

var speed : float = 1.0
var sim_interval : float = 5.0
var sim_timer : float = 0.0
func _process(delta: float) -> void:
	sim_timer += delta * speed
	if sim_timer >= sim_interval:
		run_simulation(sim_interval)
		sim_timer -= sim_interval

func run_simulation(dt: float) -> void:
	for hb in range(_handledbindings.size()):
		_handledbindings[hb] = null
	
	var i = 0	
	for b in manualbindings.keys(): #Manually set throughputs have priority over the other ones
		_handledbindings[i] = b
		i += 1

	for b in pidbindings.keys():
		if b in _handledbindings : continue
		pidbindings[b].update(dt)
		_handledbindings[i] = b
		i += 1
	
	for b in bandbindings.keys():
		if b in _handledbindings : continue
		bandbindings[b].update()
		_handledbindings[i] = b
		i += 1
		
	controller.step(dt)
	#print_flows()
	pass

func print_flows() -> void:
	print("Zulauf: %s m3s" % es.zulauf_ff.throughput)
	print("FF: %s" % cs.fettfang.sc.get_volume("water"))
	print("FF: to_psb %s m3s, to_msb %s m3s, to..." % [es.ff_psb.throughput, es.ff_msb.throughput])

func set_manual_throughput(edges_ref : Variant, value : float) -> void:
	#if is_instance_of(edges, Ref.SimEdge): edges.set_throughput(value)
	if edges_ref is Edges.ID : es.get_edge_by_id(edges_ref).set_throughput(value)
	if edges_ref is Array:
		for e in edges_ref:
			es.get_edge_by_id(e).set_throughput(value)
	manualbindings[edges_ref] = edges_ref

#Removes the priority for manual
func remove_manual_throughput(id : Edges.ID) -> void:
	if id in manualbindings:
		var obj = manualbindings[id]
		if obj is Ref.SimEdge: obj.set_throughput(0)
		elif obj is Array:
			for o in obj:
				if o is Ref.SimEdge: o.set_throughput(0)
		manualbindings.erase(id)
	
	
#init storage
func init_state() -> void:
	for c in _containers:
		c.fill(0.8) #HACK
		
	es.zulauf_ff.throughput = 0.12
	pass

#init pid setup
func init_pid() ->  void:
	bandbindings[Edges.ID.FF_PSB] = BandBinding.new(
					func() : return cs.fettfang.sc.total_volume(),
					func(v) : es.ff_psb.throughput = v,
					Band.new(0, 100, 0), Band.new(80,150,0.08), Band.new(140,225,0.15), Band.new(200,300, 0.3)
	)
		
	#ff_msb,
	bandbindings[Edges.ID.FF_MSB] = BandBinding.new(
					func() : return cs.fettfang.sc.total_volume(),
					func(v) : es.ff_msb.throughput = v,
					Band.new(0, 200, 0), Band.new(200, 300, 0.15)
	)
	#ff_ved1,
	set_manual_throughput(Edges.ID.FF_VED1, 0.00)
	
	##PSB 
	set_manual_throughput(Edges.ID.PSB_BB1, 0.04)
	set_manual_throughput(Edges.ID.PSB_BB2, 0.04)
	set_manual_throughput(Edges.ID.PSB_PSPW, 0.00)

	##PSPW
	#pspw_ved1,	#Manually regulated?
	#es.pspw_ved1.throughput = 0.00; manualbindings.set("pspw_ved1", 0)
	set_manual_throughput(Edges.ID.PSPW_VED1, 0.04)
	set_manual_throughput(Edges.ID.PSPW_VED1, 0.00)
	##RLSPW #HACK
	#rlspw_rsp1_psb,		#rlspw_rsp2_psb,		#rlspw_rsp3_psb,		#rlspw_rsp4_psb,
	pidbindings[Edges.ID.RLSPW_RSP1_PSB] = PIDBinding.new( 
		#Note: Negative values because the container is the measurement and not the target of the pumping
		PID.new(cs.rlspw.sc.max_volume_m3/2, 0.01, 0.00002, 0, -0.16, 0.0), #TODO Adjust
		func(): return cs.rlspw.sc.total_volume(),
		func(v):
			es.rlspw_rsp1_psb.throughput = -v*0.25
			es.rlspw_rsp2_psb.throughput = -v*0.25
			es.rlspw_rsp3_psb.throughput = -v*0.25
			es.rlspw_rsp4_psb.throughput = -v*0.25
	)		
	#rlspw_üsp1_ved1,
	bandbindings[Edges.ID.RLSPW_ÜSP1_VED1] = BandBinding.new(
					func() : return cs.rlspw.sc.total_volume(),
					func(v) : es.rlspw_üsp1_ved1.throughput = v,
					Band.new(0, cs.rlspw.sc.max_volume_m3/2, 0.02), Band.new(cs.rlspw.sc.max_volume_m3/2, cs.rlspw.sc.max_volume_m3, 0.2)
	)
	
	##MSB
	#msb_kwpw
	bandbindings[Edges.ID.MSB_KWPW] = BandBinding.new(
					func() : return cs.kwpw.sc.total_volume(),
					func(v) : es.msb_kwpw.throughput = v,
					Band.new(0, cs.kwpw.sc.max_volume_m3/2, 0.05),
					Band.new(cs.kwpw.sc.max_volume_m3/2, cs.rlspw.sc.max_volume_m3, 0)
	)
	#msb_ved2
	set_manual_throughput(Edges.ID.MSB_VED2, 0.00)
	##KWPW
	set_manual_throughput(Edges.ID.KWPW_BB1, 0.00)
	set_manual_throughput(Edges.ID.KWPW_BB2, 0.00)
		
	##FMDS
	set_manual_throughput(Edges.ID.FMDS_BB1, 0.0001)
	set_manual_throughput(Edges.ID.FMDS_BB2, 0.0001)

#
	##BB
	set_manual_throughput(Edges.ID.BB1_NB1, 0.05)
	set_manual_throughput(Edges.ID.BB1_NB2, 0.05)
	set_manual_throughput(Edges.ID.BB2_NB1, 0.05)
	set_manual_throughput(Edges.ID.BB2_NB2, 0.05)
#
	##NB
	set_manual_throughput(Edges.ID.NB1_ABLAUF, 0.05)
	set_manual_throughput(Edges.ID.NB1_RLSPW, 0.02)
	set_manual_throughput(Edges.ID.NB1_SSPW, 0.01)
	
	set_manual_throughput(Edges.ID.NB2_ABLAUF, 0.05)
	set_manual_throughput(Edges.ID.NB2_RLSPW, 0.02)
	set_manual_throughput(Edges.ID.NB2_SSPW, 0.01)
