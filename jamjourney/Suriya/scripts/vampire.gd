extends CharacterBody2D

var speed = 300
var health = 100
var atk = 10

var click_position = Vector2()
var target_position = Vector2()

@onready var timer: Timer = $Timer



func _ready():
	click_position = position
	die()


func _physics_process(delta):
	if Input.is_action_just_pressed("left_click"):
		click_position = get_global_mouse_position()
	
	if position.distance_to(click_position) > 3:
		target_position = (click_position - position).normalized()
		velocity = target_position * speed 
		move_and_slide()

func die():
	if health <= 0:
		timer.start()

func _on_timer_timeout() -> void:
	print("dead")
	queue_free()
