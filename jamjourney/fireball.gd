extends CharacterBody2D

var dir : float
var spawn_pos : Vector2
var spawn_rot : float
@export var damage = 100
@export var speed = 600
@onready var hitbox : Area2D = $Hitbox
@onready var body : CollisionShape2D = $Hitbox/CollisionShape2D
@onready var explode_anim : AnimatedSprite2D = $Explosion/ExplosionAnimation
@onready var explode_body : CollisionShape2D = $Explosion/CollisionShape2D
@onready var explode_area : Area2D = $Explosion
@onready var despawn_timer : Timer = $despawn_timer



func _ready() -> void:
	global_position = spawn_pos
	global_rotation = spawn_rot
	hitbox.body_entered.connect(_on_Hitbox_body_entered)
	explode_body.disabled = true
	despawn_timer.start()
	
func _physics_process(_delta: float) -> void:
	velocity = Vector2(0,-speed).rotated(dir)
	move_and_slide()

func _on_Hitbox_body_entered(body):
	speed = 0
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
