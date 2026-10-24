extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var is_animation_locked: bool = false
var is_input_locked: bool = false

@onready var walk_audio: AudioStreamPlayer2D = $SFX/WalkAudio
@onready var footstep_timer: Timer = $SFX/FootstepTimer

var is_sprinting: bool = false

func _ready() -> void:
	Global.player = self
	update_player_speed()

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if PlayerData.stamina <= 0:
		is_sprinting = false
		footstep_timer.wait_time = 0.5
		update_player_speed()
	elif is_sprinting:
		PlayerData.stamina -= delta * 30
		update_player_speed()
	if PlayerData.stamina < 100:
		PlayerData.stamina += delta * 5
		
	walking()

# Centralized function that calculates speed cleanly in one place
func update_player_speed() -> void:
	# Base speed reduced by 10% per piece of wood carried
	var current_speed = PlayerData.base_move_speed * (1.0 - (PlayerData.wood_carrying / 7.0))
	
	if is_sprinting:
		current_speed *= 1.5
		
	
	PlayerData.move_speed = max(20.0, current_speed)

func steal_wood(amount):
	PlayerData.wood_carrying += amount
	PlayerData.wood_remaining -= amount
	update_player_speed()
	print("New Speed: ", PlayerData.move_speed)
	
func die():
	get_tree().reload_current_scene()
	PlayerData.base_move_speed = 100 # Reset base if needed
	PlayerData.wood_carrying = 0
	PlayerData.wood_stolen = 0
	PlayerData.wood_remaining = 9
	PlayerData.stamina = 100
	update_player_speed()

func walking():
	if is_input_locked:
		animated_sprite.play("idle")
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)	
	
	if input_direction.length() > 0:
		input_direction = input_direction.normalized()
	
	velocity = (input_direction * PlayerData.move_speed)
		
	if not is_animation_locked:
		if velocity.x > 0 and velocity.y > 0:
			animated_sprite.play("walk_2")
		elif velocity.y < 0 and velocity.x > 0:
			animated_sprite.play("walk_4")
		elif velocity.x < 0 and velocity.y < 0:
			animated_sprite.play("walk_6")
		elif velocity.x < 0 and velocity.y > 0:
			animated_sprite.play("walk_8")
		elif velocity.y > 0:
			animated_sprite.play("walk_1")
		elif velocity.x > 0:
			animated_sprite.play("walk_3")
		elif velocity.y < 0:
			animated_sprite.play("walk_5")
		elif velocity.x < 0:
			animated_sprite.play("walk_7")
		else:
			animated_sprite.play("idle")
			
		if velocity.length() > 0:
			if footstep_timer.is_stopped():
				walk_audio.play()
				footstep_timer.start()
		else:
			footstep_timer.stop()
				
		move_and_slide()
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("sprint"):
		if PlayerData.stamina <= 0:
			return
		is_sprinting = true
		footstep_timer.wait_time = 0.3
		update_player_speed()
	elif event.is_action_released("sprint"):
		is_sprinting = false
		footstep_timer.wait_time = 0.5
		update_player_speed()
