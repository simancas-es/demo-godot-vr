extends Node
#class_name SystemTasksResult

#Abstract class

var status : STATUS = STATUS.PENDING

enum STATUS{PENDING, EXECUTED}
enum ERROR {NO_ERROR, ERROR}
func set_parameters(dict : Dictionary) -> ERROR:
	push_warning("Function not implemented!!")
	return ERROR
	
#Result of a task being done.
#Implements logic that affects the world and other tasks potentially.

#Implement in a subclass!!
#Checks whether this result can be executed
func is_available() -> bool:
	push_warning("is_available not implemented!!")
	return false
	
#Implement in a subclass!!
#Executes the logic of the result after having 
func execute() -> bool:
	push_warning("execute not implemented!!")
	return false

func run() -> bool:
	if status == STATUS.EXECUTED: return true
	if is_available():
		if execute():
			status = STATUS.EXECUTED
			return true
	return false
