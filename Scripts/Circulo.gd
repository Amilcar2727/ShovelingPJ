extends Node2D

# Dibujar circulo rojo
var alpha = 0.0
@export var duracion = 10
var elapsed_time = 0;
var animating = false
func _process(delta):
	if animating:
		if alpha < 0.9:
			elapsed_time += delta;
			alpha = elapsed_time/duracion;
			alpha = clamp(alpha,0.0,1.0);
			queue_redraw();
		else:
			#Detener animacion
			animating = false;
			await get_tree().create_timer(0.5).timeout;
			queue_free();

func _draw():
	draw_circle(Vector2.ZERO,50,Color(1,0,0,alpha));
func iniciar_circulo(time:float):
	duracion = time;
	# Reinicia
	elapsed_time = 0.0
	alpha = 0.0
	animating = true;
