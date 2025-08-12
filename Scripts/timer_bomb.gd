extends RigidBody2D

@onready var timer = $Timer;
var time_left = 20;
@onready var label = $Label;
var last_hitter = 0;
var hitted = false;
var typeName = "TimeBomb";
signal whos_last_hitter(last_hitter);

func _on_timer_timeout() -> void:
	time_left-=1;
	label.text = str(time_left);
	if mass >= 1.3:
		mass -= 0.3;
	else:
		mass = 1.3;
	if(time_left==0):
		timer.stop();
		queue_free(); 

func stop():
	timer.stop();

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	emit_signal("whos_last_hitter",last_hitter);
	await get_tree().create_timer(1.0).timeout;
	queue_free();
