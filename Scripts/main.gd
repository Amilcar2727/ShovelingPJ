extends Node
@export var box_scene: PackedScene;
@export var garbage_scene: PackedScene;
@export var deathTime:int = 60;
var rondaT = false;
@onready var player1 = $Player1
@onready var player2 = $Player2
@onready var HUD = $HUD
# Antena
@export var antena_scene:PackedScene;
@export var palanca_scene:PackedScene;
var antena_instancia;
var palanca_instancia;
var empezarAntena;
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
	$Background.show();
	$BackgroundScn1.hide();
	$CintasAbajo.hide();
	$CintasArriba.hide();
	#ANTENA
	empezarAntena = false;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass;

func game_over_by_time():
	AnimacionAntenaImpacto();
	HUD.show_game_over();
	$DeathTimer.stop();
	$BoxTimer.stop();
	$Music.stop();
	$LaserSound.play();
	
func game_win(winner:String):
	HUD.show_game_won(winner);
	HUD.update_score(str($Player1.score),str($Player2.score));
	if antena_instancia != null:
		antena_instancia.alcanzoDestino = true;
		antena_instancia.get_node("Circulo").animating = false;
	$DeathTimer.stop();
	$BoxTimer.stop();
	$Music.stop();
	$DeathSound.play();

func new_game():
	deathTime = 11;
	$Background.hide();
	$BackgroundScn1.show();
	rondaT = false;
	$CintasAbajo.show();
	$CintasArriba.show();
	AnimacionesStart($CintasAbajo);
	AnimacionesStart($CintasArriba);
	HUD.update_time(deathTime);
	HUD.show_message("Get Ready");
	player1.start($StartPositionP1.position);
	player1.orientation = "right";
	player2.start($StartPositionP2.position);
	player2.rotation = deg_to_rad(180);
	player2.scale.x = -1;
	player2.orientation = "right";
	#$Music.play(); 
	$StartTimer.start();
	get_tree().call_group("box","queue_free");
	empezarAntena = false;
	if antena_instancia != null:
		antena_instancia.queue_free();
		palanca_instancia.queue_free();

func AnimacionesStart(nodoPadre:Node2D):
	for child in nodoPadre.get_children():
		if child is AnimatedSprite2D:
			child.play();

func _on_box_timer_timeout():
	#Creamos una instancia de caja o basura
	var throwable;
	var type = randi_range(0,1);
	var spawn = randi_range(0,1);
	var diferencia;
	if type == 0:
		throwable = box_scene.instantiate();
		diferencia = Vector2.ZERO;
	else:
		throwable = garbage_scene.instantiate();
		diferencia = Vector2(0,-17);
	if spawn == 0:
		throwable.position = $SpawnBoxesP1.position + diferencia;
	elif spawn == 1:
		throwable.position = $SpawnBoxesP2.position - diferencia;
	## == Spawneamos la caja agregandolo a la escena:
	add_child(throwable);
func _on_death_timer_timeout():
	deathTime -= 1;
	HUD.update_time(deathTime);
	if(deathTime == 0):	#GameOver
		palanca_instancia.get_node("CollisionShape2D").disabled = true;
		if antena_instancia.apunta_jugador == 1:
			player2.score += 1;
			player1.hide();
			player1.position = Vector2(0,0);
		else:
			player1.score += 1;
			player2.hide();
			player2.position = Vector2(0,0);
		HUD.update_score(str(player1.score),str(player2.score));
		game_over_by_time();
	# ==== ANTENA ==== #
	if(deathTime <= 10 and not empezarAntena):
		antena_instancia = antena_scene.instantiate();
		palanca_instancia = palanca_scene.instantiate();
		antena_instancia.position = Vector2(-120, 370);
		palanca_instancia.position = Vector2(1250, 384);
		add_child(antena_instancia);
		add_child(palanca_instancia);
		empezarAntena = true;

func _on_start_timer_timeout():
	$BoxTimer.start();
	$DeathTimer.start();
	
func _on_player_1_hit():
	if rondaT == false:
		#P1 died
		player2.score += 1;
		rondaT = true;
		game_win("Player 2");
func _on_player_2_hit():
	if rondaT == false:
		#P2 died
		player1.score += 1;
		rondaT = true;
		game_win("Player 1");
func AnimacionAntenaImpacto():
	$HUD/AntenaPower.show();
	await get_tree().create_timer(1.0).timeout;
	$HUD/AntenaPower.hide();
