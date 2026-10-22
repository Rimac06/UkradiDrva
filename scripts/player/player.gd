extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var is_animation_locked: bool = false
var is_input_locked: bool = false

@onready var walk_audio: AudioStreamPlayer2D = $SFX/WalkAudio
@onready var footstep_timer: Timer = $SFX/FootstepTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.player = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	walking()

func walking():
	if is_input_locked:
		animated_sprite.play("default")
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
