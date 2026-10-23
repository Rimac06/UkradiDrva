extends CanvasLayer

@onready var wood_stolen_label: RichTextLabel = $HUD/WoodStolenLabel
@onready var wood_carrying_label: RichTextLabel = $HUD/WoodCarryingLabel
@onready var wood_remaining_label: RichTextLabel = $HUD/WoodRemainingLabel
@onready var stamina_label: RichTextLabel = $HUD/StaminaLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.ui = self
	update_wood_stolen_label(0)
	update_wood_carrying_label(0)
	update_wood_remaining_label(0)
	update_stamina_label(PlayerData.stamina)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func update_wood_stolen_label(wood_amount):
	wood_stolen_label.text = "[img=32x32]res://assets/sprites/miscellaneous/oak_log.png[/img]: %d" % wood_amount

func update_wood_carrying_label(wood_amount):
	wood_carrying_label.text = "Carrying: %d" % wood_amount

func update_wood_remaining_label(wood_amount):
	wood_remaining_label.text = "Remaining: %d" % wood_amount
	
func update_stamina_label(amount):
	stamina_label.text = "Stamina: %d" % amount
