extends CharacterBody2D

enum {
	MOVE,
	ATTACK,
	COMBO1,
	COMBO2,
	BLOCK,
	SLIDE,
	DAMAGE,
	CAST,
	DEATH
}

const SPEED = 120.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animPlayer = $AnimationPlayer
@onready var stats = $Stats
@onready var leafs = $Leafs
@onready var smack = $Sounds/Smack

@onready var animated_sprite = $AnimatedSprite2D




var state = MOVE
var run_spead = 1
var combo = false
var attack_cooldown = false
var damage_basic = 10
var damage_multiplier = 1
var damage_current
var recovery = false 


func _ready():
	Signals.connect("enemy_attack", Callable (self, "_on_damage_received"))

func _physics_process(delta):
		# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	Global.player_damage = damage_basic * damage_multiplier
			
	set_state()
		
	move_and_slide()
	
	Global.player_pos = self.position
	
func set_state():	
	match state:
		MOVE:
			move_state()
		ATTACK:
			attack_state()
		COMBO1:
			combo1_state()
		COMBO2:
			combo2_state()
		BLOCK:
			block_state()
		SLIDE:
			slide_state()
		DAMAGE:
			damage_state()
		CAST:
			pass
		DEATH:
			deatch_state()

func move_state():
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED * run_spead
		
		if velocity.y == 0:
			if run_spead == 1:
				animPlayer.play("walk")
			else:
				animPlayer.play('run')
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0:
			animPlayer.play('idle')
			
	if direction == -1:
		animated_sprite.flip_h = true
		$AttackDirection.rotation_degrees = 180
	elif direction == 1:
		animated_sprite.flip_h = false
		$AttackDirection.rotation_degrees = 0
	
	if Input.is_action_pressed("run") and not recovery:
		stats.stamina -= stats.run_cost
		run_spead = 1.5
	else:
		run_spead = 1
			
	if Input.is_action_just_pressed('attack'):
		if not recovery:
			stats.stamina_cost = stats.attack_cost
			if attack_cooldown == false and stats.stamina > stats.stamina_cost:
				state = ATTACK
		
	if Input.is_action_just_pressed('block') and velocity.x != 0:
		if not recovery:
			stats.stamina_cost = stats.slide_cost
			if stats.stamina > stats.stamina_cost:
				state = SLIDE
	elif Input.is_action_just_pressed('block') and velocity.x == 0:
		if not recovery:
			if stats.stamina > 1:
				state = BLOCK

func attack_state():
	stats.stamina_cost = stats.attack_cost
	damage_multiplier = 1
	
	if Input.is_action_just_pressed("attack") and combo == true and stats.stamina > stats.stamina_cost:
		state = COMBO1
	
	velocity.x = move_toward(velocity.x, 0, SPEED)
	animPlayer.play('attack')
	await animPlayer.animation_finished	
	attack_freeze()
	state = MOVE
	
func combo1():
	combo = true
	await animated_sprite.animation_finished	
	combo = false
	
func combo1_state():
	stats.stamina_cost = stats.attack_cost
	damage_multiplier = 1.2
	
	if Input.is_action_just_pressed("attack") and combo == true and stats.stamina > stats.stamina_cost:
		state = COMBO2
		
	animPlayer.play('attack2')
	await animPlayer.animation_finished	
	state = MOVE

func combo2():
	combo = true
	await animated_sprite.animation_finished	
	combo = false

func combo2_state():
	damage_multiplier = 2
	animPlayer.play('attack3')
	await animPlayer.animation_finished	
	state = MOVE
	
func block_state():
	stats.stamina -= stats.block_cost
	velocity.x = move_toward(velocity.x, 0, SPEED)
	animPlayer.play('block')	
	if Input.is_action_just_released("block") or recovery:
		state = MOVE
	
func slide_state():
	animPlayer.play('slide')
	await animPlayer.animation_finished	
	state = MOVE
	
func damage_state():	
	animPlayer.play('damage')
	await animPlayer.animation_finished	
	state = MOVE

func attack_freeze():
	attack_cooldown = true
	await get_tree().create_timer(0.5).timeout
	attack_cooldown = false

func deatch_state():
	velocity.x = 0
	animPlayer.play('deatch')
	await animPlayer.animation_finished
	queue_free()
	get_tree().change_scene_to_file.bind("res://scn/menu/menu.tscn").call_deferred()
	
func _on_damage_received(enemy_damage):
	smack.play()
	await smack.finished
	if state == BLOCK:
		enemy_damage /= 2
	elif state == SLIDE:
		enemy_damage = 0
	else:
		state = DAMAGE
		damage_anim()
		
	stats.health -= enemy_damage
		
	if stats.health <= 0:
		stats.health = 0
		state = DEATH

func _on_stats_no_stamina():
	recovery = true
	await get_tree().create_timer(2).timeout
	recovery = false

func damage_anim():
	velocity.x = 0
	animated_sprite.modulate = Color(1, 0, 0, 1)
	if animated_sprite.flip_h == true:
		velocity.x += 200
	else:
		velocity.x -= 200
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(animated_sprite, "velocity", Vector2(0, 0), 0.2)
	tween.parallel().tween_property(animated_sprite, "modulate", Color(1, 1, 1, 1), 0.2)

func steps():
	leafs.emitting = true
	leafs.one_shot = true
