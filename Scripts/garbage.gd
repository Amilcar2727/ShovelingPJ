extends BaseBox

func _ready():
	typeName = "Garbage"
	super()
	
func _on_impact(_body):
	$BananaSound.play();
	_body.onBanana = true;
	self.hide();
	await $BananaSound.finished;
	queue_free();
	
func ChangeColorRed():
	$AnimatedSprite2D.modulate = Color(1, 0.1, 0.1, 1);
	actual_modulate = "red";
func ChangeColorBlue():
	$AnimatedSprite2D.modulate = Color(0.1, 0.35, 1, 1);
	actual_modulate = "blue";
