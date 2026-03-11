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



func get_edges() -> Array[Ref.SimEdge]:
	var edges = [
		zulauf_ff,
		#ff
		ff_psb,
		ff_msb,
		ff_ved1,

		#PSB
		psb_bb1,
		psb_bb2,
		psb_pspw,

		#PSPW
		pspw_ved1,
		
		#SSPW
		sspw_ved1,

		#RLSPW
		rlspw_rsp1_psb,
		rlspw_rsp2_psb,
		rlspw_rsp3_psb,
		rlspw_rsp4_psb,
		rlspw_üsp1_ved1,

		twswpw_ff,
		twswpw_msb,

		#MSB
		msb_kwpw,
		msb_ved2,

		#KWPW
		kwpw_bb1,
		kwpw_bb2,

		#FMDS
		fmds_bb1,
		fmds_bb2,

		#BB
		bb1_nb1,
		bb1_nb2,
		bb2_nb1,
		bb2_nb2,

		#NB
		nb1_ablauf,
		nb1_rlspw,
		nb1_sspw,
		nb2_ablauf,
		nb2_rlspw,
		nb2_sspw,
				
	] as Array[Ref.SimEdge]
	
	return edges

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
