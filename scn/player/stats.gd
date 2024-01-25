extends CanvasLayer

signal no_stamina()

@onready var health_bar = $HealthBar
@onready var stamina_bar = $Stamina
@onready var health_text = $"../HealthText"
@onready var health_anim = $"../HealthAnim"
			
var stamina_cost = 0
var attack_cost = 10
var block_cost = 0.5
var slide_cost = 20
var run_cost = 0.3

var min_stamina = 0
var max_stamina = 100
var stamina = 50:
	set(value):
		stamina = clamp(value, min_stamina, max_stamina)
		if stamina < 1:
			emit_signal("no_stamina")


var min_health = 0
var max_health = 120
var old_health = max_health
var health:
	set(value):
		health = clamp(value, min_health, max_health)
		health_bar.value = health
		var difference = health - old_health
		old_health = health
		
		health_text.text = str(difference)
		if difference < 0:
			health_anim.play("damage_received")
		elif difference > 0:
			health_anim.play("health_received")

func _ready():
	health_text.modulate.a = 0
	health = max_health
	health_bar.max_value = health
	health_bar.value = health

func _process(delta):
	stamina_bar.value = stamina
	stamina += 10 * delta
		

func stamina_consumption():
	stamina -= stamina_cost

func _on_health_regen_timeout():
	health += 1
