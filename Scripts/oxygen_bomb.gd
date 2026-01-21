extends BaseBox

func _ready():
	typeName = "OxygenBomb"
	super()
	
func ChangeColorRed():
	$AnimatedSprite2D.modulate = Color(1, 0.1, 0.1, 1);
	actual_modulate = "red";
func ChangeColorBlue():
	$AnimatedSprite2D.modulate = Color(0.1, 0.35, 1, 1);
	actual_modulate = "blue";
