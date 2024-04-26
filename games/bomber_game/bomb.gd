class_name Bomb
extends RigidBody3D

var activated: bool = false
var bomber_players_in_explosion: Array[Node3D] = []

@onready var interactable_component: InteractableComponent3D = %InteractableComponent
@onready var explosion_area: Area3D = %ExplosionArea

# Private

# Called when the node enters the scene tree for the first time
func _ready():
	interactable_component.interacted.connect(_on_interacted)
	
	explosion_area.body_entered.connect(_on_explosion_body_entered)
	explosion_area.body_exited.connect(_on_explosion_body_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame
func _process(delta):
	pass

# Called when a player interacts with the interactable component
func _on_interacted(player_component: PlayerComponent):
	if activated:
		return
	
	var bomber_player: BomberPlayer = player_component.get_parent()
	bomber_player.take_bomb(self)

# Called when a body enters the explosion area
func _on_explosion_body_entered(body: Node3D) -> void:
	if body is BomberPlayer and not body in bomber_players_in_explosion:
		bomber_players_in_explosion.push_back(body)

# Called when a body exits the explosion area
func _on_explosion_body_exited(body: Node3D) -> void:
	if body in bomber_players_in_explosion:
		bomber_players_in_explosion.erase(body)


# Public

# Activates the bomb
func activate():
	interactable_component.queue_free()
	activated = true
	freeze = true

# Explodes the bomb
func explode():
	for bomber_player in bomber_players_in_explosion:
		bomber_player.die()
	
	queue_free()
