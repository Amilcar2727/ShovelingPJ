extends BaseBox

func _ready():
	typeName = "Garbage"
	super()
	
func _on_impact(_body):
	if _body.has_method("_electric_shock"):
		print("Electrocutando!");
		_body._electric_shock();
	queue_free();
	
func ChangeColorRed():
	$AnimatedSprite2D.modulate = Color(1, 0.1, 0.1, 1);
	actual_modulate = "red";
func ChangeColorBlue():
	$AnimatedSprite2D.modulate = Color(0.1, 0.35, 1, 1);
	actual_modulate = "blue";
