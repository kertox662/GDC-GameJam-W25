extends Control

func _ready() -> void:
	$ContentMargins/ContentVbox/ButtonHBox/Start.grab_focus()

func _on_start_button_down() -> void:
	get_tree().change_scene_to_file("res://game/start/pre_match.tscn")

func _on_quit_button_down() -> void:
	get_tree().quit()

func _on_credits_button_down() -> void:
	$Credits.visible = !$Credits.visible
	$Credits/CenterContainer/VBoxContainer/BackToStart.grab_focus()

func _on_back_to_start_button_down() -> void:
	$Credits.visible = !$Credits.visible
	$ContentMargins/ContentVbox/ButtonHBox/Start.grab_focus()
