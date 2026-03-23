extends Node2D

@export var tiempo:=10;
@export var punto_init := Vector2(0,0);
@export var punto_final := Vector2(120,0);
@export var rotar:=false;

var velocidad:float;
var path:Path2D;
var path_follow:PathFollow2D;
var sprite:Sprite2D;
var alcanzoDestino = false;
var distanciaT:float;
signal finished;

func _ready():
	path = $Path2D
	path_follow = $Path2D/PathFollow2D;
	sprite = $Path2D/PathFollow2D/Sprite2D;
	_set_path();
	hide();
	
func _set_path():
	var new_curve = Curve2D.new();
	new_curve.add_point(punto_init);
	new_curve.add_point(punto_final);
	path.curve = new_curve;
	distanciaT = new_curve.get_baked_length();
	velocidad = distanciaT/tiempo;
	path_follow.progress = 0;
	path_follow.rotates = rotar;
	
	if punto_final.x < punto_init.x:
		sprite.flip_h = true;
	else:
		sprite.flip_h = false;
	
func _process(delta):
	if not alcanzoDestino:
		mover(delta);
		
func mover(delta):
	path_follow.progress += velocidad * delta;
	show();
	if path_follow.progress_ratio >= 0.99:
		alcanzoDestino = true;
		finished.emit();
		
func resetear():
	alcanzoDestino = false;
	path_follow.progress = 0;
	hide();
