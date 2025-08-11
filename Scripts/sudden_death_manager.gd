extends Node

@onready var suddenDTimer:Timer = $"../SuddenDeathTimer";
@onready var HUD:CanvasLayer = $"../HUD";
const timeC :int = 15;
var suddenTime := timeC;
signal sdFinish;

func _ready() -> void:
	suddenDTimer.timeout.connect(_on_death_timer_timeout);

func stop_timer() -> void:
	suddenDTimer.stop();

func _on_death_timer_timeout() -> void:
	suddenTime -= 1;
	HUD.update_time(suddenTime);
	if(suddenTime == 0):
		suddenDTimer.stop();
		sdFinish.emit();
	
func _on_main_sudden_d_signal() -> void:
	suddenTime = timeC;
	HUD.update_time(suddenTime);
	# Empezamos el timer
	suddenDTimer.start();
