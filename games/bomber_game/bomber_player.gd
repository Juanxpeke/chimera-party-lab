class_name BomberPlayer
extends CharacterBody3D

@export var speed = 5
@export var acceleration = 20

var push_direction: Vector3 = Vector3.ZERO
var pushers: Array[CharacterBody3D] = []

var rigid_bodies_push_force: float = 1.6

var handled_bomb: Bomb = null
var handled_bomb_throw_force: float = 4.0

@onready var player_component: PlayerComponent = %PlayerComponent
@onready var push_area: Area3D = %PushArea
@onready var bomb_handler: Marker3D = %BombHandler


# Private

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	# animation_tree.active = true
	
	push_area.body_entered.connect(_on_body_entered)
	push_area.body_exited.connect(_on_body_exited)
	
	set_process_input(false)

# Called on each physics tick
func _physics_process(delta: float) -> void:
	var move_input = Input.get_vector(
		player_component.move_left,
		player_component.move_right,
		player_component.move_up,
		player_component.move_down)
		
	var initial_direction = Vector3(move_input.x, 0.0, move_input.y)
	var direction = initial_direction
	push_direction = initial_direction
	
	# Handle pushing
	for pusher in pushers:
		var is_pushing = pusher.to_local(global_position).dot(pusher.push_direction) > 0
		if is_pushing:
			direction += pusher.push_direction.project(global_position - pusher.global_position)

	var target_velocity = speed * direction
	velocity = velocity.move_toward(target_velocity, acceleration * delta)
	
	move_and_slide()

	# animation
	if initial_direction.length() > 0.01:
		# animation_tree.set("parameters/idle/blend_position", initial_direction)
		# animation_tree.set("parameters/walk/blend_position", initial_direction)
		pass
	if velocity.length() > 50: # or (playback.get_current_node() == "walk" and target_velocity.length() > 50):
		# playback.travel("walk")
		pass
	else:
		# playback.travel("idle")
		pass
	
	process_collisions()

# Called on an input event trigger
func _input(event: InputEvent) -> void:
	if handled_bomb == null:
		return
		
	if event.is_action_pressed(player_component.action_a):
		throw_bomb()
		set_process_input(false)

# Called then a body enters the push area
func _on_body_entered(body: Node) -> void:
	if body != self and body is BomberPlayer:
		body.start_pushing(self)

# Called when a body exits the push area
func _on_body_exited(body: Node) -> void:
	if body != self and body is BomberPlayer:
		body.stop_pushing(self)


# Public

#region Multiplayer

# Setups this player with the given player data
func setup(player_data: PlayerData) -> void:
	player_component.setup(player_data)
	
#endregion

#region Physics

# Processes all the collisions
func process_collisions() -> void:
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is Bomb:
			if collider.activated:
				collider.explode()
				return
			
			collider.apply_central_impulse(-collision.get_normal() * rigid_bodies_push_force)

# Adds a pusher to the pushers array
func start_pushing(pusher: CharacterBody3D) -> void:
	pushers.append(pusher)

# Removes a pusher from the pushers array
func stop_pushing(pusher: CharacterBody3D) -> void:
	pushers.erase(pusher)
	
#endregion

#region Bomb

# Takes the given bomb
func take_bomb(bomb: Bomb):
	if handled_bomb != null:
		return
	
	bomb.activate()
	
	handled_bomb = bomb
	handled_bomb.global_position = bomb_handler.global_position
	handled_bomb.reparent(bomb_handler)
	
	set_process_input(true)

# Throws the handled bomb
func throw_bomb():
	var impulse_vector = (velocity.normalized() * 0.6 + Vector3.UP * 0.4) * velocity.length() 

	handled_bomb.reparent(get_parent())
	
	handled_bomb.freeze = false
	handled_bomb.apply_central_impulse(impulse_vector * handled_bomb_throw_force)
	
	handled_bomb = null

#endregion

#region Misc

# Dies
func die() -> void:
	rotate(Vector3.LEFT, PI / 2)
	
	set_physics_process(false)

#endregion


