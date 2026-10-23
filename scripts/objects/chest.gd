extends Interactable

@export var wood_value: int = 1
var is_looted:bool = false
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	super._ready()

func _process(delta: float) -> void:
	if is_looted:
		return
	super._process(delta)
	
func interact() -> void:
	if is_looted:
		return
	super.interact()
	Global.player.steal_wood(wood_value)
	animated_sprite.play("open")
	is_looted = true
	
