extends Area2D
@onready var antena = get_parent().get_node("Antena");

func _ready() -> void:
	if antena.apunta_jugador == 1:
		scale.y = -1;
	else:
		scale.y = 1;
		
func _on_body_entered(_body: Node2D) -> void:
	scale.y = -scale.y;
	if antena.apunta_jugador == 1:
		$SonidoCambio.play();
	else:
		$SonidoCambio2.play();
	if antena!=null:
		antena.scale.y *= -1;
