extends Label

var time = 0

func _process(delta):
	time += delta
	rect_rotation = sin(time)
