extends Interactable

func interact() -> void:
	super.interact()
	if PlayerData.wood_carrying > 0:
		PlayerData.wood_stolen += PlayerData.wood_carrying
		PlayerData.wood_carrying = 0
		PlayerData.move_speed = PlayerData.base_move_speed
