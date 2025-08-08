extends StaticBody2D

@export var tiempo=10;
var velocidad:float;
var alcanzoDestino = false;
var camino:PathFollow2D;
var apunta_jugador:int;
func _ready():
	apunta_jugador = randi_range(1,2);
	if apunta_jugador == 1:
		scale.y = 1;
	else:
		scale.y = -1;
	var path = $Path2D.curve;
	path.set_point_position(0,Vector2(position.x,position.y));
	path.set_point_position(1,Vector2(position.x+240,position.y));
	camino = $Path2D/PathFollow2D;
	velocidad = $Path2D.curve.get_baked_length()/tiempo;
	hide();
func _process(delta):
	if not alcanzoDestino:
		DeathLaser(delta);
func DeathLaser(delta):
	camino.progress_ratio += velocidad*delta/$Path2D.curve.get_baked_length();
	position = camino.position
	show();
	if camino.progress_ratio >= 0.98:
		alcanzoDestino = true;
		var circulo = $Circulo
		circulo.iniciar_circulo(12);
func rotar():
	scale.y = -scale.y;
