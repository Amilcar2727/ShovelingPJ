extends Node

@export var box_scene: PackedScene;
@export var garbage_scene: PackedScene;
@export var oxygenbomb_scene : PackedScene;
@export var anim_camera_manager:Node;
const Initialtime:int = 60;
var deathTime:int = Initialtime;
var rondaN = 1;
var rondaT := false;
@onready var player1 := $Player1;
@onready var player2 := $Player2;
@onready var HUD = $HUD;
@onready var pauseMenu = $MenuPause; #ElPeneDeDavidCHEstuvoAqui
#Yonieskbro:awawa
#rAnatieneelanoasibiengrande- anton
#antonesunhomosexualLamecaca- eylleen
# Antena
@export var antena_scene:PackedScene;
@export var palanca_scene:PackedScene;
var antena_instancia;
var palanca_instancia;
var empezarAntena;
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
	#Nro ronda
	rondaN = 1;
	#SuddenDeath
	suddenManager.sdFinish.connect(_on_sdFinish);
	onSDEvent = false;
	#empezarAntena = false;
	
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
	#$Music.play();
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
	#Cintas animacion
	AnimacionesStart($CintasAbajo);
	AnimacionesStart($CintasArriba);
	#Movimiento
	player1.can_move = true;
	player2.can_move = true;
	$BoxTimer.start();
	$DeathTimer.start();
	$LightningTimer.start();
	#empezarAntena = false;
	#if antena_instancia != null:
		#antena_instancia.queue_free();
		#palanca_instancia.queue_free();

func AnimacionesStart(nodoPadre:Node2D):
	for child in nodoPadre.get_children():
		if child is AnimatedSprite2D:
			child.play();

func _on_box_timer_timeout():
	#Creamos una instancia de caja o basura
	var throwable;
	var type = BaseBox.elegirCajaType();
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
		throwable.position = $SpawnBoxesP1.position + diferencia;
	elif spawn == 1:
		throwable.position = $SpawnBoxesP2.position - diferencia;
	## == Spawneamos la caja agregandolo a la escena:
	add_child(throwable);
	
func game_over_by_time():
	#AnimacionAntenaImpacto();
	HUD.show_game_over();
	$BoxTimer.stop();
	$Music.stop();
	#$LaserSound.play();

func _makeDark():
	onDark = true;
	$Background.show();
	$Background/AnimationPlayer.play("Lightning_off");
	await $Background/AnimationPlayer.animation_finished;
	player1._on_dark(true);
	player2._on_dark(true);
	$DarkTimer.start();

func _on_death_timer_timeout():
	deathTime -= 1;
	HUD.update_time(deathTime);
	if(deathTime == 0):	#SuddenDeath
		HUD.show_sudden_death();
		$DeathTimer.stop();
		$BoxTimer.stop();
		get_tree().call_group("box","queue_free");
		onSDEvent = true;
		suddenDSignal.emit();
		#palanca_instancia.get_node("CollisionShape2D").disabled = true;
		#if antena_instancia.apunta_jugador == 1:
			#player2.score += 1;
			#player1.hide();
			#player1.position = Vector2(0,0);
		#else:
			#player1.score += 1;
			#player2.hide();
			#player2.position = Vector2(0,0);
	# ==== ANTENA ==== #
	#if(deathTime <= 10 and not empezarAntena):
		#spawnObject(antena_instancia, antena_scene, Vector2(-120, 370));
		#spawnObject(palanca_instancia, palanca_scene, Vector2(1250, 384));
		#empezarAntena = true;
		
func spawnObject(instancia,escena:PackedScene,pos:Vector2):
	instancia = escena.instantiate();
	instancia.position = pos;
	add_child(instancia);
	
func game_show_win(winner:String):
	await HUD.show_game_won(winner);
	HUD.update_score(str($Player1.score),str($Player2.score));
	#if antena_instancia != null:
		#antena_instancia.alcanzoDestino = true;
		#antena_instancia.get_node("Circulo").animating = false;

func on_win(player):
	if rondaT:
		return;
	rondaT = true;
	$DeathTimer.stop();
	$BoxTimer.stop();
	$LightningTimer.stop();
	player.score += 1;
	await game_show_win("Player "+str(player.player_id));
	$Music.stop();
	if onSDEvent:
		suddenManager.stop_timer();
		onSDEvent = false;
	#Aumenta en 1 a las rondas
	if player1.score != 3 && player2.score != 3:
		rondaN += 1;
		new_game();
	else:
		finishGame();
		
func _on_player_1_hit():
	#P1 died
	player1._on_dead();
	on_win(player2);
func _on_player_2_hit():
	#P2 died
	player2._on_dead();
	on_win(player1);

func _on_sdFinish(last_hitter):
	if last_hitter == 1:
		_on_player_2_hit();
	elif last_hitter == 2:
		_on_player_1_hit();

func AnimacionAntenaImpacto():
	$HUD/AntenaPower.show();
	await get_tree().create_timer(1.0,false).timeout;
	$HUD/AntenaPower.hide();
	
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
	#Probabilidad
	if $Background/AnimationPlayer.is_playing():
		return;
	var nr = randf();
	if !onDark and nr <= 0.50:
		_makeDark();
