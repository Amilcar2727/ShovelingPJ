extends CanvasLayer;
# Notifies `Main` node that the button has been pressed
signal start_game; #Ya no se usa :v
# Called when the node enters the scene tree for the first time.
func _ready():
	$TimerLabel.show();
	$Message.text = "Beaver Project!";
	#$Message.hide();
	#$Scores.hide();
	#$ScoreP1.hide();
	#$ScoreP2.hide();
	$AntenaPower.hide();
	$OptionsButton.hide();
	$GoBackGameButton.hide();
	
func show_message(text,color=null):
	$Message.text = text;
	if color == null:
		$Message.add_theme_color_override("font_color", Color(1,1,1,1));
	else:
		$Message.add_theme_color_override("font_color", color);
	#$MessageTimer.start();
	
func getReady(rondaN):
	show_message("Round " + str(rondaN));
	await get_tree().create_timer(1.5).timeout;
	show_message("Get Ready!");
	await get_tree().create_timer(1.5).timeout;
	show_message("Shovel!");
	await get_tree().create_timer(0.5).timeout;
	$Message.hide();
	
func show_game_over():
	show_message("Time-Out!");
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout;
	$Message.text = "Shoveling Project!";
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(3.0).timeout;
	start_game.emit();
	
func show_game_won(player:String):
	$Message.show();
	var msgWinner = str(player) + " has won!";
	if(player == "Player 1"):
		show_message(msgWinner, Color(1,0.36,0.3,1));
	elif(player == "Player 2"):
		show_message(msgWinner, Color(0.35,0.61,1,1));
	await get_tree().create_timer(4.0).timeout;
	# Wait until the MessageTimer has counted down.
	#await $MessageTimer.timeout;
	# Make a one-shot timer and wait for it to finish.
	#$Message.text = "Shoveling Project!";
	#$Message.add_theme_color_override("font_color", Color(1,1,1,1));
	#await get_tree().create_timer(2.0).timeout;
	#Wtf estaba haciendo esto aca xd
	#start_game.emit();
	
func update_time(time):
	$TimerLabel.text = str(time);
	
func update_score(scoreP1:String,scoreP2:String):
	actualizarPlayerScore(1,int(scoreP1));
	actualizarPlayerScore(2,int(scoreP2));

#func _on_message_timer_timeout():
	#$Message.hide();
	
func _on_options_button_pressed() -> void:
	$GoBackGameButton.show();
	$OptionsButton.hide();

func _on_go_back_game_button_pressed() -> void:
	$GoBackGameButton.hide();
	$OptionsButton.show();

func actualizarHijos(list,Score:int) -> void:
	if(Score > 3): ##Maximo de rondas ganadas
		return;
	for i in range(Score):
		list[i].show();
		
func actualizarPlayerScore(player,Score) -> void:
	var list:Array
	if player == 1:
		list = $P1PointsCont.get_children();
	else:
		list = $P2PointsCont.get_children();
	actualizarHijos(list, Score);
