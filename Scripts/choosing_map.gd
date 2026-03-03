extends Control

var CurrentlyMap := "";
#ListaMapas
@export var maps:Array[MapData]
@onready var mapOnScreen = $MapOnScreen as TextureRect;
var current_index := 0;

func _ready() -> void:
	## PRIMER MAPA POR DEFECTO
	show_map(-1);
	$BtnStart.disabled = true;

func show_map(i:int)->void:
	if(i!=-1):
		current_index = i;
		var map_data = maps[i];
		mapOnScreen.texture = map_data.texture;
		$MapName.text = map_data.name;
		$BtnStart.disabled = false;
	else:
		$MapName.text = "-select map-";
		$BtnStart.disabled = true;
		
func _on_btn_back_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Escenas/ChoosingMode.tscn");

func _on_map_1_pressed() -> void:
	show_map(0);
	
func _on_map_2_pressed() -> void:
	show_map(1);
	
func _on_map_3_pressed() -> void:
	show_map(2);

## START X MAP
func _on_btn_start_pressed() -> void:
	if current_index == -1:
		return;
	var map_data = maps[current_index];
	GameData.current_map_data = map_data;
	get_tree().change_scene_to_file(map_data.scene_path);
