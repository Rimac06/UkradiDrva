extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var fov: Area2D = $FOV

var is_animation_locked: bool = false
var is_input_locked: bool = false

@export var move_speed: float = 80.0
@export var chase_speed: float = 120.0 
@export var waypoints: Array[Node2D] 
var current_waypoint_index: int = 0

enum State { WANDER, CHASE }
var current_state: State = State.WANDER

@onready var death_area: Area2D = $DeathArea

var player_in_fov: bool = false

func _ready() -> void:
	fov.body_entered.connect(_on_fov_body_entered)
	fov.body_exited.connect(_on_fov_body_exited)

func _physics_process(delta: float) -> void:
	if is_input_locked:
		animated_sprite.play("idle")
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if Global.player and player_in_fov and has_line_of_sight():
		current_state = State.CHASE
	else:
		current_state = State.WANDER

	match current_state:
		State.WANDER:
			handle_wander_state()
		State.CHASE:
			handle_chase_state()

	update_animation_and_rotation()
	move_and_slide()

func has_line_of_sight() -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, Global.player.global_position)
	
	query.exclude = [self]
	

	var result = space_state.intersect_ray(query)
	if result:
		return result.collider == Global.player
		
	return false

func handle_wander_state() -> void:
	if waypoints.is_empty():
		velocity = Vector2.ZERO
		return

	var target_waypoint = waypoints[current_waypoint_index]
	var direction = global_position.direction_to(target_waypoint.global_position)
	
	velocity = direction * move_speed
	
	if global_position.distance_to(target_waypoint.global_position) < 5.0:
		current_waypoint_index = (current_waypoint_index + 1) % waypoints.size()

func handle_chase_state() -> void:
	if Global.player:
		var direction = global_position.direction_to(Global.player.global_position)
		velocity = direction * chase_speed
	else:
		current_state = State.WANDER

func _on_fov_body_entered(body: Node2D) -> void:
	if body == Global.player:
		player_in_fov = true

func _on_fov_body_exited(body: Node2D) -> void:
	if body == Global.player:
		player_in_fov = false

func update_animation_and_rotation() -> void:
	if not is_animation_locked:
		if velocity.length() == 0:
			animated_sprite.play("idle")
			fov.rotation_degrees = 0
		else:
			var angle = rad_to_deg(velocity.angle())
			
			if angle >= -22.5 and angle < 22.5:
				animated_sprite.play("walk_3") 
				fov.rotation_degrees = 270
			elif angle >= 22.5 and angle < 67.5:
				animated_sprite.play("walk_2")
				fov.rotation_degrees = 315
			elif angle >= 67.5 and angle < 112.5:
				animated_sprite.play("walk_1") 
				fov.rotation_degrees = 0
			elif angle >= 112.5 and angle < 157.5:
				animated_sprite.play("walk_8")
				fov.rotation_degrees = 45
			elif angle >= 157.5 or angle < -157.5:
				animated_sprite.play("walk_7")
				fov.rotation_degrees = 90
			elif angle >= -157.5 and angle < -112.5:
				animated_sprite.play("walk_6") 
				fov.rotation_degrees = 135
			elif angle >= -112.5 and angle < -67.5:
				animated_sprite.play("walk_5")
				fov.rotation_degrees = 180
			elif angle >= -67.5 and angle < -22.5:
				animated_sprite.play("walk_4")
				fov.rotation_degrees = 225
			else:
				animated_sprite.play("idle")
				fov.rotation_degrees = 0


func _on_death_area_body_entered(body: Node2D) -> void:
	if body == Global.player and current_state == State.CHASE:
		Global.player.die()
