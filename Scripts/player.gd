extends Node2D;
signal hit;
const initial_speed := 500;
@export var speed=initial_speed; #How fast the player will move (pixel/sec)
@export var player_id = 1;

##Variables de referencia a nodos
@onready var ToRotate = $ToRotate;
@onready var CastorSprite = $ToRotate/AnimatedSprite2D;
@onready var AreaColision = $ToRotate/CollisionArea;
@onready var AreaColisionShape = $ToRotate/CollisionArea/CollisionShape2D;
@onready var AreaShovel = $ToRotate/ShovelingArea;
@onready var AreaShovelShape = $ToRotate/ShovelingArea/ShovelingShape2D;
@onready var Frozen = $ToRotate/Frozen;
@onready var Banana = $ToRotate/Banana;
@onready var ShockElec = $ToRotate/ShockElec;
@onready var PointLight = $ToRotate/PointLight2D;
@onready var LightFrozen = $ToRotate/LightFrozzen;

var screen_size;	#Size of the game window
#Score
var score = 0;
#Movement
var left_action = "";
var right_action = "";
@export var fuerzaEmpujeCinta := -110;
var fuerzaExterna:float;
#Orientation
var orientation = "right";
#Powers
var shovel_action := "";
var shovel_up_action := "";
#var shovel_ready := false;
var current_boxes := [];
var impulso_fuerza = 500;
var can_launch_box = true; #Timer
# Animation y more
var can_move := false;
var cinta_activa := false; 
# Banana
var enviado = false; ##  Debug
var onBanana:bool;
# Electro
var onShock:= false;
var nrosShock := 0;
# Congelando
var onFreeze:= false;
##Tp
var direccion_shovel := 1;

##3er mapa
@export var friction = speed * 2 #Frenado
var vel_actual := Vector2.ZERO;

func _ready():
	can_move = false;
	onBanana = false;
	onShock = false;
	onFreeze = false;
	direccion_shovel = 1;
	nrosShock = 0;
	screen_size = get_viewport_rect().size;
	orientation = "right";
	#Nodos
	Banana.hide();
	ShockElec.hide();
	Frozen.hide();
	PointLight.hide();
	LightFrozen.hide();
	const P1Color = Color(1,0.36,0.3,1);
	const P2Color = Color(0.35,0.61,1,1);
	if player_id == 1:
		$IndicadorPlayer.add_theme_color_override("font_color",P1Color);
	else:
		$IndicadorPlayer.add_theme_color_override("font_color",P2Color);
	$IndicadorPlayer.text = "P"+str(player_id);
	hide();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if cinta_activa:
		_process_cinta(delta);
		position = position.clamp(Vector2.ZERO, screen_size);
	else:
		_process_resbala(delta);
		fuerzaExterna = 0;
	

func _process_cinta(delta):
	#Fuerza Cintas Transportadoras
	var cinta_push = Vector2(fuerzaEmpujeCinta, 0);
	position += cinta_push * delta;
	if can_move:
		var velocity = Vector2.ZERO;	#Player's movement vector
		if Input.is_action_pressed(shovel_action):
			set_launch("normal");
		if Input.is_action_pressed(shovel_up_action):
			set_launch("especial");
		if Input.is_action_pressed(left_action):
			velocity.x -= 1;
			orientation = "left";
		if Input.is_action_pressed(right_action):
			velocity.x += 1;
			orientation = "right";
		# MOVEMENT
		if onBanana:
			speed = 200;
			Banana.show();
			$TimerBanana.start();
			onBanana = false;
		if velocity.length() > 0:
			velocity = velocity.normalized() * speed;
			position += velocity * delta;
			CastorSprite.animation = "walk";
			CastorSprite.play();
		else:
			#CastorSprite.animation = "idle";
			CastorSprite.stop();
		#Flip
		leftOrRight(orientation);
		
	else:
		#CastorSprite.animation = "idle";
		CastorSprite.stop();

