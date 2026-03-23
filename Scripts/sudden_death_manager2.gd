extends Node

@onready var suddenDTimer:Timer = $"../SuddenDeathTimer";
@onready var HUD:CanvasLayer = $"../HUD";
@onready var WallBomb1:StaticBody2D = $"../WallBomb1";
@onready var WallBomb2:StaticBody2D = $"../WallBomb2";
const timeC :int = 30;
var suddenTime := timeC;

@export var SDObject_scene:PackedScene;
var SDObject_instance;
var vaca_mutante;
var ultimo_hitter;

func _ready() -> void:
	suddenDTimer.timeout.connect(_on_death_timer_timeout);
	WallBomb1.get_node("CollisionShape2D").disabled = true;
	WallBomb2.get_node("CollisionShape2D").disabled = true;
	
func stop_timer() -> void:
	if !suddenDTimer.is_stopped():
		suddenDTimer.stop();
func delete()->void:
	if SDObject_instance != null:
		SDObject_instance.queue_free();
		vaca_mutante.queue_free();
		
func _on_death_timer_timeout() -> void:
	suddenTime -= 1;
	if(suddenTime == 10):
		if get_parent().has_method("_throwCow"):
			vaca_mutante = get_parent()._throwCow(true);
		if SDObject_instance.has_method("changeWaitTime"):
			SDObject_instance.changeWaitTime(0.5);
	if(suddenTime == 0):
		suddenDTimer.stop();
		print("Terminó el SD");
		
## Aqui llega la señal del main
func _on_main_sudden_d_signal() -> void:
	suddenTime = timeC;
	HUD.update_time("First On Die!");
	# Aparecemos portal
	SDObject_instance = spawnObject(SDObject_scene, Vector2(0,0));
	get_tree().current_scene.add_child(SDObject_instance);
	# Lanzamos Vaca
	a_little_push();
	# Empezamos el timer
	suddenDTimer.start();
	# Hacemos aparecer las paredes:
	WallBomb1.get_node("CollisionShape2D").disabled = false;
	WallBomb2.get_node("CollisionShape2D").disabled = false;
	
func a_little_push():
	if get_parent().has_method("_throwCow"):
		vaca_mutante = get_parent()._throwCow(true);

func spawnObject(escena:PackedScene,pos:Vector2):
	var instancia = escena.instantiate();
	instancia.position = pos;
	return instancia;
