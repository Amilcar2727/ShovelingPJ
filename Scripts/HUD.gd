extends CanvasLayer;
# Notifies `Main` node that the button has been pressed
signal start_game;
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
	$Message.show();
	$MessageTimer.start();
	
func show_game_over():
	show_message("Time-Out!");
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout;
	$Message.text = "Shoveling Project!";
	$Message.show();
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(3.0).timeout;
	start_game.emit();
	
func show_game_won(player:String):
	var msgWinner = str(player) + " has won!";
	if(player == "Player 1"):
		show_message(msgWinner, Color(1,0.36,0.3,1));
	elif(player == "Player 2"):
		show_message(msgWinner, Color(0.35,0.61,1,1));
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout;
	# Make a one-shot timer and wait for it to finish.
	$Message.text = "Shoveling Project!";
	$Message.add_theme_color_override("font_color", Color(1,1,1,1));
	$Message.show();
	await get_tree().create_timer(2.0).timeout;
	start_game.emit();
	
func update_time(time):
	$TimerLabel.text = str(time);
func update_score(scoreP1:String,scoreP2:String):
	$ScoreP1.text = scoreP1;
	$ScoreP2.text = scoreP2;

func _on_message_timer_timeout():
	$Message.hide();
	
func _on_options_button_pressed() -> void:
	$GoBackGameButton.show();
	$OptionsButton.hide();

func _on_go_back_game_button_pressed() -> void:
	$GoBackGameButton.hide();
	$OptionsButton.show();
