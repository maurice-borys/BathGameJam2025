extends Control

class_name ManaManager

@onready var win_bar: TextureProgressBar = $WinBar

@export var baseMana : float = 100.0
@export var win_mana: float = 1000.0
@onready var win_scene = preload("res://Scenes/Levels/Win.tscn")

func _ready() -> void:
	win_bar.min_value = 0.0
	win_bar.max_value = win_mana
	win_bar.value = baseMana
	GlobalVariables.mana = baseMana
	win_bar.fill_mode = TextureProgressBar.FILL_LEFT_TO_RIGHT
	
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

func _process(delta: float) -> void:
	if GlobalVariables.mana == win_mana:
		get_tree().change_scene_to_packed(win_scene)
	win_bar.value = clamp(GlobalVariables.mana, 0, win_mana)
		

		
