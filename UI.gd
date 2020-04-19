extends CanvasLayer

const icon = preload("res://Ability.tscn")

var ability_stack = []

func register_ability(ability):
	for icon in ability_stack:
		if icon.title == ability.title:
			icon.set_count(icon.count + 1)
			return
	for i in range(ability_stack.size()):
		if ability_stack[i].title == "empty":
			ability_stack[i].parse_ability(ability)
			return
	var ic = icon.instance()
	ic.set_button(ability_stack.size()) # TODO
	ic.parse_ability(ability)
	ability_stack.append(ic)
	$Abilities.add_child(ic)


func remove_ability(ability):
	for icon in ability_stack:
		if icon.title == ability.title:
			icon.remove_ability()

