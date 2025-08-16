extends Node

@onready var suddenDTimer:Timer = $"../SuddenDeathTimer";
@onready var HUD:CanvasLayer = $"../HUD";
@onready var Divisor:Area2D = $"../Divisor";
@onready var WallBomb1:StaticBody2D = $"../WallBomb1";
@onready var WallBomb2:StaticBody2D = $"../WallBomb2";
const timeC :int = 20;
var suddenTime := timeC;

@export var SDObject_scene:PackedScene;
var SDObject_instance;
var ultimo_hitter;
var bomb_in_area = 0; ## Aqui 0 es para el area del jugador 1, y 1 para el 2
signal sdFinish(ultimo_hitter);

func _ready() -> void:
	suddenDTimer.timeout.connect(_on_death_timer_timeout);
	Divisor.body_exited.connect(_on_area_bomb);
	WallBomb1.get_node("CollisionShape2D").disabled = true;
	WallBomb2.get_node("CollisionShape2D").disabled = true;
	Divisor.get_node("CollisionShape2D").disabled = true;

func _on_area_bomb(_body:Node) -> void:
	bomb_in_area = 1 - bomb_in_area;
func stop_timer() -> void:
	suddenDTimer.stop();
	SDObject_instance.stop();
func _on_death_timer_timeout() -> void:
	suddenTime -= 1;
	HUD.update_time(suddenTime);
	if(suddenTime == 0):
		suddenDTimer.stop();
		print(bomb_in_area);
		##Si es 1, está en area del 2do jugador
		if bomb_in_area:
			sdFinish.emit(1);
		else: ## Si es 0, está en area del 1er jugador
			sdFinish.emit(2);
		
## Aqui llega la señal del main	
func _on_main_sudden_d_signal() -> void:
	suddenTime = timeC;
	HUD.update_time(suddenTime);
	# Paredes
	WallBomb1.get_node("CollisionShape2D").disabled = true;
	WallBomb2.get_node("CollisionShape2D").disabled = true;
	Divisor.get_node("CollisionShape2D").disabled = true;
	# Lanzamos Objeto
	a_little_push();
	# Empezamos el timer
	suddenDTimer.start();
	# Esperamos medio segundo
	await get_tree().create_timer(1).timeout;
	# Hacemos aparecer las paredes:
	WallBomb1.get_node("CollisionShape2D").disabled = false;
	WallBomb2.get_node("CollisionShape2D").disabled = false;
	Divisor.get_node("CollisionShape2D").disabled = false;
	

func a_little_push():
	var objeto = spawnObject(SDObject_instance,SDObject_scene,Vector2(1290, 384));
	add_child(objeto);
	SDObject_instance = objeto;
	objeto.whos_last_hitter.connect(on_bomba_boom);
	if objeto is RigidBody2D:
		bomb_in_area = randi_range(0,1);
		var anguloF;
		if bomb_in_area:
			anguloF = deg_to_rad(235);
			ultimo_hitter = bomb_in_area;
		else:
			anguloF = deg_to_rad(145);
			ultimo_hitter = bomb_in_area + 2;
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
