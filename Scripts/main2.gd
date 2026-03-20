extends Node

@export var box_scene: PackedScene;
@export var garbage_scene: PackedScene;
@export var oxygenbomb_scene : PackedScene;
@export var anim_camera_manager:Node;

var cinta_dir := 1;
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
@export var cow_scene:PackedScene;
var onCow := false;
@export var prob_cow:=0.15;

var onTp := false;
@export var prob_tp:=0.15;
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
	DirectionCintas(cinta_vel,cinta_dir);
	##Empezar animacion inicial
	on_animation(false,true);
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
	player1.cinta_activa = move;
	player2.cinta_activa = move;
	
func new_game():
	rondaT = false;
	deathTime = Initialtime;
	$Background.hide();
	$BackgroundScn1.show();
	$CintasAbajo.show();
	$CintasArriba.show();
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
	
	#Movimiento
	on_animation(false,false);
	DirectionCintas(cinta_vel,cinta_dir);
	await HUD.getReady(rondaN);
	cinta_dir = 1;
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
	AnimacionesStart($CintasAbajo,-vel * dir);

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
			player1.fuerzaEmpujeCinta = -110*cinta_dir;
			player2.fuerzaEmpujeCinta = 110*cinta_dir;
			vel_cajas = 100;
		2:
			$BoxTimer.wait_time = 0.75;
			DirectionCintas(2,cinta_dir);
			player1.fuerzaEmpujeCinta = -160*cinta_dir;
			player2.fuerzaEmpujeCinta = 160*cinta_dir;
			vel_cajas = 115;
		3:
			$BoxTimer.wait_time = 0.5;
			DirectionCintas(3,cinta_dir);
			player1.fuerzaEmpujeCinta = -200*cinta_dir;
			player2.fuerzaEmpujeCinta = 200*cinta_dir;
			vel_cajas = 140;
	
	var cajas = get_tree().get_nodes_in_group("box")
	for caja in cajas:
		if caja.has_method("actualizar_velocidad") and caja.typeName != "Cow":
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
		diferencia = Vector2(0,4);
	else:
		return;
	
	# Configuramos caja para usar direccion local
	throwable.use_local_direction = true;
	throwable.actualizar_velocidad(vel_cajas);
	if spawn == 0:
		throwable.direction_local = -cinta_dir;
		if cinta_dir == 1:
			throwable.position = $SpawnBoxesRP1.position# + diferencia;
		else:
			throwable.position = $SpawnBoxesLP1.position# + diferencia;
	elif spawn == 1:
		throwable.direction_local = cinta_dir;
		if cinta_dir == 1:
			throwable.position = $SpawnBoxesLP2.position + diferencia;
		else:
			throwable.position = $SpawnBoxesRP2.position + diferencia;
	
	## == Spawneamos la caja agregandolo a la escena:
	add_child(throwable);
	
func game_over_by_time():
	#AnimacionAntenaImpacto();
	HUD.show_game_over();
	$BoxTimer.stop();
	$Music.stop();
	#$LaserSound.play();

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
	$TimerRandomEvents.stop();
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
		# Momento entre rondas
		player1._finish_asyncs();
		player2._finish_asyncs();
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

func _throwCow():
	if deathTime > 55: #Para no arrojas vacas desde el inicio xd
		return;
	if onCow:
		return;
	onCow = true;
	var cow_instantiate = cow_scene.instantiate();
	cow_instantiate.cow_died.connect(_on_cow_died);
	var spawn = randi_range(0,1);
	var PosX:float
	var PosY = randf_range($SpawnBoxesLP2.position.y+50, $SpawnBoxesLP1.position.y-50);
	cow_instantiate.use_local_direction = true;
	cow_instantiate.actualizar_velocidad(vel_cajas * 2);
	if spawn == 0:
		cow_instantiate.direction_local = -cinta_dir;
		PosX = $SpawnBoxesRP1.position.x + 50;
	elif spawn == 1:
		cow_instantiate.direction_local = cinta_dir;
		PosX = $SpawnBoxesLP1.position.x - 50;

	cow_instantiate.position = Vector2(PosX,PosY);
	## == Spawneamos la caja agregandolo a la escena:
	add_child(cow_instantiate);

