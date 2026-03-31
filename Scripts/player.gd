extends Node2D;
signal hit;
const initial_speed := 500;
@export var speed=initial_speed; #How fast the player will move (pixel/sec)
@export var player_id = 1;
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

func _ready():
	can_move = false;
	onBanana = false;
	onShock = false;
	onFreeze = false;
	nrosShock = 0;
	screen_size = get_viewport_rect().size;
	orientation = "right";
	$Banana.hide();
	$ShockElec.hide();
	$Frozen.hide();
	$PointLight2D.hide();
	$LightFrozzen.hide();
	hide();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if cinta_activa:
		#Fuerza Cintas Transportadoras
		var cinta_push = Vector2(fuerzaEmpujeCinta + fuerzaExterna, 0);
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
			$Banana.show();
			$TimerBanana.start();
			onBanana = false;
		if velocity.length() > 0:
			velocity = velocity.normalized() * speed;
			position += velocity * delta;
			$AnimatedSprite2D.animation = "walk";
			$AnimatedSprite2D.play();
		else:
			#$AnimatedSprite2D.animation = "idle";
			$AnimatedSprite2D.stop();
		
		#Flip
		leftOrRight(orientation);
		
	else:
		#$AnimatedSprite2D.animation = "idle";
		$AnimatedSprite2D.stop();
	
	position = position.clamp(Vector2.ZERO, screen_size);
	fuerzaExterna = 0;

func start(pos):
	position = pos;
	onBanana = false;
	$Banana.hide();
	show();
	$CollisionArea/CollisionShape2D.disabled = false;
	$ShovelingArea/ShovelingShape2D.disabled = false;
func leftOrRight(orientationA:String):
	if(orientationA == "right"):
		if(player_id == 1):
			scale.x = 1;
		elif(player_id == 2):
			scale.x = -1;
	elif(orientationA == "left"):
		if(player_id == 1):
			scale.x = -1;
		elif(player_id == 2):
			scale.x = 1;
			
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
	$CollisionArea/CollisionShape2D.set_deferred("disabled",true);
	$ShovelingArea/ShovelingShape2D.set_deferred("disabled",true);
	if self.visible == true:
		self.visible = false;
	_finish_asyncs();
	self.position = Vector2(0,0);

func _finish_asyncs():
	onShock = false;
	onFreeze = false;
	$ShockElec.hide();
	$Frozen.hide();
	$LightFrozzen.hide();
	if !$TimerShockElec.is_stopped():
		$TimerShockElec.stop();
	if !$TimerFrozen.is_stopped():
		$TimerFrozen.stop();
		
func _on_dark(v=true):
	$PointLight2D.visible = v;
	
func _on_shock():
	# Eliminamos movimiento y mostramos elect
	$ShockSound.play();
	$ShockElec.modulate = Color(1,1,1,1);
	self.can_move = false;
	self.can_launch_box = false;
	await get_tree().create_timer(0.5,false).timeout;
	# Regresamos a la normalidad
	$ShockElec.modulate = Color(1,1,1,0.4);
	self.can_move = true;
	self.can_launch_box = true;
	nrosShock+=1;
	if nrosShock >= 4 or !onShock:
		$TimerShockElec.stop();
		$ShockElec.hide();
		onShock = false;
		return;
	
func _electric_shock():
	nrosShock = 0;
	onShock = true;
	$ShockElec.show();
	_on_shock();
	$TimerShockElec.start();

### Congelando
func _freezing():
	if onFreeze:
		$TimerFrozen.start();
		if !$FrozeSound.playing:
			$FrozeSound.play();
		return;
	onFreeze = true;
	$FrozeSound.play();
	$Frozen.show();
	$LightFrozzen.show();
	self.can_move = false;
	self.can_launch_box = false;
	$TimerFrozen.start();
	
func _on_timer_banana_timeout():
	speed = 500;
	$Banana.hide();

func _on_timer_shock_elec_timeout() -> void:
	if onShock:
		_on_shock();

func _on_timer_frozen_timeout() -> void:
	$FrozeSound2.play();
	self.can_move = true;
	self.can_launch_box = true;
	$Frozen.hide();
	$LightFrozzen.hide();
	onFreeze = false;
