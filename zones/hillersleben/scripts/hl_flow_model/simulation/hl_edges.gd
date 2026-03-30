const Ref := preload("uid://b6alvcbiyby3g")
const Containers := preload("uid://bddvcs80xee0d")

const generated_edges : Array[Ref.SimEdge] = []

#Rechen
var zulauf_ff := Ref.SimEdgeSource.new()
#ff
var ff_psb := Ref.SimEdge.new()
var ff_msb := Ref.SimEdge.new()
var ff_ved1 := Ref.SimEdge.new()

#PSB
var psb_bb1 := Ref.SimEdge.new()
var psb_bb2 := Ref.SimEdge.new()
var psb_pspw := Ref.SimEdge.new()

#PSPW
var pspw_ved1 := Ref.SimEdge.new()

#SSPW
var sspw_ved1 := Ref.SimEdge.new()

#TWSWPW
var twswpw_msb := Ref.SimEdge.new()
var twswpw_ff := Ref.SimEdge.new()

#MSB
var msb_kwpw := Ref.SimEdge.new()
var msb_ved2 := Ref.SimEdge.new()

#KWPW
var kwpw_bb1 := Ref.SimEdge.new()
var kwpw_bb2 := Ref.SimEdge.new()

#RLSPW
var rlspw_rsp1_psb := Ref.SimEdge.new()
var rlspw_rsp2_psb := Ref.SimEdge.new()
var rlspw_rsp3_psb := Ref.SimEdge.new()
var rlspw_rsp4_psb := Ref.SimEdge.new()
var rlspw_üsp1_ved1 := Ref.SimEdge.new()


#FMDS
var fmds_bb1 := Ref.SimEdge.new()
var fmds_bb2 := Ref.SimEdge.new()

#BB
var bb1_nb1 := Ref.SimEdge.new()
var bb1_nb2 := Ref.SimEdge.new()
var bb2_nb1 := Ref.SimEdge.new()
var bb2_nb2 := Ref.SimEdge.new()

#NB
var nb1_ablauf := Ref.SimEdge.new()
var nb1_rlspw := Ref.SimEdge.new()
var nb1_sspw := Ref.SimEdge.new()
var nb2_ablauf := Ref.SimEdge.new()
var nb2_rlspw := Ref.SimEdge.new()
var nb2_sspw := Ref.SimEdge.new()


enum ID {
	ZULAUF_FF,
	FF_PSB,
	FF_MSB,
	FF_VED1,
	PSB_BB1,
	PSB_BB2,
	PSB_PSPW,
	PSPW_VED1,
	SSPW_VED1,
	RLSPW_RSP1_PSB,
	RLSPW_RSP2_PSB,
	RLSPW_RSP3_PSB,
	RLSPW_RSP4_PSB,
	RLSPW_ÜSP1_VED1,

	TWSWPW_FF,
	TWSWPW_MSB,

	#MSB
	MSB_KWPW,
	MSB_VED2,

	#KWPW
	KWPW_BB1,
	KWPW_BB2,

	#FMDS
	FMDS_BB1,
	FMDS_BB2,

	#BB
	BB1_NB1,
	BB1_NB2,
	BB2_NB1,
	BB2_NB2,

	#NB
	NB1_ABLAUF,
	NB1_RLSPW,
	NB1_SSPW,
	NB2_ABLAUF,
	NB2_RLSPW,
	NB2_SSPW,
	
}

var LIST : Dictionary[ID, Ref.SimEdge] = {
	ID.ZULAUF_FF : zulauf_ff,
	ID.FF_PSB : ff_psb,
	ID.FF_MSB : ff_msb,
	ID.FF_VED1 : ff_ved1,
	ID.PSB_BB1 : psb_bb1,
	ID.PSB_BB2 : psb_bb2,
	ID.PSB_PSPW : psb_pspw,
	ID.PSPW_VED1 : pspw_ved1,
	ID.SSPW_VED1 : sspw_ved1,
	ID.RLSPW_RSP1_PSB : rlspw_rsp1_psb,
	ID.RLSPW_RSP2_PSB : rlspw_rsp2_psb,
	ID.RLSPW_RSP3_PSB : rlspw_rsp2_psb,
	ID.RLSPW_RSP4_PSB : rlspw_rsp4_psb,
	ID.RLSPW_ÜSP1_VED1 : rlspw_üsp1_ved1,

	ID.TWSWPW_FF : twswpw_ff,
	ID.TWSWPW_MSB : twswpw_msb,

	#MSB
	ID.MSB_KWPW : msb_kwpw,
	ID.MSB_VED2 : msb_ved2,

	#KWPW
	ID.KWPW_BB1 : kwpw_bb1,
	ID.KWPW_BB2 : kwpw_bb2,

	#FMDS
	ID.FMDS_BB1 : fmds_bb1,
	ID.FMDS_BB2 : fmds_bb2,

	#BB
	ID.BB1_NB1 : bb1_nb1,
	ID.BB1_NB2 : bb1_nb2,
	ID.BB2_NB1 : bb2_nb1,
	ID.BB2_NB2 : bb2_nb2,

	#NB
	ID.NB1_ABLAUF : nb1_ablauf,
	ID.NB1_RLSPW : nb1_rlspw,
	ID.NB1_SSPW : nb1_sspw,
	ID.NB2_ABLAUF : nb2_ablauf,
	ID.NB2_RLSPW : nb2_rlspw,
	ID.NB2_SSPW : nb2_sspw
}
	