func _on_cow_died():
	onCow = false

func _tpBoxes():
	if deathTime > 55: #Para no empezar a tepear desde el inicio xd
		return;
	if onTp:
		return;
	onTp = true;
	var cajas := get_tree().get_nodes_in_group("box")
	var cajas_validas := [];
	for caja in cajas:
		if !is_instance_valid(caja):
			continue;
		if caja.out_screen or caja.tepeando:
			continue;
		if caja.position.x < $SpawnBoxesLP1.position.x + 250 or caja.position.x > $SpawnBoxesRP1.position.x - 250:
			continue;
		cajas_validas.append(caja);
	#Validamos nro de cajas
	if cajas_validas.is_empty():
		onTp = false;
		return;
	## Hacemos shuffle
	cajas_validas.shuffle();
	var boxes_to_tp = cajas_validas.slice(0,4);
	var velocidades_guardadas = [];
	#Congelar cajas
	print("Tepeando!!");
	for caja in boxes_to_tp:
		if is_instance_valid(caja):
			$Tp1.play();
			caja.ChangeColorYellow();
			#caja.hide();
			##Guardamos velocidades
			if caja.hitted or caja.typeName == "Cow":
				velocidades_guardadas.append({
					"caja":caja,
					"velocidad":caja.linear_velocity,
					"angular":caja.angular_velocity
				})
			caja.freeze = true; ##Congelamos caja durante tp
			caja.tepeando = true;
			caja.swapCS(); ##Apagamos CollisionShape
			
	await get_tree().create_timer(0.5,false).timeout;
	
	#Tepear
	for caja in boxes_to_tp:
		if !is_instance_valid(caja):
			continue;
		##Calcula x entre 2 rangos:
		var pos_actual_x = caja.position.x;
		##Limites de pantalla y spawns
		var left_limit = $SpawnBoxesLP1.position.x+150;
		var right_limit = $SpawnBoxesRP1.position.x-150;
		#Var
		var new_x = _calcular_nueva_x(pos_actual_x, left_limit, right_limit);
		## Caso no hay opciones validas
		if new_x == null:
			print("No hay opciones validas");
			new_x = ($SpawnBoxesLP1.position.x + $SpawnBoxesRP1.position.x)/2;
		
		##Buscamos velocidades guardadas
		var velocidad_guardada = null;
		if caja.hitted or caja.typeName == "Cow":
			for v in velocidades_guardadas:
				if v["caja"] == caja:
					velocidad_guardada = v
					break;
		
		caja.tepeando = true;
		var new_pos = Vector2(new_x, caja.global_position.y);
		caja.call_deferred("set_global_position", new_pos);
		##Restauramos vel
		if velocidad_guardada and (caja.hitted or caja.typeName == "Cow"):
			caja.call_deferred("set_linear_velocity",velocidad_guardada["velocidad"]);
			caja.call_deferred("set_angular_velocity",velocidad_guardada["angular"]);
		#Aplicar TP
		caja.freeze = false;
		$Tp2.play();
		caja.swapCS(); ##Prendemos CollisionShape
		#caja.show();
		await get_tree().create_timer(0.25,false).timeout;
		if !is_instance_valid(caja):
			continue;
		caja.ChangeColorOrig();
		caja.tepeando = false;
		
	onTp = false;
	
func _calcular_nueva_x(pos_actual_x:float, left_limit:float, right_limit:float):
	#Opciones de tp
	var opciones := [];
	## Opciones izquierda
	var left_min = left_limit;
	var left_max = pos_actual_x - 100;
	if left_max > left_min:
		opciones.append(randf_range(left_min, left_max));
	## Opciones derecha
	var right_min = pos_actual_x + 100;
	var right_max = right_limit;
	if right_max > right_min:
		opciones.append(randf_range(right_min, right_max));

	## Caso no hay opciones validas
	if opciones.is_empty():
		return null;
		
	return opciones[randi() % opciones.size()];
	
func _on_timer_random_events_timeout() -> void:
	if !onCow:
		var nr = randf();
		if nr <= prob_cow:
			_throwCow();
	if !onTp:
		var nr = randf();
		if nr <= prob_tp:
			_tpBoxes();
