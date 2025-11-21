extends CharacterBody2D

@export var speed = 100

var vel = Vector2.ZERO
var is_selected = false

@onready var click_area: Area2D = $ClickArea
@onready var nav_agent: NavigationAgent2D = $NavAgent

func _ready():
	add_to_group("enemies")
	click_area.input_event.connect(_on_click_area_input)
	
func _process(delta: float) -> void:
	self.velocity.x = speed
	move_and_slide()

func _on_click_area_input(viewport, event, shape_idx):
	print("CLICKED")
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			get_tree().call_group("selection", "handle_enemy_click", self)

func set_selected(selected: bool):
	is_selected = selected
	queue_redraw()

func _draw():
	if is_selected:
		draw_circle(Vector2.ZERO, 25, Color(0, 1, 0, 0.3))
		draw_arc(Vector2.ZERO, 25, 0, TAU, 32, Color(0, 1, 0), 2.0)
