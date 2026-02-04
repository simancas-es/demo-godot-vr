extends SystemTasksResult
#class_name SystemTasksResultPrint
const SystemTasksResult := SYSTEMTASKS_UIDCLASSREF.SystemTasksResult

@export var text : String = "Result SystemTasksResultUIPrint executed."


func set_parameters(dict : Dictionary) -> ERROR:
	for v in dict:
		var val : Variant = dict.get(v, null)
		match v:
			"text":
				if typeof(val) == TYPE_STRING:
					val = str(val)
					self.text = val
					return ERROR.NO_ERROR
								
	return ERROR.ERROR
				
				
#Checks whether this result can be executed
func is_available() -> bool:
	#push_warning("is_available not implemented!!") #This one is always available...
	return true
	
#Executes the logic of the result after having 
func execute() -> bool:
	Signals.ui_msg_top.emit(tr(text)) #Assume that the global Signals always exists
	return true
	
	
	
