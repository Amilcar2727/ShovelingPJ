extends Node

@export var box_scene: PackedScene;
@export var garbage_scene: PackedScene;
@export var oxygenbomb_scene : PackedScene;
@export var anim_camera_manager:Node;
@export var prob_apagon:=0.15;
##Para cambio de direccion de las cintas
@export var cambio_dir_prob := 0.15;
var cambio_dir_prob_actual := 0.15;
var prob_min:=0.03;
var prob_incremento :=0.01;

var cinta_dir := 1;
var cinta_vel := 7;
var cambiando_cinta := false;

var spawn_phase := 0
const Initialtime:int = 60;
var deathTime:int = Initialtime;
var rondaN = 1;
var rondaT := false;
@onready var player1 := $Player1;
@onready var player2 := $Player2;
@onready var HUD = $HUD;
@onready var pauseMenu = $MenuPause; 
#ElPeneDeDavidCHEstuvoAqui
#Yonieskbro:awawa
#rAnatieneelanoasibiengrande- anton
#antonesunhomosexualLamecaca- eylleen

# SuddenDeath
signal suddenDSignal;
@onready var suddenManager:Node = $"SuddenDeathManager";
var onSDEvent := false;
## Minieventos
var onDark = false;
# Called when the node enters the scene tree for the first time.
func _ready():
	#Asignamos las acciones del Input Map para player 1
	player1.left_action = "player1_left";
	player1.right_action = "player1_right";
	player1.shovel_action = "player1_shovel";
	player1.shovel_up_action = "player1_shovel_up";
	#Asignamos las acciones del Input Map para player 2
	player2.left_action = "player2_left";
	player2.right_action = "player2_right";
	player2.shovel_action = "player2_shovel";
	player2.shovel_up_action = "player2_shovel_up";
	$Background.hide();
	$BackgroundScn1.show();
	$CintasAbajo.show();
	$CintasArriba.show();
	$BombasSD/BombasSDArriba.hide();
	$BombasSD/BombasSDAbajo.hide();
	$BombasSD.hide();
	#Nro ronda
	rondaN = 1;
	#SuddenDeath
	suddenManager.sdFinish.connect(_on_sdFinish);
	onSDEvent = false;
	
	##Empezar animacion inicial
	on_animation();
	player1.show();
	player2.show();
	await anim_camera_manager.animationCameraInitPlay()
	##Nuevo juego
	new_game();

##Input
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if !get_tree().paused: #Si pausamos
			pauseMenu.open();
	
func on_animation():
	HUD.hide();
	player1.can_move = false;
	player2.can_move = false;
	
func new_game():
	rondaT = false;
	deathTime = Initialtime;
	$Background.hide();
	$BackgroundScn1.show();
	$CintasAbajo.show();
	$CintasArriba.show();
	$BombasSD/BombasSDAbajo.show();
	$BombasSD/BombasSDArriba.show();
	$BombasSD.hide();
	#Cintas animacion
	AnimacionesStop($CintasAbajo);
	AnimacionesStop($CintasArriba);
	HUD.show();
	HUD.update_time(deathTime);
	#HUD.show_message("Get Ready!");
	player1.start($StartPositionP1.position);
	player1.orientation = "right";
	player1.scale.x = 1;
	player2.start($StartPositionP2.position);
	player2.rotation = deg_to_rad(180);
	player2.scale.x = -1;
	player2.orientation = "right";
	if !$Music.playing:
		$Music.play();
	get_tree().call_group("box","queue_free");
	onSDEvent = false;
	suddenManager.stop_timer();
	if suddenManager.SDObject_instance != null:
		suddenManager.SDObject_instance.queue_free();
	#Start game
	# Momento entre rondas
	#Movimiento
	player1.can_move = false;
	player2.can_move = false;
	await HUD.getReady(rondaN);
	cinta_dir = 1;
	#Cintas animacion
	DirectionCintas(7,cinta_dir);
	refresh_phase();
	$Conveyor.play();
	#Movimiento
	player1.can_move = true;
	player2.can_move = true;
	$BoxTimer.start();
	$DeathTimer.start();
	$LightningTimer.start();

