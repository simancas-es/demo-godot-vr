extends SystemTasksResult
#class_name SystemTasksResultGiveItem
const SystemTasksResult := SYSTEMTASKS_UIDCLASSREF.SystemTasksResult

@export var text : String = ""
@export var item_id : String = "Missing_item_id"
@export var amount : int = 0


func set_parameters(dict : Dictionary) -> ERROR:
	for v in dict:
		var val : Variant = dict.get(v, null)
		match v:
			"text":
				if typeof(val) == TYPE_STRING:
					self.text = val
					return ERROR.NO_ERROR
			"item_id":
				if typeof(val) == TYPE_STRING:
					self.item_id = val
					return ERROR.NO_ERROR
			"amount":
				if typeof(val) == TYPE_STRING:
					if val.is_valid_int():
						val = val.to_int()
						self.amount = val
						return ERROR.NO_ERROR
					else:
						push_warning("Cant convert to int!! %s." % val)	
						return ERROR.ERROR
					
								
	return ERROR.ERROR
				
				
#Checks whether this result can be executed
func is_available() -> bool:
	push_warning("is_available not implemented!!")
	return true
	
#Executes the logic of the result after having 
func execute() -> bool:
	print("GiveItem Result: {text}, item_id: {item_id}, amount: {amount}. ".format({"text": self.text, "item_id":self.item_id, "amount":self.amount}))
	push_error("execute not implemented!!")
	return true
	
	
	
