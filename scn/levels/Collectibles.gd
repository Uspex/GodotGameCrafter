extends Node2D

var coin_preload = preload("res://scn/collectibles/coin.tscn")

func _ready():
	Signals.connect("enemy_died", Callable (self, "_on_enemy_died"))

func _on_enemy_died(enemy_position, state):
	if state != 4:
		for i in randi_range(1, 5):
			coin_spawn(enemy_position)
			await get_tree().create_timer(0.3).timeout


func coin_spawn(poss):
	var coin = coin_preload.instantiate()
	coin.position = poss
	add_child(coin)
