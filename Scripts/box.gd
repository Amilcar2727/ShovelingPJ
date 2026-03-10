extends BaseBox

func _ready():
	typeName = "Box"
	super()

func _on_impact(_body):
	$HitSound.play();
	_body.hide();
	_body.hit.emit();
	self.hide();
	await $HitSound.finished;
	queue_free();
