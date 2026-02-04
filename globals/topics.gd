extends Node
class_name TOPICS

##TOPIC LAYER FOR POLYGONS. It's purpose is to
##show only polygons belonging to a certan layer.
enum LAYER {
	NONE = 0,
	ABWASSER = 1 << 0,
	TRINKWASSER = 1 << 1,
	ELEKTRIK = 1 << 2,	
}

##Save names here and use tr() at the end of the script.
const n_wastewater_text = "Wastewater"
const n_trinkwasser_text = "Drinking Water"
const n_elektrik_text = "Eletrotechnics"
##Names in english for each layername
const LAYERNAMES := {	
	LAYER.ABWASSER : n_wastewater_text,
	LAYER.TRINKWASSER : n_trinkwasser_text,
	LAYER.ELEKTRIK : n_elektrik_text
}


# Translation HACK
var t = [
		tr(n_wastewater_text),
		tr(n_trinkwasser_text),
		tr(n_elektrik_text)
	
]
