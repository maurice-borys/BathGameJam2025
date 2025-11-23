extends Control

@onready var startScene : PackedScene = preload("res://Scenes/Levels/mainWorld.tscn")

@onready var buttonStart : Button = $VBoxContainer/Button

func _ready() -> void:
	buttonStart.button_down.connect(pressStart)

func pressStart():
	get_tree().change_scene_to_packed(startScene)
