extends Node2D

@export var nextScene : PackedScene
@export var miniBoss : Node2D

var players : Array[Node2D]
var spawners : Array[Node2D]
var manaGenerators : Array[Node2D]

func _ready() -> void:
	players.assign(get_tree().get_nodes_in_group("Players").filter(func(item): return item is Node2D))
	spawners.assign(get_tree().get_nodes_in_group("Spawners").filter(func(item): return item is Node2D))
	manaGenerators.assign(get_tree().get_nodes_in_group("manaGenerators").filter(func(item): return item is Node2D))
	
	# Will you must love my coding in this project, even I wonder how this code ended up like this
	for player in players:
		player.addXp(GlobalVariables.playerXP)
		if player is not Cleric:
			player.targetArray.assign(manaGenerators + [miniBoss])
			player.completedMap.connect(nextLevel)

func _process(delta: float) -> void:
	if not is_instance_valid(miniBoss):
		nextLevel()

func nextLevel():
	get_tree().change_scene_to_packed(nextScene)
