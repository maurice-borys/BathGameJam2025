extends CharacterBody2D

class_name Grunt

signal goto_command_path_start(path: CommandPath)

@export var speed: float = 100.0
@export var damadge: float = 1.0

@onready var nav_component: NavComponent = $NavComponent
@onready var attack_timer: Timer = $AttackTimer
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var sprite: Sprite2D = $Sprite
@onready var health_module: Health = $HealthModule

var holding = false
var pointer_node: Node2D
var target: Node2D
var follow: CommandPath
var vel = Vector2.ZERO
var is_selected = false

func _ready():
	add_to_group("enemies")
	nav_component.target_player()

func _physics_process(delta: float) -> void:
	nav_component.navigate()
	if health_module.getHealth() <= 0.0:
		queue_free()

func _on_nav_component_computed_velocity(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()

func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	attack_timer.start()
	
func _on_attack_timer_timeout() -> void:
	for body in attack_hitbox.get_overlapping_bodies():
		if body.is_in_group("player"):
			var health = Health.findHealthModule(body)
			if health:
				health.dealDamage(damadge)
				