func get_edges() -> Array[Ref.SimEdge]:
	var edges = LIST.values() as Array[Ref.SimEdge]	
	return edges

func get_edge_by_id(id : ID) -> Ref.SimEdge:
	return LIST[id]

func initialize(containers : Containers) -> void:
	var cs = containers #intantiate the container script

	zulauf_ff.add_target(cs.fettfang.sc)

	ff_psb.link(cs.fettfang.sc, cs.psb.sc)	
	ff_msb.link(cs.fettfang.sc, cs.msb.sc)		
	ff_ved1.link(cs.fettfang.sc, cs.ed.ved1)
	
	psb_bb1.link(cs.psb.sc, cs.bb1.sc)
	psb_bb2.link(cs.psb.sc, cs.bb2.sc)
	psb_pspw.link(cs.psb.sc, cs.pspw.sc)


	pspw_ved1.source = cs.pspw.sc
	pspw_ved1.add_target(cs.ed.ved1, 1.0)
	pspw_ved1.add_target(cs.ed.ved3, 0.0)	

	#RLSPW
	Ref.SimEdge.add_source_to_edges(cs.rlspw.sc,
		 rlspw_rsp1_psb, rlspw_rsp2_psb, rlspw_rsp3_psb, rlspw_rsp4_psb,
		rlspw_üsp1_ved1)
		
	Ref.SimEdge.add_target_to_edges(cs.psb.sc,
			rlspw_rsp1_psb, rlspw_rsp2_psb, rlspw_rsp3_psb, rlspw_rsp4_psb)
			
	rlspw_üsp1_ved1.add_target(cs.ed.ved1, 1.0)
	rlspw_üsp1_ved1.add_target(cs.ed.ved3, 0.0)
	
	##SSPW
	sspw_ved1.source = cs.sspw.sc
	sspw_ved1.add_target(cs.ed.ved1, 1.0)
	sspw_ved1.add_target(cs.ed.ved3, 0.0)
	
	#TWSWPW
	Ref.SimEdge.add_source_to_edges(cs.twswpw.sc, twswpw_ff, twswpw_msb)
	twswpw_ff.add_target(cs.fettfang.sc)
	twswpw_msb.add_target(cs.msb.sc)
	
	
	msb_kwpw.link(cs.msb.sc, cs.kwpw.sc)
	msb_ved2.link (cs.msb.sc, cs.ed.ved2)

		#KWPW
	kwpw_bb1.link(cs.kwpw.sc, cs.bb1.sc)
	kwpw_bb2.link(cs.kwpw.sc, cs.bb2.sc)
	
	#FMDS
	Ref.SimEdge.add_source_to_edges(cs.fmds.sc, fmds_bb1, fmds_bb2)
	fmds_bb1.add_target(cs.bb1.sc)
	fmds_bb2.add_target(cs.bb2.sc)

	#BB
	Ref.SimEdge.add_target_to_edges(cs.nb1.sc,	bb1_nb1, bb2_nb1)
	Ref.SimEdge.add_target_to_edges(cs.nb2.sc,	bb1_nb2, bb2_nb2)
	Ref.SimEdge.add_source_to_edges(cs.bb1.sc,	bb1_nb1, bb1_nb2)
	Ref.SimEdge.add_source_to_edges(cs.bb2.sc,	bb2_nb1, bb2_nb2)

	#NB
	Ref.SimEdge.add_target_to_edges(cs.ablauf.sc,	nb1_ablauf, nb2_ablauf)
	Ref.SimEdge.add_target_to_edges(cs.rlspw.sc,	nb1_rlspw, nb2_rlspw)
	Ref.SimEdge.add_target_to_edges(cs.sspw.sc,		nb1_sspw, nb2_sspw)
	Ref.SimEdge.add_source_to_edges(cs.nb1.sc, nb1_ablauf, nb1_rlspw, nb1_sspw)
	Ref.SimEdge.add_source_to_edges(cs.nb2.sc, nb2_ablauf, nb2_rlspw, nb2_sspw)
	
	#Check
	for e in get_edges():
		assert(e.source)
