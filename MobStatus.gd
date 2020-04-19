extends VBoxContainer

onready var mob_count := $MobCount
onready var mob_commitment := $MobCommitment

var total_mob_commitment = 0

func _ready():
	var mob = get_mob()
	mob.connect("mob_count_changed", self, "on_mob_count_changed")
	mob.connect("npc_commitment_incremented", self, "on_mob_commitment_incremented")


func get_mob():
	return $"../../../../Mob"


func on_mob_count_changed(qnt):
	mob_count.text = "Members: %d" % get_mob().members.size()


func on_mob_commitment_incremented(increment):
	total_mob_commitment += increment
	mob_commitment.text = "Mob Commitment: %d" % total_mob_commitment
	
	# This is to test if the commitment quantity is acurate
#	var actual_commitment = 0
#	for npc in get_mob().members:
#		actual_commitment += npc.commitment
#	print("MobStatus.gd:30: Acurate Commitment: ", actual_commitment, "; Commitment displayed: ", total_mob_commitment)
