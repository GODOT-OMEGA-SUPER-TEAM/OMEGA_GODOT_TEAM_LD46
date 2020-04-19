#tool
extends Node

export(float, 0.0, 1.0) var intensity = 0.0 setget set_intensity

export(Array, AudioStream) var tracks

var players = []

func _ready():
	for track in tracks:
		var player = AudioStreamPlayer.new()
		player.stream = track
		player.autoplay = true
		add_child(player)
		
		players.push_back(player)
	
	set_intensity(intensity)


func set_intensity(value):
	intensity = value
	var track_count = tracks.size()
	for i in track_count:
		var start_intensity = float(i - 1) / (track_count - 1)
		var end_intensity = float(i) / (track_count - 1)
		
		var volume = clamp(inverse_lerp(start_intensity, end_intensity, intensity), 0.0, 1.0)
		if players.size():
			players[i].volume_db = 10 * log(volume) - 10 # Percent to decibel.
			print(str(i) + " : " + str(players[i].volume_db))
