extends Control

func _on_start_pressed():
	MusicManager.intensity = 1.0
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://map.tscn")


func _on_credits_pressed():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Credits.tscn")


func _on_quit_pressed():
	OS.window_fullscreen = false
	get_tree().quit()
