extends CharacterBody2D

var dir : Vector2
@export var damage = 100
@export var speed = 600
@onready var hitbox : Area2D = $Hitbox
@onready var body : CollisionShape2D = $Hitbox/CollisionShape2D
@onready var moving_anim : AnimatedSprite2D = $moving
@onready var explode_anim : AnimatedSprite2D = $Explosion/ExplosionAnimation
@onready var explode_body : CollisionShape2D = $Explosion/CollisionShape2D
@onready var explode_area : Area2D = $Explosion
@onready var despawn_timer : Timer = $despawn_timer



func _ready() -> void:
	hitbox.body_entered.connect(_on_Hitbox_body_entered)
	explode_body.disabled = true
	despawn_timer.start()

	look_at(get_global_mouse_position())
	dir = global_position.direction_to(get_global_mouse_position())
	
func _physics_process(_delta: float) -> void:
	velocity = dir * speed 
	moving_anim.play("default")
	
	move_and_slide()
	

func _on_Hitbox_body_entered(body):
	speed = 0
	moving_anim.stop()
	explode(body)
	
	
func explode(body):
	hitbox.disabled = true
	explode_body.disabled = false
	explode_anim.play("default")
	_on_explode_Hitbox_entered(body)
	_on_explode_anim_finished()
	
func _on_explode_anim_finished():
	if explode_anim.animation == "default":
		explode_body.disabled = true
		queue_free()
		
func _on_explode_Hitbox_entered(body):
	Health.findHealthModule(body).dealDamage(damage)

func _on_despawn_timer_timeout() -> void:
	queue_free()
