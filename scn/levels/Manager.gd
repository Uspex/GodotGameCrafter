extends Node

@onready var pause_menu = $"../CanvasLayer/PauseMenu"
@onready var menu_button = $"../CanvasLayer/MenuButton"

var game_pause: bool = false
var save_path = 'user://save_game.save'
@onready var player = $"../Player/Player"


func _ready():
	pause_menu.hide()

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		game_pause = !game_pause
		
	if game_pause:
		get_tree().paused = true
		pause_menu.show()
		menu_button.hide()
	else:
		get_tree().paused = false
		pause_menu.hide()
		menu_button.show()


func _on_resume_pressed():
	game_pause = !game_pause


func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scn/menu/menu.tscn")


func _on_menu_button_pressed():
	game_pause = !game_pause


func save_game():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(Global.gold)
	file.store_var(player.position.x)
	file.store_var(player.position.y)
	
func load_game():
	var file = FileAccess.open(save_path, FileAccess.READ)
	Global.gold = file.get_var(Global.gold)
	player.position.x = file.get_var(player.position.x)
	player.position.y = file.get_var(player.position.y)

func _on_save_pressed():
	save_game()
	game_pause = !game_pause


func _on_load_pressed():
	load_game()
	game_pause = !game_pause
