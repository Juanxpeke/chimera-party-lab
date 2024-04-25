class_name BomberPlayer
extends CharacterBody3D

@export var speed = 5
@export var acceleration = 20

var push_direction: Vector3 = Vector3.ZERO
var _pushers: Array[CharacterBody3D] = []
var handled_bomb: Bomb = null

@onready var player_component: PlayerComponent = %PlayerComponent
@onready var push_area: Area3D = %PushArea
@onready var bomb_handler: Marker3D = %BombHandler


# Private

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	# animation_tree.active = true
	push_area.body_entered.connect(_on_body_entered)
	push_area.body_exited.connect(_on_body_exited)

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
	for pusher in _pushers:
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
		
func _on_body_entered(body: Node) -> void:
	if body != self and body is BomberPlayer:
		body.start_pushing(self)

func _on_body_exited(body: Node) -> void:
	if body != self and body is BomberPlayer:
		body.stop_pushing(self)


# Public

#region Multiplayer
func setup(player_data: PlayerData) -> void:
	player_component.setup(player_data)
#endregion

#region Physics
func start_pushing(pusher: CharacterBody3D) -> void:
	_pushers.append(pusher)

func stop_pushing(pusher: CharacterBody3D) -> void:
	_pushers.erase(pusher)
#endregion

#region Bomb
func take_bomb(bomb: Bomb):
	if handled_bomb != null:
		return
	
	bomb.activate()
	
	handled_bomb = bomb
	handled_bomb.global_position = bomb_handler.global_position
	handled_bomb.reparent(bomb_handler)
#endregion



