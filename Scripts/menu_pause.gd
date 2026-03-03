extends CanvasLayer

func _ready() -> void:
	self.visible = false;
	
func open():
	call_deferred("_do_open");
	
func close():
	call_deferred("_do_close");
	
func _do_open():
	self.visible = true;
	get_tree().paused = true;
	
func _do_close():
	get_tree().paused = false;
	self.visible = false;
	
##Input
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and visible: #Salir de la pausa
		close();
			
## Llamadas a botones
func _on_btn_reanudar_pressed() -> void:
	close();
	
func _on_btn_re_match_pressed() -> void:
	get_tree().paused = false;
	GameData._reset_score();
	get_tree().reload_current_scene();
	
func _on_btn_go_maps_pressed() -> void:
	get_tree().paused = false;
	GameData._reset_score();
	get_tree().change_scene_to_file("res://Escenas/ChoosingMap.tscn");
	
func _on_btn_main_menu_pressed() -> void:
	get_tree().paused = false;
	GameData._reset_config();
	get_tree().change_scene_to_file("res://Escenas/MainMenu.tscn");
