extends CharacterBody2D

var speed = 300
var health = 100

var click_position = Vector2()
var target_position = Vector2()

@onready var timer: Timer = $Timer
@onready var sprite: AnimatedSprite2D = $BasicAttack
@onready var hitbox: Area2D = $AttackHitbox
@onready var hitbox_shape: CollisionShape2D = $AttackHitbox/CollisionShape2D

var attacking: bool = false

func _ready():
	click_position = position
	die()

func _process(delta):
	if Input.is_action_just_pressed("button_1") and not attacking:
		start_attack()

func start_attack():
	attacking = true
	hitbox_shape.disabled = false
	sprite.play("default")
	_on_basic_attack_animation_finished()
	
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


func _on_basic_attack_animation_finished() -> void:
	if sprite.animation == "default":
		hitbox_shape.disabled = true
		attacking = false
