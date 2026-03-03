extends Node2D;
signal hit;
@export var speed=500;	#How fast the player will move (pixel/sec)
@export var player_id = 1;
var screen_size;	#Size of the game window
#Score
var score = 0;
#Movement
var left_action = "";
var right_action = "";
@export var fuerzaEmpujeCinta = -3000;
#Orientation
var orientation = "right";
#Powers
var shovel_action := "";
var shovel_up_action := "";
#var shovel_ready := false;
var current_boxes := [];
var impulso_fuerza = 600;
var can_launch_box = true; #Timer
# Animation y more
var can_move := false;
# Banana
var enviado = false; ##  Debug
var onBanana:bool;
func _ready():
	can_move = false;
	onBanana = false;
	screen_size = get_viewport_rect().size;
	orientation = "right";
	$Banana.hide();
	$PointLight2D.hide();
	hide();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !can_move:
		return;
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
		$BananaSound.play();
		speed = 200;
		$Banana.show();
		$TimerBanana.start();
		onBanana = false;
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed;
		$AnimatedSprite2D.play();
	else:
		$AnimatedSprite2D.stop();
	#Fuerza Cintas Transportadoras
	var left_push_force = Vector2(fuerzaEmpujeCinta, 0);
	velocity += left_push_force * delta
	#Flip
	leftOrRight(orientation);
	position += velocity * delta;
	position = position.clamp(Vector2.ZERO, screen_size);
	
	if velocity.x!=0:
		$AnimatedSprite2D.animation = "walk";

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
				$CollisionArea/CollisionShape2D.set_deferred("disabled",true);
				$ShovelingArea/ShovelingShape2D.set_deferred("disabled",true);
			elif body.typeName == "Garbage":
				body._on_impact(self);
			elif body.typeName == "OxygenBomb":
				body._on_impact(self);
				$CollisionArea/CollisionShape2D.set_deferred("disabled",true);
				$ShovelingArea/ShovelingShape2D.set_deferred("disabled",true);
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
		changeColorBody('clear');
		current_boxes.push_back(body);
		changeColorBody('draw');
		
func _on_shoveling_area_body_exited(body):
	var box_index = current_boxes.find(body);
	if box_index != -1:
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
			launch_box(impulso_fuerza,-120*player);
	
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
	## Este hiteado o no
	current_box.hitted = true;

	current_box.last_hitter = player_id;
	current_box.set_collision_mask_value(1,true);
	current_box.linear_velocity = Vector2.ZERO;
	var anguloF = deg_to_rad(angulo);
	var vector_fuerza = Vector2(cos(anguloF),sin(anguloF)) * impulso;
	current_box.apply_impulse(vector_fuerza);
			
func _on_timer_timeout():
	can_launch_box = true;

func _on_explosion(_body):
	hide();
	hit.emit();

func _on_dead():
	if self.visible == true:
		self.visible = false;
	self.position = Vector2(0,0);

func _on_dark(v=true):
	$PointLight2D.visible = v;
	
func _on_timer_banana_timeout():
	speed = 500;
	$Banana.hide();
