extends Control

func _on_back_pressed():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Start.tscn")
