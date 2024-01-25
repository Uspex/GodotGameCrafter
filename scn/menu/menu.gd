extends Node2D

@onready var music_buttons = $MusicButtons


func _on_quit_pressed():
	music_buttons.play()
	await music_buttons.finished
	get_tree().quit()


func _on_play_pressed():
	music_buttons.play()
	await music_buttons.finished
	get_tree().change_scene_to_file.bind("res://scn/levels/level.tscn").call_deferred()
