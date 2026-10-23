extends Node


var base_move_speed: int = 100
var move_speed: int = 100
var stamina: float = 100:
	set(value):
			stamina = value
			if is_instance_valid(Global) and Global.ui:
				Global.ui.update_stamina_label(value)

var wood_stolen: int = 0:
	set(value):
			wood_stolen = value
			if is_instance_valid(Global) and Global.ui:
				Global.ui.update_wood_stolen_label(value)

var wood_carrying:int = 0:
	set(value):
			wood_carrying = value
			if is_instance_valid(Global) and Global.ui:
				Global.ui.update_wood_carrying_label(value)
				
var wood_remaining: int = 9:
	set(value):
			wood_remaining= value
			if is_instance_valid(Global) and Global.ui:
				Global.ui.update_wood_remaining_label(value)
