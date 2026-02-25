extends Node3D

func _on_door_opened(_door):
	$DoorOpened.play()


func _on_door_closed(_door):
	$DoorClosed.play()
