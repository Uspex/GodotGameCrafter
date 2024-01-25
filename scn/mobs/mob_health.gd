extends Node2D

signal no_health()
signal damage_received()

@onready var health_bar = $HealthBar
@onready var damage_text = $DamageText
@onready var animPlayer = $AnimationPlayer

@export var max_health = 100

var health = 100:
	set (value):
		health = value
		health_bar.value = max_health
		
		if health <= 0:
			health_bar.visible = false
		else:
			health_bar.visible = true
		

func _ready():
	damage_text.modulate.a = 0
	health = max_health
	health_bar.max_value = max_health
	health_bar.visible = false


func _on_hurt_box_area_entered(_area):
	await get_tree().create_timer(0.1).timeout
	health -= Global.player_damage
	
	damage_text.text = str(Global.player_damage)
	animPlayer.stop()
	animPlayer.play("damage_text")
	
	if health <= 0:
		emit_signal("no_health")
	else:
		emit_signal("damage_received")
