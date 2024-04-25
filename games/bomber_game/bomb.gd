class_name Bomb
extends RigidBody3D

var exploding: bool = false

@onready var interactable_component: InteractableComponent3D = %InteractableComponent

# Private

# Called when the node enters the scene tree for the first time
func _ready():
	interactable_component.interacted.connect(_on_interacted)

# Called every frame. 'delta' is the elapsed time since the previous frame
func _process(delta):
	pass

# Called when a player interacts with the interactable component
func _on_interacted(player_component: PlayerComponent):
	if sleeping:
		return
	
	var bomber_player: BomberPlayer = player_component.get_parent()
	bomber_player.take_bomb(self)

# Public

# Activates the bomb
func activate():
	interactable_component.disable()
	sleeping = true
	exploding = true