## Cambiar direccion de las cintas transportadoras
func swap_cintas_direction():
	if cambiando_cinta:
		return;
	if deathTime > 55: #Para no iniciar a cambiar desde el inicio
		return;
	var ran = randf();
	if ran > cambio_dir_prob_actual:
		cambio_dir_prob_actual = min(cambio_dir_prob_actual + prob_incremento, cambio_dir_prob)
		print(cambio_dir_prob_actual);
		return;
	
	cambiando_cinta = true;
	cambio_dir_prob_actual = prob_min;
	print("Cambiando direccion!")
	## 1. Dado q ya estamos moviendonos, detenemos
	AnimacionesPause($CintasArriba);
	AnimacionesPause($CintasAbajo);
	BaseBox.direction_all = 0;
	var temp = Vector2(player1.fuerzaEmpujeCinta, player2.fuerzaEmpujeCinta);
	player1.fuerzaEmpujeCinta = 0;
	player2.fuerzaEmpujeCinta = 0;
	await get_tree().create_timer(0.6,false).timeout;
	## 2. Invertimos direccion
	cinta_dir *= -1
	## 3. Reactivamos
	DirectionCintas(cinta_vel, cinta_dir);
	## Ajustamos tambien fuerza de jugadores
	player1.fuerzaEmpujeCinta = -temp.x;
	player2.fuerzaEmpujeCinta = -temp.y;
	
	cambiando_cinta = false
	

func DirectionCintas(vel=7, dir=1):
	cinta_vel = vel;
	cinta_dir = dir;
	print("Direccion Cintas:",cinta_dir);
	AnimacionesStart($CintasArriba,vel * dir);
	AnimacionesStart($CintasAbajo,vel * dir);
	BaseBox.direction_all = -1*dir;

func AnimacionesStart(nodoPadre:Node2D, speed:float=1.0):
	for child in nodoPadre.get_children():
		if child is AnimatedSprite2D:
			child.speed_scale = speed;
			child.play();

func AnimacionesStop(nodoPadre:Node2D):
	for child in nodoPadre.get_children():
		if child is AnimatedSprite2D:
			child.stop();

func AnimacionesPause(nodoPadre:Node2D):
	for child in nodoPadre.get_children():
		if child is AnimatedSprite2D:
			child.pause();
			
func calculate_spawn_phase(time_left:int) -> int:
	if time_left > 40:
		return 1;
	elif time_left > 20:
		return 2;
	else:
		return 3;
func apply_spawn_phase(phase:int):
	match phase:
		1:
			$BoxTimer.wait_time = 1;
			prob_apagon = 0.05;
			#DirectionCintas(7);
			player1.fuerzaEmpujeCinta = -110*cinta_dir;
			player2.fuerzaEmpujeCinta = -110*cinta_dir;
			BaseBox.speed_all = 100;
		2:
			$BoxTimer.wait_time = 0.75;
			prob_apagon = 0.10;
			DirectionCintas(9,cinta_dir);
			player1.fuerzaEmpujeCinta = -160*cinta_dir;
			player2.fuerzaEmpujeCinta = -160*cinta_dir;
			BaseBox.speed_all = 115;
		3:
			$BoxTimer.wait_time = 0.5;
			prob_apagon = 0.15;
			DirectionCintas(12,cinta_dir);
			player1.fuerzaEmpujeCinta = -200*cinta_dir;
			player2.fuerzaEmpujeCinta = -200*cinta_dir;
			BaseBox.speed_all = 130;
			
	print("Wait_time: ",$BoxTimer.wait_time);
	print("Prob_apagon: ",prob_apagon);
			
