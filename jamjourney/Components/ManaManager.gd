extends Node

class_name ManaManager

var mana : int

@export var baseMana : float = 100.0

func _ready() -> void:
	mana = baseMana
	
	var rawNodes = get_tree().get_nodes_in_group("manaGenerators")
	for raw in rawNodes:
		if raw is Generators:
			raw.manaTick.connect(add)			

func can_afford(obj: Node2D) -> bool:
	return mana >= obj.mana_cost()

func buy(obj: Node2D):
	mana -= obj.mana_cost()

func add(amount):
	mana += amount
