extends CharacterBody2D

var speed = 300
var damage = 50

@onready var health_module: Health = $HealthModule
@onready var sprite: AnimatedSprite2D = $BasicAttack
@onready var hitbox: Area2D = $AttackHitbox
@onready var hitbox_shape: CollisionShape2D = $AttackHitbox/CollisionShape2D

@onready var death_timer: Timer = $death_timer

@export var teleport_range : float = 300

var click_position = Vector2()
var target_position = Vector2()

var attacking = false

func _ready():
	click_position = position
	hitbox.body_entered.connect(_on_Hitbox_body_entered)
	health_module.healthChanged.connect(health_changed)

func _process(_delta):
	if Input.is_action_just_pressed("button_1") and not attacking:
		start_attack()
	if Input.is_action_just_pressed("button_2") and not attacking:
		start_teleport()
	
	
func _physics_process(_delta):
	if Input.is_action_just_pressed("left_click"):
		click_position = get_global_mouse_position()
	
	if position.distance_to(click_position) > 3:
		target_position = (click_position - position).normalized()
		velocity = target_position * speed
		move_and_slide()
		
func start_attack():
	attacking = true
	hitbox_shape.disabled = false
	sprite.play("default")
	_on_basic_attack_animation_finished()

func start_teleport():
	attacking = true
	if global_position.distance_to(get_global_mouse_position()) <= teleport_range:
		global_position = get_global_mouse_position()
		click_position = get_global_mouse_position()
		
	attacking = false
	

func health_changed(_old, new):
	if new <= 0:
		death_timer.start()




func _on_basic_attack_animation_finished() -> void:
	if sprite.animation == "default":
		hitbox_shape.disabled = true
		attacking = false
		
func _on_Hitbox_body_entered(body):
	if attacking:
		Health.findHealthModule(body).dealDamage(damage)


func _on_death_timer_timeout() -> void:
	print("dead")
	queue_free()
