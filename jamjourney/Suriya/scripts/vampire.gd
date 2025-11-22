extends CharacterBody2D

var speed = 300
@onready var health_module: Health = $HealthModule 

var click_position = Vector2()
var target_position = Vector2()

@onready var timer: Timer = $Timer
@onready var bat_timer: Timer = $bat_timer

@onready var sprite: AnimatedSprite2D = $BasicAttack
@onready var hitbox: Area2D = $AttackHitbox
@onready var hitbox_shape: CollisionShape2D = $AttackHitbox/CollisionShape2D

@onready var bite_hitbox: Area2D = $BiteHitbox
@onready var bite_sprite: AnimatedSprite2D = $BiteAttack
@onready var bite_hitbox_shape: CollisionShape2D = $BiteHitbox/CollisionShape2D

@onready var vampire_sprite: AnimatedSprite2D = $VampireSprite
@onready var vampire_hitbox_shape: CollisionShape2D = $CollisionShape2D

var attacking: bool = false
var healing: bool = false
var bat_form: bool = false

func _ready():
	click_position = position
	hitbox.body_entered.connect(_on_Hitbox_body_entered)
	health_module.healthChanged.connect(health_changed)

func _process(_delta):
	if Input.is_action_just_pressed("button_1") and not attacking:
		start_attack()
	
	elif Input.is_action_just_pressed("button_2") and not attacking:

		start_bite_attack()
	
	elif Input.is_action_just_pressed("button_3") and not attacking:
		bat_form = true
		start_bat_form()

func start_attack():
	attacking = true
	hitbox_shape.disabled = false
	sprite.play("default")
	_on_basic_attack_animation_finished()

func start_bite_attack():
	healing = true
	attacking = true
	bite_hitbox_shape.disabled = false
	vampire_sprite.play("Bite")
	bite_sprite.play("default")
	_on_bite_attack_animation_finished()

func start_bat_form():
	bat_form = true
	attacking = true
	vampire_sprite.play("bat")
	bat_timer.start()
	vampire_hitbox_shape.disabled = true
	
	
func _physics_process(_delta):
	if bat_form:
		speed = 500
		
	if Input.is_action_just_pressed("left_click"):
		click_position = get_global_mouse_position()
	
	if position.distance_to(click_position) > 3:
		target_position = (click_position - position).normalized()
		velocity = target_position * speed 
		move_and_slide()

func health_changed(_old, new):
	if new <= 0:
		timer.start()

func _on_timer_timeout() -> void:
	print("dead")
	queue_free()

func _on_Hitbox_body_entered(body):
	if attacking:
		Health.findHealthModule(body).dealDamage(10)
	if healing:
		Health.findHealthModule(self).healHealth(10)
		healing = false


func _on_basic_attack_animation_finished() -> void:
	if sprite.animation == "default":
		hitbox_shape.disabled = true
		attacking = false

func _on_bite_attack_animation_finished() -> void:
	if sprite.animation == "default":
		bite_hitbox_shape.disabled = true
		attacking = false


func _on_bat_timer_timeout() -> void:
	bat_form = false
	speed = 300
	vampire_sprite.play("default")
	vampire_hitbox_shape.disabled = false
	attacking = false
