extends Control

func _on_start_pressed():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://map.tscn")


func _on_credits_pressed():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Credits.tscn")


func _on_quit_pressed():
	get_tree().quit()
