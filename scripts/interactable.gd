extends Node2D
class_name Interactable

signal interacted

@onready var area: Area2D = $Area2D
@onready var loading: TextureProgressBar = $InteractLabel/Loading
@onready var interact_label: Control = $InteractLabel
var player_in_range: bool = false

@export var hold: bool = false
var hold_timer: float = 0.0
@export var required_hold_time: float = 5.0

func _ready() -> void:
	interact_label.visible = false
	if loading:
		loading.visible = false
		loading.max_value = required_hold_time
		loading.value = 0.0
		
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	if not player_in_range or not hold:
		return

	if Input.is_action_pressed("interact"):
		hold_timer += delta
		loading.value = hold_timer
		loading.visible = true    
		
		if Global.player:
			Global.player.is_input_locked = true
			
		if hold_timer >= required_hold_time:
			print("Action completed!")
			interact()
			reset_interaction()
	else:
	
		if hold_timer > 0.0:
			print("Released early, progress reset.")
			reset_interaction()

func reset_interaction() -> void:
	hold_timer = 0.0
	if loading:
		loading.value = 0.0
		loading.visible = false
	if Global.player:
		Global.player.is_input_locked = false

func _on_body_entered(body: Node2D):
	if body == Global.player:
		print("entered")
		interact_label.visible = true
		player_in_range = true
	
func _on_body_exited(body: Node2D):
	if body == Global.player:
		print("extered")
		interact_label.visible = false
		player_in_range = false
		if hold:
			reset_interaction() 

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact") and not hold:
		interact()

func interact() -> void:
	interacted.emit()
