extends BaseBox
signal cow_died; #:(
var inmortal := false;
var _ultimo_rebote := 0.0
var _cooldown_rebote := 0.1  # segundos
var vel_objetivo: Vector2
var impulso_extra := Vector2.ZERO
var on_animation:=false;

func _ready():
	typeName = "Cow"
	super()
	if inmortal:
		freeze = true;
		on_animation = true;
		$AnimationPlayer.play("Spawn_Cyborg");
		await $AnimationPlayer.animation_finished;
		freeze = false;
		on_animation = false;
	use_local_direction = true;
	angular_velocity = 3;
	angular_damp = 0;
	angular_damp_mode = RigidBody2D.DAMP_MODE_REPLACE
	vel_objetivo = Vector2(randf_range(-200,200), randf_range(-200,200))
	tree_exiting.connect(_on_tree_exiting);
	if inmortal:
		$CowSound2.play();
	else:
		$CowSound1.play();
func _process(delta):
	if inmortal:
		return
	super(delta);
	
func _on_body_entered(_body):
	super(_body);
	if !$CowSound2.playing:
		$CowSound2.play();

func aplicar_impulso_custom(imp: Vector2):
	impulso_extra += imp
	
func _integrate_forces(state: PhysicsDirectBodyState2D):
	super(state)
	if not inmortal:
		return
	_ultimo_rebote -= state.step
	# 💥 combinar velocidad base + impulsos
	var vel_final = vel_objetivo + impulso_extra
	# 🚨 SIEMPRE forzar velocidad base
	state.linear_velocity = vel_final
	# 🔻 disipar impulso poco a poco
	impulso_extra = impulso_extra.lerp(Vector2.ZERO, 0.1)
	# 🚫 Evitar rebotes múltiples seguidos
	if _ultimo_rebote > 0:
		return
	# Procesar contactos
	for i in state.get_contact_count():
		var normal = state.get_contact_local_normal(i)
		# 💥 rebote basado en TU velocidad, no la del motor
		vel_objetivo = vel_objetivo.bounce(normal)
		# mantener intensidad constante
		vel_objetivo = vel_objetivo.normalized() * 900
		# Aplicar la nueva velocidad
		state.linear_velocity = vel_objetivo
		# Pequeño efecto angular para más caos
		state.angular_velocity = randf_range(-8, 8)
		# 🔥 activar cooldown
		_ultimo_rebote = _cooldown_rebote
		# Solo procesar el primer contacto
		break
		
func Delete_by_itself():
	if inmortal:
		return;
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
func _on_explosion(_body):
	if !inmortal:
		queue_free();
	else:
		pass;
func ChangeColor(player_id):
	pass;
