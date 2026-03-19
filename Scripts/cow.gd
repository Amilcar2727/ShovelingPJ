extends BaseBox
signal cow_died; #:(

func _ready():
	typeName = "Cow"
	super()
	use_local_direction = true;
	angular_velocity = 3;
	angular_damp = 0;
	angular_damp_mode = RigidBody2D.DAMP_MODE_REPLACE
	tree_exiting.connect(_on_tree_exiting);
	$CowSound1.play();
	
func _on_body_entered(_body):
	super(_body);
	if !$CowSound2.playing:
		$CowSound2.play();

func Delete_by_itself():
	if $CowSound1.playing:
		await $CowSound1.finished;
	elif $CowSound2.playing:
		await $CowSound2.finished;
	call_deferred("queue_free");
# Emitir señal cuando se elimina la vaca
func _on_tree_exiting():
	emit_signal("cow_died");
	
func _on_impact(_body):
	pass;

func ChangeColor(player_id):
	pass;
