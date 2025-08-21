extends Control


func _on_btn_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Escenas/ChoosingMode.tscn");

func _on_btn_options_pressed() -> void:
	pass # Replace with function body.

func _on_btn_credits_pressed() -> void:
	pass # Replace with function body.

func _on_btn_exit_pressed() -> void:
	get_tree().quit();
