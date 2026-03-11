extends Node
const Ref = preload("uid://b6alvcbiyby3g")


class Rechen extends Node:
	var sc = Ref.SimContainer.new()
	func _init() -> void:
		sc.max_volume_m3 = 2.0
var rechen := Rechen.new()

class Fettfang extends Node:
	var sc = Ref.SimContainer.new()
	func _init() -> void:
		sc.max_volume_m3 = 5.2 * 15 * 3	
var fettfang := Fettfang.new()

class PSB extends Node:
	var sc = Ref.SimContainer.new()
	func _init() -> void:
		sc.max_volume_m3 = 1130
var psb := PSB.new()

class PSPW extends Node:
	var sc = Ref.SimContainer.new()
	func _init() -> void:
		sc.max_volume_m3 = 3 * 3 * 5
var pspw := PSPW.new()

class SSPW extends Node:
	var sc = Ref.SimContainer.new()
	func _init() -> void:
		sc.max_volume_m3 = 3 * 3 * 5
var sspw := SSPW.new()

class TWSWPW extends Node: #To MSB and Fettfang. From many.
	var sc = Ref.SimContainer.new()
	func _init() -> void:
		sc.max_volume_m3 = 3 * 3 * 5 * 2
var twswpw := TWSWPW.new()

class KWPW extends Node: #To MSB and Fettfang. From many.
	var sc = Ref.SimContainer.new()
	func _init() -> void:
		sc.max_volume_m3 = 3 * 3 * 5
var kwpw := KWPW.new()

class RLSPW extends Node:
	var sc = Ref.SimContainer.new()

	func _init() -> void:
		sc.max_volume_m3 = 3 * 3 * 5
var rlspw := RLSPW.new()

class ED extends Node:
	var ved1 := Ref.SimContainer.new() #to twswpw
	var ved2 := Ref.SimContainer.new() #to twswpw and rop1
	var ved3 := Ref.SimContainer.new() #to twswpw and rop2, rop4
	var ned1 := Ref.SimContainer.new() #to twswpw and rop2
	func _init() -> void:
		ved1.max_volume_m3 = 406
		ved2.max_volume_m3 = 406
		ved3.max_volume_m3 = 406
		ned1.max_volume_m3 = 406
		pass
var ed = ED.new()

class FMDS extends Node:
	var sc := Ref.SimContainer.new()
	func _init() -> void:
		sc.max_volume_m3 = 100
var fmds := FMDS.new()

class BB1 extends Node:
	var sc := Ref.SimContainer.new()
	func _init() -> void:
		sc.max_volume_m3 = 3705.9
var bb1 := BB1.new()

class BB2 extends Node:
	var sc := Ref.SimContainer.new()
	func _init() -> void:
		sc.max_volume_m3 = 3705.9
var bb2 := BB2.new()

class NB1 extends Node:
	var sc := Ref.SimContainer.new()
	func _init() -> void:
		sc.max_volume_m3 = 27.86*27.86/4 * 3.14 * 3.5 #tiefe 3.5
var nb1 := NB1.new()

class NB2 extends Node:
	var sc := Ref.SimContainer.new()
	func _init() -> void:
		sc.max_volume_m3 = 27.86*27.86/4 * 3.14 * 3.5 #tiefe 3.5
var nb2 := NB2.new()

class Ablauf extends Node:
	var sc := Ref.SimContainer.new()
	func _init() -> void:
		sc.max_volume_m3 = 5*3*3
var ablauf := Ablauf.new()

class MSB extends Node:
	var sc := Ref.SimContainer.new()
	func _init() -> void:
		sc.max_volume_m3 = 3000
var msb := MSB.new()


enum ID {
	RECHEN, FETTFANG,PSB, PSPW, SSPW, TWSWPW, KWPW, RLSPW,
	VED1, VED2, VED3, NED1, FMDS, BB1, BB2, NB1, NB2, ABLAUF, MSB
}
var LIST : Dictionary[ID, Ref.SimContainer] = {
	ID.RECHEN : rechen.sc,
	ID.FETTFANG : fettfang.sc,
	ID.PSB : psb.sc,
	ID.PSPW : pspw.sc,
	ID.SSPW : sspw.sc,
	ID.TWSWPW : twswpw.sc,
	ID.KWPW : kwpw.sc,
	ID.RLSPW : rlspw.sc,
	ID.VED1 : ed.ved1,
	ID.VED2 : ed.ved2,
	ID.VED3 : ed.ved3,
	ID.NED1 : ed.ned1,
	ID.FMDS : fmds.sc,
	ID.BB1 : bb1.sc,
	ID.BB2 : bb2.sc,
	ID.NB1 : nb1.sc,
	ID.NB2 : nb2.sc,
	ID.ABLAUF : ablauf.sc,
	ID.MSB : msb.sc,
}

#Bad but it works
func _init() -> void:
	
	
	pass