func _process_resbala(delta): ##Para 3er mapa
	#Fuerza BlackHole
	var bh_pull = Vector2(fuerzaExterna, 0);
	position += bh_pull * delta;
	var velocity = Vector2.ZERO;	#Player's movement vector
	if can_move:
		if Input.is_action_pressed(shovel_action):
			set_launch("normal");
		if Input.is_action_pressed(shovel_up_action):
			set_launch("especial");
		if Input.is_action_pressed(left_action):
			velocity.x -= 1;
			orientation = "left";
		if Input.is_action_pressed(right_action):
			velocity.x += 1;
			orientation = "right";
	else:
		#CastorSprite.animation = "idle";
		CastorSprite.stop();
	
	# MOVEMENT
	if onBanana:
		speed = 200;
		Banana.show();
		$TimerBanana.start();
		onBanana = false;
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed;
		vel_actual = vel_actual.move_toward(velocity, speed * delta);
		CastorSprite.animation = "walk";
		CastorSprite.play();
	else:
		vel_actual = vel_actual.move_toward(Vector2.ZERO, friction *delta);
		#CastorSprite.animation = "idle";
		CastorSprite.stop();
	#Clamp
	var new_pos = position + vel_actual * delta;
	if new_pos.x < 0:
		new_pos.x = 0;
		vel_actual.x = 0;
	elif new_pos.x > screen_size.x:
		new_pos.x = screen_size.x;
		vel_actual.x = 0;
	position = new_pos;
	#Flip
	leftOrRight(orientation);
		
func start(pos):
	position = pos;
	onBanana = false;
	Banana.hide();
	show();
	AreaColisionShape.disabled = false;
	AreaShovelShape.disabled = false;
func leftOrRight(orientationA:String):
	if(orientationA == "right"):
		if(player_id == 1):
			$ToRotate.scale.x = 1;
		elif(player_id == 2):
			$ToRotate.scale.x = -1;
	elif(orientationA == "left"):
		if(player_id == 1):
			$ToRotate.scale.x = -1;
		elif(player_id == 2):
			$ToRotate.scale.x = 1;

func swapCS():
	if AreaColisionShape.disabled == true:
		AreaColisionShape.call_deferred("set_disabled",false);
	else:
		AreaColisionShape.call_deferred("set_disabled",true);
	if AreaShovelShape.disabled == true:
		AreaShovelShape.call_deferred("set_disabled",false);
	else:
		AreaShovelShape.call_deferred("set_disabled",true);
		
		
func _on_collision_area_body_entered(body):
	if body.is_in_group("box"):
		if body.last_hitter != player_id and body.last_hitter != 0 and body.linear_velocity.length() > 300:
			if body.typeName == "Box":
				body._on_impact(self);
			elif body.typeName == "Garbage":
				body._on_impact(self);
			elif body.typeName == "OxygenBomb":
				body._on_impact(self);
			else:
				pass;
				
func changeColorBody(mode = 'draw'):
	if len(current_boxes) != 0:
		var last_box = current_boxes[len(current_boxes)-1] #Ultimo
		if last_box.has_node("AnimatedSprite2D") and last_box.is_in_group("box"):
			if mode == 'draw':
				last_box.ChangeColor(player_id);
			elif mode == 'clear':
				if !last_box.hitted:
					last_box.ChangeColor(0);
				else:
					last_box.ChangeColor(last_box.last_hitter); #0,1,2
	
func _on_shoveling_area_body_entered(body):
	if body not in (current_boxes):
		if body is BaseBox and body.tepeando:
			current_boxes.push_back(body);
			return;
		changeColorBody('clear');
		current_boxes.push_back(body);
		changeColorBody('draw');
		
func _on_shoveling_area_body_exited(body):
	var box_index = current_boxes.find(body);
	if box_index != -1:
		if body is BaseBox and body.tepeando:
			current_boxes.pop_at(box_index);
			return;
		changeColorBody('clear')
		current_boxes.pop_at(box_index);
		changeColorBody('draw')
	
