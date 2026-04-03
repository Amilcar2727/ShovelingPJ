extends RigidBody2D
class_name BaseBox

static var direction_all := -1; ##Usado en 1er mapa
static var speed_all = 100; ##Usado en 1er mapa
var direction_local := -1; ##Usado en 2do
var speed_local := 100; ##Usado en 2do

var use_local_direction := false; ##Flag para usar local o global

var hitted = false;
var last_hitter = 0;
var actual_modulate = "normal";
var typeName = "Box";
var ultima_velocidad:Vector2;
var out_screen := false;

var tepeando := false;
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("box");
	_play_random_animation();
	_fix_orientation();
	_setup_physics();
	actual_modulate = "normal";
	var notifier = find_child("VisibleOnScreenNotifier2D", true, false);
	if notifier:
		notifier.screen_exited.connect(_on_screen_exited)
	out_screen = false;

func actualizar_velocidad(nueva_vel: int):
	if use_local_direction:
		speed_local = nueva_vel;

func _physics_process(_delta: float) -> void:
	pass;

func _process(_delta):
	if not hitted:
		if use_local_direction:
			linear_velocity = Vector2(speed_local * direction_local, 0);
		else:
			linear_velocity = Vector2(speed_all * direction_all, 0);
			
#Obtenemos la ultima velocidad pre impacto
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	ultima_velocidad = state.get_linear_velocity();

func _on_body_entered(_body):
	hitted = true;
	
func swapCS():
	if $CollisionShape2D.disabled == true:
		$CollisionShape2D.call_deferred("set_disabled",false);
	else:
		$CollisionShape2D.call_deferred("set_disabled",true);
	
func _on_impact(_body):
	pass;

func _on_explosion(_body):
	queue_free();
	
func _on_screen_exited():
	out_screen = true;
	
## Helpers
func _play_random_animation():
	var anims = $AnimatedSprite2D.sprite_frames.get_animation_names();
	$AnimatedSprite2D.play(anims[randi()%anims.size()]);

func _fix_orientation():
	if(position.y<300):
		self.scale.x = -self.scale.x;
		
func _setup_physics():
	contact_monitor = true;
	max_contacts_reported = 1;
	connect("body_entered",Callable(self,"_on_body_entered"));
	
static func elegirCajaType(t):
	var random = randf();
	var cajas:Array
	match t:
		1:
			cajas = [
				{"tipo": 1, "prob": 0.65}, ##Caja
				{"tipo": 2, "prob": 0.15}, ##Basura
				{"tipo": 3, "prob": 0.10}, ##BalonOxigeno 0.07
				{"tipo": 4, "prob": 0.10}, ##Nada
			]
		2:
			cajas = [
				{"tipo": 1, "prob": 0.55}, ##Caja
				{"tipo": 2, "prob": 0.20}, ##Basura
				{"tipo": 3, "prob": 0.15}, ##BalonOxigeno 0.07
				{"tipo": 4, "prob": 0.10}, ##Nada
			]
		_:
			cajas = [
				{"tipo": 1, "prob": 0.45}, ##Caja
				{"tipo": 2, "prob": 0.25}, ##Basura
				{"tipo": 3, "prob": 0.25}, ##BalonOxigeno 0.07
				{"tipo": 4, "prob": 0.05}, ##Nada
			]
	var acumulado = 0.0
	for op in cajas:
		acumulado += op["prob"]
		if(random <= acumulado):
			return op["tipo"];
	return 4;

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
func ChangeColorYellow():
	$AnimatedSprite2D.modulate = Color(1, 1, 0.15, 1);
	actual_modulate = "normal";
func ChangeSnowMan():
	$AnimatedSprite2D.hide();
	$SnowMan.show();
	self.mass = 1.4;
