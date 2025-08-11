extends RigidBody2D

@onready var timer = $Timer;
var time_left = 15;
@onready var label = $Label;

func _on_timer_timeout() -> void:
	time_left-=1;
	label.text = str(time_left);
	print(time_left);
	if(time_left==0):
		timer.stop();
		get_parent().queue_free();
