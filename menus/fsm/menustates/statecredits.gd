extends StateMenus

@export var state_main : StateMenus

func enter():
	super()
	print("Entering Credits...")
	back()


func process_input(_event: InputEvent):
	back()
	
func exit():
	super()
	print("Exiting Credits...")
	pass
	
