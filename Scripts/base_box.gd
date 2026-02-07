extends RigidBody2D
class_name BaseBox

var speed = 100;
var hitted = false;
var last_hitter = 0;
var actual_modulate = "normal";
var typeName = "Box";
var ultima_velocidad:Vector2;
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("box");
	_play_random_animation();
	_fix_orientation();
	_setup_physics();
	actual_modulate = "normal";

func _process(_delta):
	if not hitted:
		linear_velocity = Vector2(-speed, 0);
		
#Obtenemos la ultima velocidad pre impacto
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	ultima_velocidad = state.get_linear_velocity();
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	await get_tree().create_timer(1,false).timeout; #Esperamos 1 segundo para eliminarlo
	queue_free();

func _on_body_entered(_body):
	hitted = true;
	
func _on_impact(_body):
	pass;
	
func _on_explosion(_body):
	queue_free();
	
## Helpers
func _play_random_animation():
	var anims = $AnimatedSprite2D.sprite_frames.get_animation_names();
	$AnimatedSprite2D.play(anims[randi()%anims.size()]);

func _fix_orientation():
	if(position.y<300):
		$AnimatedSprite2D.scale.y = -0.08;
		
func _setup_physics():
	contact_monitor = true;
	max_contacts_reported = 1;
	connect("body_entered",Callable(self,"_on_body_entered"));
	
static func elegirCajaType():
	var random = randf();
	const cajas = [
		{"tipo": 1, "prob": 0.60}, ##Caja
		{"tipo": 2, "prob": 0.10}, ##Basura
		{"tipo": 3, "prob": 0.10}, ##BalonOxigeno 0.07
		{"tipo": 4, "prob": 0.20}, ##Nada
	]
	var acumulado = 0.0
	for op in cajas:
		acumulado += op["prob"]
		if(random <= acumulado):
			return op["tipo"];
	return null;

## Colores
func ChangeColor(player_id):
	if player_id == 1:
		ChangeColorRed();
	elif player_id == 2:
		ChangeColorBlue();
	else:
		ChangeColorOrig();

func ChangeColorOrig():
	$AnimatedSprite2D.modulate = Color(1,1,1,1);
	actual_modulate = "normal";
func ChangeColorRed():
	$AnimatedSprite2D.modulate = Color(0.75, 0, 0, 1);
	actual_modulate = "red";
func ChangeColorBlue():
	$AnimatedSprite2D.modulate = Color(0, 0, 0.75, 1);
	actual_modulate = "blue";
	
