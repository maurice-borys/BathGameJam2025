extends Node

class_name ManaGer

var mana : int

@export var baseMana : float = 100.0
@export var spawnerCost : float = 50.0
@export var wallCost: float = 0.1

func _ready() -> void:
	mana = baseMana
	
	var rawNodes = get_tree().get_nodes_in_group("manaGenerators")
	for raw in rawNodes:
		if raw is Generators:
			raw.manaTick.connect(add)			

func can_place(obj: Variant) -> bool:
	match obj:
		GruntSpawner:
			return try_sub(spawnerCost)
		WallClass:
			var len = obj.length()
			var cost = len * wallCost
			print(cost)
			return try_sub(cost)
		_: return false

func can_afford(cost: int) -> bool:
	return mana >= cost

func spend(cost: int) -> void:
	mana -= cost

func add(amount):
	mana += amount

func try_sub(amount):
	if mana >= amount:
		mana = clamp(mana - amount, 0, INF)
		return true
	return false
