extends Node2D

@onready var mobs = $".."
@onready var animation_player = $AnimationPlayer

var mushroom_preload = preload("res://scn/mobs/mushroom.tscn")
var skeleton_preload = preload("res://scn/mobs/skeleton.tscn")
var spawn_count = 0

func _ready():
	Signals.connect("day_time", Callable (self, "_on_time_changed"))
	
	
func _on_time_changed(state, day_count):
	spawn_count = 0
	var rng = randi_range(0, 5)
	var count_mobs = day_count + rng
	if state == 1:
		for i in count_mobs:
			animation_player.play("Spawn")
			await animation_player.animation_finished
			spawn_count += 1
			
	if spawn_count == count_mobs:
		animation_player.play("Idel")
	
	
func enemy_spawn():
	var rng = randi_range(1, 2)
	if rng == 1:
		mushroom_spawn()
	elif rng == 2:
		skeleton_spawn()
	
func skeleton_spawn():
	var skeleton = skeleton_preload.instantiate()
	skeleton.position = Vector2(self.position.x, 480)
	mobs.add_child(skeleton)

func mushroom_spawn():
	var mushroom = mushroom_preload.instantiate()
	mushroom.position = Vector2(self.position.x, 480)
	mobs.add_child(mushroom)
