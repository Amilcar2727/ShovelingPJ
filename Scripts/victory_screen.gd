extends Control

func _ready() -> void:
	$Visuals/WinnerContainer/Crown/AnimationPlayer.play("Floating");
	$Visuals/LoserContainer/Loser/AnimationPlayer.play("FloatingFantasma");

func _on_btn_rematch_pressed() -> void:
	print("Reiniciando match!");
	get_tree().change_scene_to_file("res://Escenas/Map1_Factory.tscn");
	
func _on_btn_maps_pressed() -> void:
	get_tree().change_scene_to_file("res://Escenas/ChoosingMap.tscn");

func _input(event: InputEvent) -> void:
	#Reproducir animaciones winner
	pass;
	
