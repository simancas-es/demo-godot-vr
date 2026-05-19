extends CONSUMER
const CONSUMER := preload("uid://cjrqcfgi4v8xn")

@onready var checks : Node3D = %Q_VORSTELLUNG
const CHECKPOINT := preload("uid://cf00e7qn1t0c7")

func _ready():
	sequencer = $TaskSequencerVorstellung
	
func _on_next_task(task_id : int) -> void:
	match task_id:
		SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_SEE_RECHEN:
			_activate_area("tec-rechen")
		SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_SEE_FETTFANG:
			_activate_area("tec-ff")
		SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_SEE_VKB:
			_activate_area("tec-vkb")
		SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_SEE_BB:
			_activate_area("tec-bb")
		SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_SEE_NKB:
			_activate_area("tec-nkb")
		SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_SEE_RAD:
			_activate_area("tec-rad")
		SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_SEE_VED:
			_activate_area("tec-ved")
		SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_SEE_ENTWAESSERUNG:
			_activate_area("tec-entw")
		SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_SEE_FAULUNG:
			_activate_area("tec-faulung")
		SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_SEE_GASMESSRAUM:
			_activate_area("tec-gasmess")
		SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_SEE_BHKW:
			_activate_area("tec-bhkw")
		SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_SEE_GASSPEICHER:
			_activate_area("tec-gasspeicher")
		
func _activate_area(name : String):
	var a : CHECKPOINT = checks.get_node_or_null(name)
	if a:
		a.activate()