func before_launch_box(player_id, mode:String):
	var player = 1 if (player_id == 1) else -1;
	player *= direccion_shovel;
	if mode == "especial":
		launch_box(impulso_fuerza,-90*player);
	else:
		if orientation == "right":
			launch_box(impulso_fuerza,-60*player);
		elif orientation == "left":
			launch_box(impulso_fuerza,-110*player);
	
func set_launch(mode:String):
	if len(current_boxes)!=0 and can_launch_box:
		if player_id == 1:
			before_launch_box(player_id, mode);
		elif player_id == 2:
			before_launch_box(player_id, mode);
		can_launch_box = false;
		$TimerShovel.start();
		
func launch_box(impulso:float, angulo:float):
	## Caja por lanzar
	var current_box = current_boxes[len(current_boxes)-1];
	if current_box.has_method("explote"):
		if current_box.exploting:
			return;
	## Este hiteado o no
	current_box.hitted = true;

	current_box.last_hitter = player_id;
	current_box.set_collision_mask_value(1,true);
	var anguloF = deg_to_rad(angulo);
	var vector_fuerza = Vector2(cos(anguloF),sin(anguloF)) * impulso;
	if current_box.has_method("aplicar_impulso_custom"):
		if current_box.inmortal:
			current_box.aplicar_impulso_custom(vector_fuerza * 5);
		else:
			current_box.linear_velocity = Vector2.ZERO;
			current_box.apply_impulse(vector_fuerza);
	else:
		current_box.linear_velocity = Vector2.ZERO;
		current_box.apply_impulse(vector_fuerza);
	$ShovelSound.play();
			
func _on_timer_timeout():
	can_launch_box = true;

func _on_explosion(_body):
	hide();
	hit.emit();

func _on_dead():
	AreaColisionShape.set_deferred("disabled",true);
	AreaShovelShape.set_deferred("disabled",true);
	if self.visible == true:
		self.visible = false;
	_finish_asyncs();

func _finish_asyncs():
	self.onShock = false;
	self.onFreeze = false;
	self.friction = 700.0;
	ShockElec.hide();
	Frozen.hide();
	if !self.can_launch_box:
		self.can_launch_box = true;
	LightFrozen.hide();
	if !$TimerShockElec.is_stopped():
		$TimerShockElec.stop();
	if !$TimerFrozen.is_stopped():
		$TimerFrozen.stop();
		
func _on_dark(v=true):
	$PointLight2D.visible = v;
	
func _on_shock():
	# Eliminamos movimiento y mostramos elect
	$ShockSound.play();
	ShockElec.modulate = Color(1,1,1,1);
	self.can_move = false;
	self.can_launch_box = false;
	await get_tree().create_timer(0.5,false).timeout;
	# Regresamos a la normalidad
	ShockElec.modulate = Color(1,1,1,0.4);
	self.can_move = true;
	self.can_launch_box = true;
	nrosShock+=1;
	if nrosShock >= 4 or !onShock:
		$TimerShockElec.stop();
		ShockElec.hide();
		onShock = false;
		return;
	
func _electric_shock():
	nrosShock = 0;
	onShock = true;
	ShockElec.show();
	_on_shock();
	$TimerShockElec.start();

### Congelando
func _freezing(time:=3):
	$TimerFrozen.wait_time = time;
	if onFreeze:
		$TimerFrozen.start();
		if !$FrozeSound.playing:
			$FrozeSound.play();
		return;
	onFreeze = true;
	$FrozeSound.play();
	Frozen.show();
	LightFrozen.show();
	self.can_move = false;
	self.can_launch_box = false;
	self.friction *= 0.40;
	$TimerFrozen.start();
	
func _on_timer_banana_timeout():
	speed = 500;
	Banana.hide();

func _on_timer_shock_elec_timeout() -> void:
	if onShock:
		_on_shock();

func _on_timer_frozen_timeout() -> void:
	$FrozeSound2.play();
	self.can_move = true;
	self.can_launch_box = true;
	self.friction = 700;
	Frozen.hide();
	LightFrozen.hide();
	onFreeze = false;
