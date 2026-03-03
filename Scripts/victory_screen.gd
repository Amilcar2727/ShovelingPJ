extends Control
const P1Color = Color(1,0.36,0.3,1);
const P2Color = Color(0.35,0.61,1,1);
@onready var winner_lbl = $Control/WinnerLbl
@onready var loser_lbl = $Control/LoserLbl
@onready var score_winner = $Control/Node2D/ScoreWinner
@onready var score_loser = $Control/Node2D/ScoreLoser
@onready var marker_1 = $Control/Node2D/Marker2D
@onready var marker_2 = $Control/Node2D/Marker2D2

func setWinnerLoser(winnerId):
	winner_lbl.text = "P"+str(winnerId);  #1 #2, 
	loser_lbl.text = "P"+str(3-winnerId); #2 #1 #3-win
	if winnerId == 1:
		winner_lbl.add_theme_color_override("font_color",P1Color);
		loser_lbl.add_theme_color_override("font_color",P2Color);
		score_winner.set_position(marker_1.position);
		score_loser.set_position(marker_2.position);
	else:
		winner_lbl.add_theme_color_override("font_color",P2Color);
		loser_lbl.add_theme_color_override("font_color",P1Color);
		score_winner.set_position(marker_2.position);
		score_loser.set_position(marker_1.position);
	
func _ready() -> void:
	$Visuals/WinnerContainer/Crown/AnimationPlayer.play("Floating");
	$Visuals/LoserContainer/Loser/AnimationPlayer.play("FloatingFantasma");
	setWinnerLoser(GameData.winner);
	$Control/Node2D/ScoreWinner.text = str(GameData.score_p1);
	$Control/Node2D/ScoreLoser.text = str(GameData.score_p2);
	
func _on_btn_rematch_pressed() -> void:
	print("Reiniciando match!");
	GameData._reset_score();
	get_tree().change_scene_to_file(GameData.current_map_data.scene_path);
	
func _on_btn_maps_pressed() -> void:
	GameData._reset_score();
	get_tree().change_scene_to_file("res://Escenas/ChoosingMap.tscn");

func _input(event: InputEvent) -> void:
	#Reproducir animaciones winner
	pass;
	
