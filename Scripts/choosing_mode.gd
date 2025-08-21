extends Control

var num_Players := 1;
var mode = "VERSUS"; #TUTORIAL

func _ready() -> void:
	num_Players = 1;
	mode = "VERSUS"
	$P2.hide();
	#Boton P1 deshabilitado por ahora
	$PlayersContainer/BtnP1.disabled = true;
	$PlayersContainer/BtnP2.text = "Press 
								to Play";
	# Botones Mode
	$ModeContainer/BtnTutorial.modulate.a = 0.5;
	$ModeContainer/BtnVersus.modulate.a = 1;
	print("Num Players = ",num_Players);

func _on_btn_p_2_pressed() -> void:
	if num_Players == 1:
		num_Players = 2;
		$P2.show();
		$LabelP2.show();
		$PlayersContainer/BtnP2.text = "";
		print("Num Players = ",num_Players);
	else:
		num_Players = 1;
		$P2.hide();
		$PlayersContainer/BtnP2.text = "Press 
									to Play";
		print("Num Players = ",num_Players);
		
func _on_btn_tutorial_pressed() -> void:
	mode = "TUTORIAL";
	$ModeContainer/BtnTutorial.modulate.a = 1;
	$ModeContainer/BtnVersus.modulate.a = 0.5;
	print("Mode: ",mode);
	
func _on_btn_versus_pressed() -> void:
	mode = "VERSUS";
	$ModeContainer/BtnTutorial.modulate.a = 0.5;
	$ModeContainer/BtnVersus.modulate.a = 1;
	print("Mode: ",mode);


func _on_btn_back_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Escenas/MainMenu.tscn");

func _on_btn_go_pressed() -> void:
	get_tree().change_scene_to_file("res://Escenas/ChoosingModeLoad.tscn");
