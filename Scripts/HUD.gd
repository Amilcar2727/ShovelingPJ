extends CanvasLayer;
# Notifies `Main` node that the button has been pressed
signal start_game;
# Called when the node enters the scene tree for the first time.
func _ready():
	$DeathLabel.hide();
	$Message.text = "Beaver Project!";
	$StartButton.show();
	$Scores.hide();
	$ScoreP1.hide();
	$ScoreP2.hide();
	$AntenaPower.hide();
	$Logo.show();

func show_message(text):
	$Message.text = text;
	$Message.show();
	$MessageTimer.start();
func show_game_over():
	show_message("Time-Out!");
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout;
	$Message.text = "Beaver Project!";
	$Message.show();
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout;
	$StartButton.show();
func show_game_won(player:String):
	var msgWinner = str(player) + " has won!";
	if(player == "Player 1"):
		$Message.add_theme_color_override("font_color", Color(1,0.36,0.3,1));
	elif(player == "Player 2"):
		$Message.add_theme_color_override("font_color", Color(0.35,0.61,1,1));
	show_message(msgWinner);
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout;
	$Message.add_theme_color_override("font_color", Color(1,1,1,1));
	$Message.text = "Repeat?";
	$Message.show();
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout;
	$StartButton.show();
func update_time(time):
	$DeathLabel.text = str(time);
func update_score(scoreP1:String,scoreP2:String):
	$ScoreP1.text = scoreP1;
	$ScoreP2.text = scoreP2;
	
func _on_start_button_pressed():
	$StartButton.hide();
	$DeathLabel.show();
	$Scores.show();
	$ScoreP1.show();
	$ScoreP2.show();
	$Logo.hide();
	start_game.emit();

func _on_message_timer_timeout():
	$Message.hide();