func _on_box_timer_timeout():
	if BaseBox.direction_all == 0:
		return;
	var throwable;
	var type = BaseBox.elegirCajaType(spawn_phase);
	var spawn = randi_range(0,1);
	var diferencia;
	if type == 1:
		throwable = box_scene.instantiate();
		diferencia = Vector2.ZERO;
	elif type == 2:
		throwable = garbage_scene.instantiate();
		diferencia = Vector2(0,-17);
	elif type == 3:
		throwable = oxygenbomb_scene.instantiate();
		diferencia = Vector2(0,-20);
	else:
		return;
	if spawn == 0:
		if cinta_dir == 1:
			throwable.position = $SpawnBoxesRP1.position + diferencia;
		else:
			throwable.position = $SpawnBoxesLP1.position + diferencia;
	elif spawn == 1:
		if cinta_dir == 1:
			throwable.position = $SpawnBoxesRP2.position - diferencia;
		else:
			throwable.position = $SpawnBoxesLP2.position - diferencia;
	## == Spawneamos la caja agregandolo a la escena:
	add_child(throwable);
	
func game_over_by_time():
	HUD.show_game_over();
	$BoxTimer.stop();
	$Music.stop();

func _makeDark():
	onDark = true;
	$Background.show();
	$Background/AnimationPlayer.play("Lightning_off");
	await $Background/AnimationPlayer.animation_finished;
	player1._on_dark(true);
	player2._on_dark(true);
	$DarkTimer.start();

func refresh_phase():
	var new_phase = calculate_spawn_phase(deathTime);
	if new_phase != spawn_phase:
		spawn_phase = new_phase;
		apply_spawn_phase(spawn_phase);
		print("===================");
		print("Fase: ",spawn_phase);
		print("===================");
	
func _on_death_timer_timeout():
	deathTime -= 1;
	HUD.update_time(deathTime);
	# Fases de ronda
	refresh_phase();
	if(deathTime == 0):	#SuddenDeath
		$BombasSD.show();
		$BombasSD/AnimationPlayer.play("BombasSD");
		HUD.show_sudden_death();
		$DeathTimer.stop();
		$BoxTimer.stop();
		get_tree().call_group("box","queue_free");
		onSDEvent = true;
		suddenDSignal.emit();
	
func game_show_win(winner:String):
	await HUD.show_game_won(winner);
	HUD.update_score(str($Player1.score),str($Player2.score));

func on_win(player):
	if rondaT:
		return;
	rondaT = true;
	$DeathTimer.stop();
	$BoxTimer.stop();
	$LightningTimer.stop();
	player.score += 1;
	await game_show_win("Player "+str(player.player_id));
	if onSDEvent:
		suddenManager.stop_timer();
		onSDEvent = false;
	#Aumenta en 1 a las rondas
	if player1.score != 3 && player2.score != 3:
		rondaN += 1;
		spawn_phase = 0
		$Conveyor.stop();
		new_game();
	else:
		$Music.stop();
		finishGame();
		
func _on_player_1_hit():
	#P1 died
	player1._on_dead();
	$BombasSD/BombasSDAbajo.hide();
	on_win(player2);
func _on_player_2_hit():
	#P2 died
	player2._on_dead();
	$BombasSD/BombasSDArriba.hide();
	on_win(player1);

func _on_sdFinish(last_hitter):
	if last_hitter == 1:
		_on_player_2_hit();
	elif last_hitter == 2:
		_on_player_1_hit();
	
func finishGame():
	print("Terminando juego");
	GameData.score_p1 = player1.score;
	GameData.score_p2 = player2.score;
	GameData.winner = int(player2.score > player1.score) + 1;
	get_tree().change_scene_to_file("res://Escenas/VictoryScreen.tscn");

func _on_dark_timer_timeout() -> void:
	player1._on_dark(false);
	player2._on_dark(false);
	$Background/AnimationPlayer.play("Lightning_on");
	await $Background/AnimationPlayer.animation_finished;
	$Background.hide();
	onDark = false;

func _on_lightning_timer_timeout() -> void:
	## Cintas
	swap_cintas_direction();
	#Probabilidad
	if $Background/AnimationPlayer.is_playing():
		return;
	var nr = randf();
	if !onDark and nr <= prob_apagon:
		_makeDark();
