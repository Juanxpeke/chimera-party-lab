class_name Bomb
extends RigidBody3D

var activated: bool = false

var bomb_owner: BomberPlayer = null
var bomber_players_in_explosion: Array[Node3D] = []

@onready var interactable_component: InteractableComponent3D = %InteractableComponent
@onready var enemy_player_detection_area: Area3D = %EnemyPlayerDetectionArea
@onready var explosion_area: Area3D = %ExplosionArea

# Private

# Called when the node enters the scene tree for the first time
func _ready():
	enemy_player_detection_area.monitoring = false
	
	enemy_player_detection_area.monitorable = false
	explosion_area.monitorable = false
	
	interactable_component.interacted.connect(_on_interacted)
	
	enemy_player_detection_area.body_entered.connect(_on_enemy_player_detection_entered)
	
	explosion_area.body_entered.connect(_on_explosion_body_entered)
	explosion_area.body_exited.connect(_on_explosion_body_exited)

# Called when a player interacts with the interactable component
func _on_interacted(player_component: PlayerComponent):
	if activated:
		return
	
	var bomber_player: BomberPlayer = player_component.get_parent()
	bomber_player.take_bomb(self)

# Called when a body enters the enemy player detection area
func _on_enemy_player_detection_entered(body: Node3D) -> void:
	if body is BomberPlayer and body != bomb_owner:
		explode()

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
func activate(bomber_player: BomberPlayer):
	interactable_component.queue_free()
	
	bomb_owner = bomber_player
	
	enemy_player_detection_area.monitoring = true
	activated = true
	freeze = true

# Explodes the bomb
func explode():
	for bomber_player in bomber_players_in_explosion:
		#bomb_owner.player_component.add_local_score(1)
		bomber_player.die()
	
	queue_free()
