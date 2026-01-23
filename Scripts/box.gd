extends BaseBox

func _ready():
	typeName = "Box"
	super()

func _on_impact(_body):
	_body.hide();
	_body.hit.emit();
	queue_free();
