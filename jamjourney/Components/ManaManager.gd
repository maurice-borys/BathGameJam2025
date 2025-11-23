extends Control

class_name ManaManager

@onready var win_bar: ProgressBar = $WinBar

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
			
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color(0.97, 0.483, 0.683, 1.0)  # Bright green
	fill_style.border_width_bottom = 2
	fill_style.border_color = Color(0, 0, 0)
	win_bar.add_theme_stylebox_override("fill", fill_style)

	## Create visible background
	#var bg_style = StyleBoxFlat.new()
	#bg_style.bg_color = Color(0.1, 0.1, 0.1)  # Dark gray
	#bg_style.border_width_all = 2
	#bg_style.border_color = Color(0.5, 0.5, 0.5)
	#add_theme_stylebox_override("background", bg_style)

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
