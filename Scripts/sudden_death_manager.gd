extends Node

@onready var suddenDTimer:Timer = $"../SuddenDeathTimer";
@onready var HUD:CanvasLayer = $"../HUD";
const timeC :int = 20;
var suddenTime := timeC;

@export var SDObject_scene:PackedScene;
var SDObject_instance;
var ultimo_hitter;
signal sdFinish(ultimo_hitter);

func _ready() -> void:
	suddenDTimer.timeout.connect(_on_death_timer_timeout);

func stop_timer() -> void:
	suddenDTimer.stop();

func _on_death_timer_timeout() -> void:
	suddenTime -= 1;
	HUD.update_time(suddenTime);
	if(suddenTime == 0):
		suddenDTimer.stop();
		##TODO
		sdFinish.emit(null);
	
func _on_main_sudden_d_signal() -> void:
	suddenTime = timeC;
	HUD.update_time(suddenTime);
	# Lanzamos Objeto
	a_little_push();
	# Empezamos el timer
	suddenDTimer.start();

func a_little_push():
	var objeto = spawnObject(SDObject_instance,SDObject_scene,Vector2(1280, 384));
	add_child(objeto);
	objeto.whos_last_hitter.connect(on_bomba_boom);
	if objeto is RigidBody2D:
		var anguloF = deg_to_rad(135);
		var vector_fuerza = Vector2(cos(anguloF),sin(anguloF)) * 100;
		objeto.apply_impulse(Vector2(vector_fuerza));

func on_bomba_boom(last_hitter):
	ultimo_hitter = last_hitter;
	suddenDTimer.stop();
	sdFinish.emit(ultimo_hitter);

func spawnObject(instancia,escena:PackedScene,pos:Vector2):
	instancia = escena.instantiate();
	instancia.position = pos;
	return instancia;
