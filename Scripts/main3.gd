extends Node

@export var box_scene: PackedScene;
@export var garbage_scene: PackedScene;
@export var oxygenbomb_scene : PackedScene;
@export var anim_camera_manager:Node;
@onready var canvasModulate = $Background;

var cinta_dir := -1;
var cinta_vel := 1;
var cambiando_cinta := false;
var vel_cajas := 100;

var spawn_phase := 0
const Initialtime:int = 60;
var deathTime:int = Initialtime;
var rondaN = 1;
var rondaT := false;
@onready var player1 := $Player1;
@onready var player2 := $Player2;
@onready var HUD = $HUD;
@onready var pauseMenu = $MenuPause; 

# Eventos aleatorios
var onStorm := false;
@export var prob_storm:=0.15;
var active_tweens := [];

var onTp := false;
@export var prob_tp:=0.15;
var timeWaitTp := 0.5;
# Antena
#@export var antena_scene:PackedScene;
#@export var palanca_scene:PackedScene;
var antena_instancia;
var palanca_instancia;
var empezarAntena;

# SuddenDeath
signal suddenDSignal;
@onready var suddenManager:Node = $"SuddenDeathManager";
var onSDEvent := false;
## Minieventos
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
	canvasModulate.show();
	$BackgroundScn1.show();
	$CintasAbajo.show();
	$CintasArriba.show();
	#Nro ronda
	rondaN = 1;
	#SuddenDeath
	onSDEvent = false;
	#empezarAntena = false;
	DirectionCintas(cinta_vel,cinta_dir);
	##Empezar animacion inicial
	on_animation(false,true);
	player1.cinta_activa = false;
	player2.cinta_activa = false;
	player1.position = Vector2(0,0);
	player2.position = Vector2(0,0);
	player1.show();
	player2.show();
	#await anim_camera_manager.animationCameraInitPlay()
	##Nuevo juego
	#$Camera2D.zoom = Vector2(0.6,0.6);
	new_game();

##Input
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if !get_tree().paused: #Si pausamos
			pauseMenu.open();
	
func on_animation(move := false,hiddenHud:=true):
	if hiddenHud: HUD.hide();
	player1.can_move = move;
	player2.can_move = move;
	#player1.cinta_activa = move;
	#player2.cinta_activa = move;
	
func new_game():
	rondaT = false;
	deathTime = Initialtime;
	canvasModulate.show();
	$BackgroundScn1.show();
	$CintasAbajo.show();
	$CintasArriba.show();
	
	##Posiciones iniciales
	$SpawnBoxesRP1.position = Vector2(1300, 570);
	$SpawnBoxesRP2.position = Vector2(1300, 193);
	$SpawnBoxesLP1.position = Vector2(-20, 570);
	$SpawnBoxesLP2.position = Vector2(-20, 193);
	
	#Cintas animacion
	AnimacionesStop($CintasAbajo);
	AnimacionesStop($CintasArriba);
	HUD.show();
	HUD.update_time(deathTime);
	#HUD.show_message("Get Ready!");
	player1.start($StartPositionP1.position);
	player1.orientation = "right";
	player1.ToRotate.scale.x = 1;
	player2.start($StartPositionP2.position);
	player2.ToRotate.rotation = deg_to_rad(180);
	player2.ToRotate.scale.x = -1;
	player2.orientation = "right";
	if !$Music.playing:
		$Music.play();
	get_tree().call_group("box","queue_free");
	
	onStorm = false;
	onSDEvent = false;
	suddenManager.stop_timer();
	if suddenManager.SDObject_instance != null:
		get_tree().call_group("box","queue_free");
		suddenManager.delete();
	#Start game
	
	#Movimiento
	player1.cinta_activa = false;
	player2.cinta_activa = false;
	on_animation(false,false);
	DirectionCintas(cinta_vel,cinta_dir);
	canvasModulate.color = Color("#d7def6");
	await HUD.getReady(rondaN);
	cinta_dir = -1;
	timeWaitTp = 0.5;
	#Cintas animacion
	refresh_phase();
	$Conveyor.play();
	#Movimiento
	on_animation(true,false);
	$BoxTimer.start();
	$DeathTimer.start();
	$TimerRandomEvents.start();

