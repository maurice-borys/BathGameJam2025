extends Node

class_name ManaManager

@export var baseMana : float = 100.0

func _ready() -> void:
	GlobalVariables.mana = baseMana
	
	var rawNodes = get_tree().get_nodes_in_group("manaGenerators")
	for raw in rawNodes:
		if raw is Generators:
			raw.manaTick.connect(add)

func can_afford(obj: Node2D) -> bool:
	return GlobalVariables.mana >= obj.mana_cost()

func buy(obj: Node2D):
	GlobalVariables.mana -= obj.mana_cost()


func add(amount):
	GlobalVariables.mana += amount
