extends Node2D

func _ready():
	# Thinking of an instagator as a NPC type that is always a mob member (there should only be one).
	add_npc(Vector2(100, 100), NPC.Type.INSTIGATOR)
	add_npc(Vector2(100, 200), NPC.Type.INSTIGATOR)
	add_npc(Vector2(100, 300), NPC.Type.INSTIGATOR)
	generate_random_npcs(10)


func add_npc(position: Vector2, type):
	var new_npc = load("res://NPC.tscn")
	var npc_instance = new_npc.instance()
	npc_instance.stats.type = type
	npc_instance.position = position
	add_child(npc_instance)


func generate_random_npcs(amount):
	for _i in range(amount):
		var type = NPC.Type.DEMIHUMAN if randf() < 0.5 else NPC.Type.CLERIC
		add_npc(Vector2(rand_range(1, 800), rand_range(1, 800)), type)
