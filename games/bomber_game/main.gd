extends Node3D

@export var player_scene: PackedScene

const SCORE = preload("res://games/my_game/ui/score.tscn")

@onready var players: Node3D = %Players
@onready var spawns: Node3D = %Spawns

@onready var game_timer: Timer = %GameTimer

@onready var user_interface: CanvasLayer = %UI

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	if not player_scene:
		Debug.log("No player scene selected")
		return
		
	for i in Game.players.size():
		var player_data = Game.players[i]
		var player_inst = player_scene.instantiate()
		players.add_child(player_inst)
		player_inst.setup(player_data)
		player_inst.global_position = spawns.get_child(i).global_position
		
		var score = SCORE.instantiate()
		score.setup(player_data)
		user_interface.add_child(score)
	
	game_timer.timeout.connect(_on_game_timer_timeout)
	
	InteractableManager.activate()

# Called when the game timer timeouts
func _on_game_timer_timeout() -> void:
	Game.end_game()
