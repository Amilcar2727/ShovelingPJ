## GameData.gd
extends Node
const MODE_TUTORIAL := "TUTORIAL";
const MODE_VERSUS := "VERSUS";

#Variables globales
var num_Players:int = 1;
var mode:String = MODE_TUTORIAL;
var current_map_data:MapData;
var score_p1:int = 0;
var score_p2:int = 0;
var winner:int = 1 #p1 o p2

func _reset_score():
	#Variables globales
	score_p1 = 0;
	score_p2 = 0;
	winner = 1 #p1 o p2

func _reset_config():
	_reset_score();
	current_map_data = null;
	num_Players = 1;
	mode = MODE_TUTORIAL;
