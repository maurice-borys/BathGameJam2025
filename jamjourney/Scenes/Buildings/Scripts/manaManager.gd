extends Node2D

var mana : int

@onready var wallScene : PackedScene = preload("res://Jericho Area No Touchy/Buildings/wall.tscn")
@onready var spawnerScene : PackedScene = preload("res://Will/spawner.tscn")

@export var navMesh : NavigationRegion2D
@export var baseMana : int = 100
@export var spawnerCost : int = 5

func _ready() -> void:
	mana = baseMana
	
	var rawNodes = get_tree().get_nodes_in_group("manaGenerators")
	for raw in rawNodes:
		if raw is Generators:
			raw.manaTick.connect(moo)
			
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("right_click"):
		placeWall()

func placeWall():
	var wallObj : WallClass = wallScene.instantiate()
	wallObj.position = get_global_mouse_position()
	wallObj.rebakeMesh.connect(tooMuchBake)
	wallObj.loseMana.connect(boo)
	wallObj.deleteWall.connect(deleteWall)
	navMesh.add_child(wallObj)

func placeSpawner():
	var spawnerObj : Node2D = spawnerScene.instantiate()
	spawnerObj.position = get_global_mouse_position()
	get_tree().current_scene.add_child(spawnerObj)

func tooMuchBake():
	navMesh.bake_navigation_polygon()
	
func deleteWall(body : Node2D):
	body.get_parent().remove_child(body)
	body.queue_free()
	navMesh.bake_navigation_polygon()

func moo(amount):
	mana += amount
	print(mana)

func boo(amount):
	mana = clamp(mana - amount, 0, INF)