func DirectionCintas(vel=1, dir=1):
	cinta_vel = vel;
	cinta_dir = dir;
	print("Direccion Cintas:",cinta_vel);
	AnimacionesStart($CintasArriba,vel * dir);
	AnimacionesStart($CintasAbajo,vel * dir);

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
			#DirectionCintas(7);
			player1.fuerzaEmpujeCinta = 110*cinta_dir;
			player2.fuerzaEmpujeCinta = 110*cinta_dir;
			vel_cajas = 100;
		2:
			$BoxTimer.wait_time = 0.75;
			DirectionCintas(2,cinta_dir);
			player1.fuerzaEmpujeCinta = 160*cinta_dir;
			player2.fuerzaEmpujeCinta = 160*cinta_dir;
			vel_cajas = 115;
		3:
			$BoxTimer.wait_time = 0.5;
			DirectionCintas(3,cinta_dir);
			player1.fuerzaEmpujeCinta = 200*cinta_dir;
			player2.fuerzaEmpujeCinta = 200*cinta_dir;
			vel_cajas = 140;
	
	var cajas = get_tree().get_nodes_in_group("box")
	for caja in cajas:
		if caja.has_method("actualizar_velocidad"):
			caja.actualizar_velocidad(vel_cajas);
			
	print("Wait_time: ",$BoxTimer.wait_time);
			
func _on_box_timer_timeout():
	var throwable;
	var type = BaseBox.elegirCajaType(spawn_phase);
	var spawn = randi_range(0,1);
	var diferencia;
	if type == 1:
		throwable = box_scene.instantiate();
		diferencia = Vector2(0,5);
	elif type == 2:
		throwable = garbage_scene.instantiate();
		diferencia = Vector2(0,3);
	elif type == 3:
		throwable = oxygenbomb_scene.instantiate();
		diferencia = Vector2(0,5);
	else:
		return;
	
	# Configuramos caja para usar direccion local
	throwable.use_local_direction = true;
	throwable.actualizar_velocidad(vel_cajas);
	throwable.direction_local = cinta_dir;
	if onSDEvent:
		cinta_dir = randi_range(0,1);
	
	if spawn == 0:
		if cinta_dir == 1:
			throwable.position = $SpawnBoxesLP1.position# + diferencia;
		else:
			throwable.position = $SpawnBoxesRP1.position# + diferencia;
	elif spawn == 1:
		if cinta_dir == 1:
			throwable.position = $SpawnBoxesLP2.position + diferencia;
		else:
			throwable.position = $SpawnBoxesRP2.position + diferencia;
	
	## == Spawneamos la caja agregandolo a la escena:
	add_child(throwable);

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
		player1.fuerzaEmpujeCinta = -250*cinta_dir;
		player2.fuerzaEmpujeCinta = 250*cinta_dir;
		$DeathTimer.stop();
		#$BoxTimer.stop();
		#get_tree().call_group("box","queue_free");
		HUD.show_sudden_death();
		await get_tree().process_frame;
		onSDEvent = true;
		suddenDSignal.emit();
	
func changes_sd():
	timeWaitTp = 0.2;
	#640,384
	$SpawnBoxesRP1.position.x = 1500;
	$SpawnBoxesRP1.position.y = randi_range(334,434);
	$SpawnBoxesRP2.position.x = 1500;
	$SpawnBoxesRP2.position.y = randi_range(334,434);
	
	$SpawnBoxesLP1.position.x = -220;
	$SpawnBoxesLP1.position.y = randi_range(334,434);
	$SpawnBoxesLP2.position.x = -220;
	$SpawnBoxesLP2.position.y = randi_range(334,434);
	
func spawnObject(instancia,escena:PackedScene,pos:Vector2):
	instancia = escena.instantiate();
	instancia.position = pos;
	add_child(instancia);
	
