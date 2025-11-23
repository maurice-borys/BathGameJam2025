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
	
	# Will I'm sorry about this I just can't be bothered to do anything else 
	for player in players:
		if player is not Cleric:
			player.targetArray.assign(manaGenerators + [miniBoss])
		
func nextLevel():
	get_tree().change_scene_to_packed(nextScene)
