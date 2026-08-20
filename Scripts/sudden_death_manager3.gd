extends Node

@onready var suddenDTimer:Timer = $"../SuddenDeathTimer";
@onready var HUD:CanvasLayer = $"../HUD";
const timeC :int = 30;
var suddenTime := timeC;

@export var SDObject_scene:PackedScene;
var SDObject_instance;

func _ready() -> void:
	suddenDTimer.timeout.connect(_on_death_timer_timeout);
	
func stop_timer() -> void:
	if !suddenDTimer.is_stopped():
		suddenDTimer.stop();
func delete()->void:
	if SDObject_instance != null:
		SDObject_instance.queue_free();
		
func _on_death_timer_timeout() -> void:
	suddenTime -= 1;
	if(suddenTime == 20):
		SDObject_instance._StartTimerLaser(3);
	if(suddenTime == 10):
		SDObject_instance._StartTimerLaser(2.5);
	if(suddenTime == 0):
		suddenDTimer.stop();
		print("Terminó el SD");
		
## Aqui llega la señal del main
func _on_main_sudden_d_signal() -> void:
	suddenTime = timeC;
	HUD.update_time("First On Die!");
	# Aparecemos black hole
	SDObject_instance = spawnObject(SDObject_scene, Vector2(0,0));
	get_tree().current_scene.add_child(SDObject_instance);
	var scene = get_tree().current_scene
	scene.changes_sd();
	var bg = scene.find_child("Background");
	var tweenBG = create_tween();
	tweenBG.tween_property(bg,"color",Color("#FF7A2F"),2)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT); #curva suave y acelera
	# Empezamos el timer
	suddenDTimer.start();
	SDObject_instance._ChangeForces(Vector2(450,600));
	SDObject_instance._StartTimerLaser();
	var tweenForce = create_tween();
	tweenForce.tween_method(
		SDObject_instance._ChangeForces,
		Vector2(450, 600),
		Vector2(650, 800),
		25
	).set_trans(Tween.TRANS_LINEAR);
	
func spawnObject(escena:PackedScene,pos:Vector2):
	var instancia = escena.instantiate();
	instancia.position = pos;
	return instancia;

func _on_player_1_hit() -> void:
	if is_instance_valid(SDObject_instance):
		if SDObject_instance.finished:
			return;
		await SDObject_instance._finish_event();
		SDObject_instance.queue_free();
func _on_player_2_hit() -> void:
	if is_instance_valid(SDObject_instance):
		if SDObject_instance.finished:
			return;
		await SDObject_instance._finish_event();
		SDObject_instance.queue_free();