func game_show_win(winner:String):
	await HUD.show_game_won(winner);
	HUD.update_score(str($Player1.score),str($Player2.score));

func on_win(player):
	if rondaT:
		return;
	rondaT = true;
	$DeathTimer.stop();
	$BoxTimer.stop();
	$TimerRandomEvents.stop();
	player.score += 1;
	if onSDEvent:
		suddenManager.stop_timer();
	#print("Regresando Color Normal Canvas")
	var t1 = create_tween();
	active_tweens.append(t1);
	t1.tween_property(canvasModulate,"color",Color("#d7def6"),2)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)
	await game_show_win("Player "+str(player.player_id));
	#Aumenta en 1 a las rondas
	if player1.score != 3 && player2.score != 3:
		if onSDEvent:
			onSDEvent = false;
		rondaN += 1;
		spawn_phase = 0
		$Conveyor.stop();
		# Momento entre rondas
		player1.vel_actual = Vector2.ZERO;
		player2.vel_actual = Vector2.ZERO;
		player1._finish_asyncs();
		player2._finish_asyncs();
		player1.ToRotate.scale = Vector2(1,1);
		player1.ToRotate.rotation = 0;
		player2.ToRotate.scale = Vector2(-1,1);
		player2.ToRotate.rotation = deg_to_rad(180);
		player1.direccion_shovel = 1;
		player2.direccion_shovel = 1;
		player1.can_launch_box
		##Tweens
		for t in active_tweens:
			if t.is_valid():
				t.kill()
		active_tweens.clear();
		$Tormenta.position.x = 0;
		if $SnowStorm.playing:
			$SnowStorm.stop();
		new_game();
	else:
		$Music.stop();
		finishGame();
		
func _on_player_1_hit():
	#P1 died
	player1._on_dead();
	on_win(player2);
func _on_player_2_hit():
	#P2 died
	player2._on_dead();
	on_win(player1);
	
func finishGame():
	print("Terminando juego");
	GameData.score_p1 = player1.score;
	GameData.score_p2 = player2.score;
	GameData.winner = int(player2.score > player1.score) + 1;
	get_tree().change_scene_to_file("res://Escenas/VictoryScreen.tscn");

func _StormEvent(mutant:=false):
	if deathTime > 55:
		return;
	if onStorm:
		return;
	print("Nevando!!");
	onStorm = true;
	## Canvas
	var tweenBG = create_tween();
	active_tweens.append(tweenBG);
	## Sonido
	sonido_delay($SnowStorm);
	# Para animaciones paralelas
	tweenBG.set_parallel(true);
	# Oscurecer
	##.trans -> curva de movimiento
	##.ease -> Define donde acelera/desacelera
	tweenBG.tween_callback(func():
		if !onSDEvent:
			#print("Entrando Color Normal Canvas");
			var t = create_tween()
			active_tweens.append(t);
			t.tween_property(canvasModulate,"color",Color("#4a5a8a"),1.4)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_OUT); #curva suave y acelera
		else:
			#print("Entrando Color SD Canvas")
			var t = create_tween();
			active_tweens.append(t);
			t.tween_property(canvasModulate,"color",Color("#a02819"),1.4)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_OUT); #curva suave y acelera
	)
	
	## SnowMan para las cajas
	tweenBG.tween_callback(func():
		turn_boxes_snowman();
	).set_delay(6);
	
	## Tormenta
	tweenBG.tween_property($Tormenta,"position:x",-11500, 6)\
		.set_delay(1.1)\
		.set_trans(Tween.TRANS_LINEAR); #vel. constante
	
	tweenBG.tween_callback(func():
		if !onSDEvent:
			#print("Regresando Color Normal Canvas")
			var t = create_tween()
			active_tweens.append(t);
			t.tween_property(canvasModulate,"color",Color("#d7def6"),2)\
				.set_trans(Tween.TRANS_SINE)\
				.set_ease(Tween.EASE_IN)
		else:
			#print("Regresando Color SD Canvas")
			var t = create_tween()
			active_tweens.append(t);
			t.tween_property(canvasModulate,"color",Color("#ff7a2f"),2)\
				.set_trans(Tween.TRANS_SINE)\
				.set_ease(Tween.EASE_IN)
	).set_delay(5.6)
	await tweenBG.finished;
	$Tormenta.position.x = 0;
	onStorm = false;

