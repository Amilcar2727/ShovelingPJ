extends Control
func _ready() -> void:
	GameData.num_Players = 1;
	GameData.mode = GameData.MODE_TUTORIAL;
	$P2.hide();
	_on_1player();
	#Boton P1 deshabilitado por ahora
	$PlayersContainer/BtnP1.disabled = true;
	$PlayersContainer/BtnP2.modulate.a = 0.75;

func _on_1player() -> void:
	$ModeContainer/BtnLeft.disabled = true;
	$ModeContainer/BtnRight.disabled = true;
	GameData.mode = GameData.MODE_TUTORIAL;
	$ModeContainer/LabelModo.text = GameData.mode;
	$PlayersContainer/BtnP2.text = "Press 
									to Play";

func _on_2player() -> void:
	#BOTONES MODO
	$ModeContainer/BtnLeft.disabled = false;
	$ModeContainer/BtnRight.disabled = false;
	#UI Player 2
	$PlayersContainer/BtnP2.text = "";
	

func _on_btn_p_2_pressed() -> void:
	if GameData.num_Players == 1:
		GameData.num_Players = 2;
		$P2.show();
		_on_2player();
	else:
		GameData.num_Players = 1;
		$P2.hide();
		_on_1player();
		
func _on_btn_mode_pressed() -> void:
	if GameData.mode == GameData.MODE_TUTORIAL:
		GameData.mode = GameData.MODE_VERSUS;
	else:
		GameData.mode = GameData.MODE_TUTORIAL;
	$ModeContainer/LabelModo.text = GameData.mode;

func _on_btn_back_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Escenas/MainMenu.tscn");

func _on_btn_go_pressed() -> void:
	if GameData.mode == GameData.MODE_VERSUS:
		get_tree().change_scene_to_file("res://Escenas/ChoosingModeLoad.tscn");
	else:
		pass;
	print("Players: ",GameData.num_Players);
	print("Mode: ",GameData.mode);
	
