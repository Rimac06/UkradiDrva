extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var is_animation_locked: bool = false
var is_input_locked: bool = false

@onready var walk_audio: AudioStreamPlayer2D = $SFX/WalkAudio
@onready var footstep_timer: Timer = $SFX/FootstepTimer

var is_sprinting: bool = false

func _ready() -> void:
	Global.player = self

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if PlayerData.stamina <= 0:
		# Fixed: changed 10 to 10.0 for proper float division
		PlayerData.move_speed = PlayerData.base_move_speed * (1.0 - PlayerData.wood_carrying / 10.0 + 0.05)
		footstep_timer.wait_time = 0.5
		is_sprinting = false
	elif is_sprinting:
		PlayerData.stamina -= delta * 30
	elif PlayerData.stamina < 100:
		PlayerData.stamina += delta * 5
		
	walking()
	
func steal_wood(amount):
	PlayerData.wood_carrying += amount
	PlayerData.wood_remaining -= amount
	PlayerData.move_speed = PlayerData.base_move_speed * (1.0 - (PlayerData.wood_carrying / 10.0 + 0.05))
	print(PlayerData.move_speed)
	
func die():
	get_tree().reload_current_scene()
	PlayerData.move_speed = PlayerData.base_move_speed
	PlayerData.wood_carrying = 0
	PlayerData.wood_stolen = 0
	PlayerData.wood_remaining = 9
	PlayerData.stamina = 100

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
		PlayerData.move_speed *= 1.5
		footstep_timer.wait_time = 0.3
		is_sprinting = true
	elif event.is_action_released("sprint"):
		# Fixed: changed 10 to 10.0 here as well
		PlayerData.move_speed = PlayerData.base_move_speed * (1.0 - PlayerData.wood_carrying / 10.0 + 0.05)
		footstep_timer.wait_time = 0.5
		is_sprinting = false
