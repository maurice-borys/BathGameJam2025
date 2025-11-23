extends CharacterBody2D

@onready var health_module: Health = $HealthModule 

@export var speed = 300
@export var damage = 10
var click_position = Vector2()
var target_position = Vector2()

@onready var nav_component: NavComponent = $NavComponent

@onready var timer: Timer = $death_timer
@onready var bat_timer: Timer = $bat_timer
@onready var bite_cooldown: Timer = $bite_cooldown
@onready var transform_cooldown: Timer = $transform_cooldown

@onready var sprite: AnimatedSprite2D = $pivot/BasicAttack

@onready var hitbox: Area2D = $pivot/AttackHitbox
@onready var hitbox_shape: CollisionShape2D = $pivot/AttackHitbox/CollisionShape2D

@onready var bite_hitbox: Area2D = $pivot/BiteHitbox
@onready var bite_sprite: AnimatedSprite2D = $pivot/BiteAttack
@onready var bite_hitbox_shape: CollisionShape2D = $pivot/BiteHitbox/CollisionShape2D

@onready var vampire_sprite: AnimatedSprite2D = $VampireSprite
@onready var vampire_hitbox_shape: CollisionShape2D = $CollisionShape2D

@onready var pivot: Node2D = $pivot

var attacking: bool = false
var healing: bool = false
var bat_form: bool = false
var bite_avaliable: bool = true
var bat_available: bool = true

func _ready():
	add_to_group("enemies")
	click_position = position
	hitbox.body_entered.connect(_on_Hitbox_body_entered)
	bite_hitbox.body_entered.connect(_on_Hitbox_body_entered)
	health_module.healthChanged.connect(health_changed)
	sprite.animation_finished.connect(_on_basic_attack_animation_finished)
	bite_sprite.animation_finished.connect(_on_bite_attack_animation_finished)

func _process(_delta):

	if Input.is_action_just_pressed("button_1") and not attacking:
		start_attack()
		pivot.rotation = global_position.direction_to(get_global_mouse_position()).angle() - PI
		
	
	elif Input.is_action_just_pressed("button_2") and not attacking and bite_avaliable:
		start_bite_attack()
		pivot.rotation = global_position.direction_to(get_global_mouse_position()).angle() - PI
		
	elif Input.is_action_just_pressed("button_3") and not attacking and bat_available:
		bat_form = true
		start_bat_form()
		pivot.rotation = global_position.direction_to(get_global_mouse_position()).angle() - PI

func start_attack():
	print("attack")
	attacking = true
	hitbox_shape.disabled = false
	sprite.play("default")
	

func start_bite_attack():
	print("bite")
	healing = true
	attacking = true
	bite_hitbox_shape.disabled = false
	bite_avaliable = false
	vampire_sprite.play("Bite")
	bite_sprite.play("default")

func start_bat_form():
	bat_form = true
	attacking = true
	bat_available = false
	vampire_sprite.play("bat")
	bat_timer.start()
	transform_cooldown.start()
	vampire_hitbox_shape.disabled = true
	
	
func _physics_process(_delta):
	if bat_form:
		nav_component.nav_agent.max_speed = 500.0
		speed = 500
		
	nav_component.navigate()
		
	#if Input.is_action_just_pressed("left_click"):
	#	click_position = get_global_mouse_position()
	#
	#if position.distance_to(click_position) > 3:
	#	target_position = (click_position - position).normalized()
	#	velocity = target_position * speed 
	#	move_and_slide()

func health_changed(_old, new):
	if new <= 0:
		timer.start()

func _on_timer_timeout() -> void:
	print("dead")
	queue_free()

func _on_Hitbox_body_entered(body):
	if attacking:
		Health.findHealthModule(body).dealDamage(damage)
		print("dealt: " + str(damage) + "damage")
	if healing:
		health_module.healHealth(damage)
		healing = false
		print("healed: " + str(damage) + " health, health: " + str(health_module.getHealth()))


func _on_basic_attack_animation_finished() -> void:
	if sprite.animation == "default":
		hitbox_shape.disabled = true
		attacking = false

func _on_bite_attack_animation_finished() -> void:
	if bite_sprite.animation == "default":
		bite_hitbox_shape.disabled = true
		attacking = false
	bite_cooldown.start()


func _on_bat_timer_timeout() -> void:
	bat_form = false
	speed = 300
	vampire_sprite.play("default")
	vampire_hitbox_shape.disabled = false
	attacking = false


func _on_bite_cooldown_timeout() -> void:
	bite_avaliable = true

func _on_transform_cooldown_timeout() -> void:
	bat_available = true


func _on_nav_component_computed_velocity(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()
