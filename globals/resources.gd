extends Node
class_name RESOURCES

#TODO IMPORTANT: Check for files at beginning

const SystemTasksDatabase := "res://content/tasks/task_database_demo.json"
const SystemTasksText := "res://content/tasks/task_text.json"

#TODO: Redefine using uuids and decouple elements
const FPV := "res://clases/fpv/fpv.tscn"
const CAMERA_NORMAL_SKY := "res://clases/fpv/cameraenvironmentsky.tres"
const CAMERA_PANO_SKY := "res://clases/room360/cameraenvironmentpanoramasky.tres"



#General sounds
const SOUND_CLICK := "res://audio/menu/click.mp3"
const SOUND_CLICK_IN := "res://audio/menu/click_in.mp3"
const SOUND_CLICK_OUT := "res://audio/menu/click_out.mp3"
const SOUND_FLICK_IN := "res://audio/menu/flick_in.mp3"

#Item Sounds
const SOUND_VAN_ENGINE := "res://models/van/motor_encendido.mp3"

#Menus #TODO: Decouple paths so they appear only in the menu objects
const MENU_POPUP := "res://menus/infopopup/infopopup.tscn"
const MSGTOP := "res://menus/msgtop/msgtop.tscn"
const DIALOG_SIMPLE := "res://menus/dialog/dialog.tscn"
const MENU_ENVSELECT := "res://menus/environmentselector/environmentselector.tscn"
const MENU_ENVSELECT_ENTRY := "res://menus/environmentselector/entryenv.tscn"
const MENU_ENVSELECT_MAP := "res://menus/map/mappanel.tscn"

#SHADER
const SHADER_WAVYTEXT := "res://menus/msgtop/wavytext.gdshader"

#JSONS
const INFORMATION_TEMPLATE := "res://clases/panorama/informationtemplate.json"
const ZONE_DESCRIPTION_TEMPLATE := "res://clases/zones/zoneinformationtemplate.json"
const INSPECT_TRANSLATIONS_TEMPLATE := INVENTORYSETTINGS.INSPECT_TRANSLATIONS_TEMPLATE
