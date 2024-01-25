extends Node2D

@onready var dayText = $CanvasLayer/DayText
@onready var player = $Player/Player
@onready var light_animation = $Light/LightAnimation



enum {
	MORNING,
	DAY,
	EVENING,
	NIGHT
}
var state = 0
var change_light_time = 20
var dayCount:int

func _ready():
	dayCount = 0
	Global.gold = 0
	morning_state()

func morning_state():
	dayCount += 1
	dayText.text = "Day " + str(dayCount)
	light_animation.play("sunrise")
	
func evening_state():
	light_animation.play("sunset")


func _on_day_night_timeout():
	if state < 3:
		state += 1
	else:
		state = 0
		
	match state:
		MORNING:
			morning_state()
		EVENING:
			evening_state()
		
	Signals.emit_signal("day_time", state, dayCount)