func sonido_delay(sonido:AudioStreamPlayer):
	await get_tree().create_timer(0.4,false).timeout;
	sonido.play();

func turn_boxes_snowman():
	var cajas := get_tree().get_nodes_in_group("box");
	var cajas_validas := [];
	for caja in cajas:
		if !is_instance_valid(caja):
			continue;
		if caja.out_screen:
			continue;
		if caja.position.x < $SpawnBoxesLP1.position.x + 250 or caja.position.x > $SpawnBoxesRP1.position.x - 250:
			continue;
		if caja.has_method("explote"):
			if caja.exploting:
				continue;
		cajas_validas.append(caja);
	#Validamos nro de cajas
	if cajas_validas.is_empty():
		return;
	## Hacemos shuffle
	cajas_validas.shuffle();
	var boxes_to_snowman = cajas_validas.slice(0,5);
	#Congelar cajas
	print("Convirtiendo Muñecos!!");
	for caja in boxes_to_snowman:
		if is_instance_valid(caja):
			caja.ChangeSnowMan();
			$SnowManSound.play();
			await get_tree().create_timer(0.1,false).timeout;

func _tpPlayers():
	if deathTime > 55: #Para no empezar a tepear desde el inicio xd
		return;
	if onTp:
		return;
	if rondaT:
		onTp = false;
		return;
	
	onTp = true;
	#Validamos nro de cajas
	var velocidades_guardadas = [];
	#Congelar players
	print("Tepeando!!");
	$Tp1.play();
	
	var vel_guardada1 = {
		"player":player1,
		"velocidad":player1.vel_actual
	}
	var vel_guardada2 = {
		"player":player2,
		"velocidad":player2.vel_actual
	}
	velocidades_guardadas.append(vel_guardada1)
	velocidades_guardadas.append(vel_guardada2)
	player1.can_move = false;
	player2.can_move = false;
	player1.vel_actual = Vector2.ZERO;
	player1.vel_actual = Vector2.ZERO;
	player1.swapCS(); ##Apagamos CollisionShape
	player2.swapCS();
	await get_tree().create_timer(timeWaitTp,false).timeout;
	
	#Tepear
	var pos_actual_x1 = player1.position.x;
	var pos_actual_x2 = player2.position.x;
	
	var aux_y = player2.position.y;
	player2.position.y = player1.position.y;
	player1.position.y = aux_y;
	
	player1.ToRotate.scale.x *= -1;
	player2.ToRotate.scale.x *= -1;
	player1.ToRotate.scale.y *= -1;
	player2.ToRotate.scale.y *= -1;
	
	player1.direccion_shovel *= -1; 
	player2.direccion_shovel *= -1; 
	##Restauramos vel
	for v in velocidades_guardadas:
		if v["player"] == player1:
			player1.vel_actual = v["velocidad"];
		else:
			player2.vel_actual = v["velocidad"];
	#Aplicar TP
	if !player1.onFreeze:
		player1.can_move = true;
	if !player2.onFreeze:
		player2.can_move = true;
	$Tp2.play();
	#Shake camara
	$Camera2D.offset += Vector2(randf_range(-6, 6), randf_range(-6, 6));
	await get_tree().create_timer(0.08, false).timeout
	$Camera2D.offset = Vector2(640, 360);
	player1.swapCS(); ##Prendemos CollisionShape
	player2.swapCS();
		
	onTp = false;
	
func _on_timer_random_events_timeout() -> void:
	if !onStorm:
		var nr = randf();
		if nr <= prob_storm:
			_StormEvent();
	if !onTp:
		var nr = randf();
		if nr <= prob_tp:
			_tpPlayers();
