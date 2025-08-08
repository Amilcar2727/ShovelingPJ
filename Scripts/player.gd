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
var shovel_action = "";
var shovel_up_action = "";
var shovel_ready = false;
var current_box = null;
var impulso_fuerza = 600;
var can_launch_box = true; #Timer
# Banana
var onBanana:bool;
func _ready():
	onBanana = false;
	screen_size = get_viewport_rect().size;
	orientation = "right";
	$Banana.hide();
	hide();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
	if body.name != "Antena":
		if body.last_hitter != player_id and body.last_hitter != 0 and body.linear_velocity.length() > 300:
			if body.typeName == "Box":
				print(body.name);
				hide();
				body.queue_free();
				hit.emit();
				$CollisionArea/CollisionShape2D.set_deferred("disabled",true);
				$ShovelingArea/ShovelingShape2D.set_deferred("disabled",true);
			else:
				body.queue_free();
				onBanana = true;
func _on_shoveling_area_body_entered(body):
	#Color
	if body.has_node("AnimatedSprite2D"):
		if player_id == 1:
			body.ChangeColorRed();
		elif player_id == 2:
			body.ChangeColorBlue();
	if body.is_in_group("box"):
		current_box = body;
		shovel_ready = true;
func _on_shoveling_area_body_exited(body):
	if body.has_node("AnimatedSprite2D"):
		if !body.hitted:
			body.ChangeColorOrig();
		elif body.hitted and body.last_hitter != player_id and body.last_hitter != 0:
			if player_id == 1:
				body.ChangeColorBlue();
			else:
				body.ChangeColorRed();
	if body == current_box:
		current_box = null;
		
func set_launch(mode:String):
	if shovel_ready and can_launch_box and current_box:
		if player_id == 1:
			if mode == "especial":
				launch_box(impulso_fuerza,-90);
				can_launch_box = false;
				$TimerShovel.start();
				return;
			if orientation == "right":
				launch_box(impulso_fuerza,-60);
			elif orientation == "left":
				launch_box(impulso_fuerza,-120);
		elif player_id == 2:
			if mode == "especial":
				launch_box(impulso_fuerza,90);
				can_launch_box = false;
				$TimerShovel.start();
				return;
			if orientation == "right":
				launch_box(impulso_fuerza,60);
			elif orientation == "left":
				launch_box(impulso_fuerza,120);
		can_launch_box = false;
		$TimerShovel.start();
		
func launch_box(impulso:float, angulo:float):
	if current_box:
		if current_box.hitted == false:
			current_box.hitted = true;
		current_box.set_collision_mask_value(1,true);
		current_box.linear_velocity = Vector2.ZERO;
		var anguloF = deg_to_rad(angulo);
		var vector_fuerza = Vector2(cos(anguloF),sin(anguloF)) * impulso;
		current_box.apply_impulse(vector_fuerza);
		
		current_box.last_hitter = player_id;
		current_box = null;
		shovel_ready = false;
			
func _on_timer_timeout():
	can_launch_box = true;

func _on_timer_banana_timeout():
	speed = 500;
	$Banana.hide();
