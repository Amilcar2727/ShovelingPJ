extends RigidBody2D

var speed = 100;
var hitted = false;
var ultima_velocidad:Vector2;
var last_hitter = 0;
var actual_modulate = "";
var typeName = "Box";
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("box");
	var box_types = $AnimatedSprite2D.sprite_frames.get_animation_names();
	$AnimatedSprite2D.play(box_types[randi()%box_types.size()]);
	if(position.y<300):
		$AnimatedSprite2D.scale.y = -0.08;
	contact_monitor = true;
	max_contacts_reported = 1;
	connect("body_entered",Callable(self,"_on_body_entered"));
	actual_modulate = "normal";
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if hitted:
		pass;
	else:
		linear_velocity = Vector2(-speed, 0);
#Obtenemos la ultima velocidad pre impacto
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	ultima_velocidad = state.get_linear_velocity();
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free();
	
func ChangeColorOrig():
	$AnimatedSprite2D.modulate = Color(1,1,1,1);
	actual_modulate = "normal";
func ChangeColorRed():
	$AnimatedSprite2D.modulate = Color(0.75, 0, 0, 1);
	actual_modulate = "red";
func ChangeColorBlue():
	$AnimatedSprite2D.modulate = Color(0, 0, 0.75, 1);
	actual_modulate = "blue";
	
func _on_body_entered(body):
	hitted = true;
