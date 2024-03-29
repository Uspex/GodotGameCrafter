extends CharacterBody2D
class_name Enemy
	
@onready var animPlayer = $AnimationPlayer
@onready var sprite = $AnimatedSprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var palyer = Vector2.ZERO
var direction = Vector2.ZERO
var damage = 20
var move_spead = 150


enum {
	IDLE,
	ATTACK,
	CHASE,
	DAMAGE,
	DEATH,
	RECOVER
}

#переменная типа SetGet где она Переменная, Сигнал и Функция
var state: int = 0:
	set(value):
		state = value
		match state:
			IDLE:
				idle_state()
			ATTACK:
				attack_state()
			DAMAGE:
				damage_state()
			DEATH:
				death_state()
			RECOVER:
				recover_state()
				

func _ready():
	state = CHASE
	
func _physics_process(delta):
		# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if state == CHASE:
		chase_state()
		
	move_and_slide()
	
	palyer = Global.player_pos
	

func _on_attack_range_body_entered(_body):
	state = ATTACK

func idle_state():
	velocity.x = 0
	animPlayer.play("Idle")
	state = CHASE
	
func attack_state():
	velocity.x = 0
	animPlayer.play("Attack")
	await animPlayer.animation_finished
	state = IDLE
	
func chase_state():
	animPlayer.play("Run")
	direction = (palyer - self.position).normalized()
	if direction.x < 0:
		sprite.flip_h = true
		$AttackDirection.rotation_degrees = 180
	else:
		sprite.flip_h = false
		$AttackDirection.rotation_degrees = 0
		
	velocity.x = direction.x * move_spead

func damage_state():
	velocity.x = 0
	damage_anim()
	animPlayer.play("Damage")
	await animPlayer.animation_finished
	state = IDLE
	
func death_state():
	velocity.x = 0
	animPlayer.play("Death")
	await animPlayer.animation_finished
	queue_free()
	
func recover_state():
	velocity.x = 0
	animPlayer.play("Recover")
	await animPlayer.animation_finished
	if $AttackDirection/AttackRange.has_overlapping_bodies():
		state = ATTACK
	else:
		state = IDLE
	
func _on_hit_box_area_entered(_area):
	Signals.emit_signal("enemy_attack", damage)	


func damage_anim():
	direction = (palyer - self.position).normalized()
	velocity.x = 0
	if direction.x < 0:
		velocity.x += 200
	elif direction.x > 0:
		velocity.x -= 200
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(self, "velocity", Vector2(0, 0), 0.2)


func _on_run_timeout():
	move_spead = move_toward(move_spead, randi_range(120, 170), 100)
