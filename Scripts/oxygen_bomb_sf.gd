extends BaseBox

var exploting := false;
var on_blackh := false;
var fuerzas_guardadas := {};
var bodies_guardados := [];

func _ready():
	typeName = "OxygenBomb"
	$ExplosionArea.monitoring = false; #Empieza apagado
	$MidArea2.monitoring = false; #Empieza apagado
	$OuterArea3.monitoring = false; #Empieza apagado
	$ExplosionSprite.visible = false;
	$AnimatedSprite2D.visible = true;
	exploting = false;
	on_blackh = false;
	$Luces.visible = false;
	fuerzas_guardadas = {};
	super()
	
func ChangeColorRed():
	$AnimatedSprite2D.modulate = Color(1, 0.1, 0.1, 1);
	actual_modulate = "red";
func ChangeColorBlue():
	$AnimatedSprite2D.modulate = Color(0.1, 0.35, 1, 1);
	actual_modulate = "blue";
	
func _physics_process(_delta: float) -> void:
	if !on_blackh:
		return;
	_apply_force($OuterArea3, 350);
	_apply_force($MidArea2, 525);

func _apply_force(area:Area2D, fuerza:float):
	for body in area.get_overlapping_bodies():
		if body is BaseBox and body != self:
			body.hitted = true;
			# Direccion del agujero negro al objeto
			var dir = (self.global_position - body.global_position).normalized();
			var force_vector = dir * fuerza * body.mass;
			# Aplicamos impulso
			body.apply_central_force(force_vector);
	##Players
	for area_overlapped:Area2D in area.get_overlapping_areas():
		var rootNode = area_overlapped.get_owner();
		if not fuerzas_guardadas.has(rootNode):
			fuerzas_guardadas[rootNode] = rootNode.fuerzaExterna;
		# Direccion del agujero negro al objeto
		var dir = (self.global_position - rootNode.global_position).normalized();
		var fuerza_aplicada = fuerza * 0.36;
		rootNode.fuerzaExterna = fuerza_aplicada * sign(dir.x);

func _on_body_entered(_body):
	##Si el cuerpo choca con el jugador, hiteable, o piso, explota
	if (_body.name in ["Floor1", "Floor2"] or _body.is_in_group("box")) and _body != self:
		if hitted:
			explote();
		else:
			pass;
	super._on_body_entered(_body);
	
func explote():
	if exploting:
		return;
	exploting = true;
	# Apagamos el area de una vez para evitar fuerzas adicionales
	if !get_tree().current_scene.onSDEvent:
		$CollisionShape2D.call_deferred("set_disabled",true);
		set_deferred("linear_velocity",Vector2.ZERO); #Lo detenemos
		set_deferred("angular_velocity", 0);
	## Animacion de llamado a blackhole
	$Call.play();
	
	## BlackHole
	$ExplosionArea.monitoring = true;
	$MidArea2.monitoring = true;
	$OuterArea3.monitoring = true;
	#Esperamos 2 frames a que se actualizen las colisiones
	await get_tree().physics_frame; #Espera un frame
	await get_tree().physics_frame; #Espera un frame
	## Desactivamos el mask si estan en area cercana (la outer abarca todo)
	for body in $OuterArea3.get_overlapping_bodies():
		if !is_instance_valid(body):
			continue;
		if body.has_method("explote") and body != self:
			body.set_collision_layer_value(7,false);
			body.set_collision_mask_value(6,false);
			if not bodies_guardados.has(body):
				bodies_guardados.append(body);
	
	#Eliminamos los objetos en el area
	for body in $ExplosionArea.get_overlapping_bodies(): #Hiteables
		if body.has_method("_on_explosion") and body != self:
			print("On_explosion_bodies: ",body.typeName);
			if body.typeName == "OxygenBomb":
				body.queue_free();
				continue;
			#print(body.name);
			body._on_explosion(self);
	for area in $ExplosionArea.get_overlapping_areas(): #Players
		var rootNode = area.get_owner();
		if rootNode.has_method("_on_explosion") and rootNode != self:
			rootNode._on_explosion(self);
	##Prendemos area
	on_blackh = true;
	$AnimatedSprite2D.visible = false;
	if $SnowMan.visible:
		$SnowMan.visible = false;
	$ExplosionSprite.visible = true
	$Luces.visible = true;
	$BoomSound.play();
	#
	_animacion_giro();
	await get_tree().create_timer(3,false).timeout; #Simula animacion
	#Apagamos area
	on_blackh = false;
	## Restaurar fuerzas
	for jugador in fuerzas_guardadas.keys():
		if jugador.get_owner().rondaT:
			continue;
		var fuerza_original = fuerzas_guardadas[jugador];
		jugador.fuerzaEmpujeCinta = fuerza_original;
	## Restauramos orbes
	_restaurar_cuerpos();
	# Apagamos area
	if $BoomSound.playing:
		await $BoomSound.finished;
	$ExplosionArea.monitoring = false;
	$MidArea2.monitoring = false;
	$OuterArea3.monitoring = false;
	queue_free();
		
func _animacion_giro():
	var tween_rot = create_tween()
	tween_rot.set_parallel(true);
	tween_rot.tween_property($ExplosionSprite, "rotation", PI * 2, 4.0)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_OUT);
	tween_rot.tween_property($Luces, "rotation", PI * 2, 4.0)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_OUT);
		
	var tween_scale = create_tween()
	tween_scale.set_loops()  # Loop infinito
	tween_scale.tween_property($ExplosionSprite, "scale", Vector2(0.52,0.52), 0.6)\
		.set_trans(Tween.TRANS_SINE);
	tween_scale.tween_property($ExplosionSprite, "scale", Vector2(0.48,0.48), 0.6)\
		.set_trans(Tween.TRANS_SINE);
		
func _on_impact(_body):
	explote();
	_body.hide();
	_body.hit.emit();

func _on_explosion(_body):
	if exploting and not get_tree().current_scene.onSDEvent:
		return
	queue_free();

func _on_explosion_area_body_entered(body: Node2D) -> void:
	if !on_blackh:
		return;
	if body.has_method("_on_explosion"):
		body._on_explosion(self);

func _on_explosion_area_area_entered(area: Area2D) -> void:
	if !on_blackh:
		return;
	var rootNode = area.get_owner();
	if rootNode.has_method("_on_explosion") and rootNode != self:
		rootNode._on_explosion(self);

#Entrada blackhole para orbes
func _on_outer_area_3_body_entered(body: Node2D) -> void:
	if !is_instance_valid(body):
		return;
	if body.has_method("explote") and body != self:
		body.set_collision_layer_value(7,false);
		body.set_collision_mask_value(6,false);
		if not bodies_guardados.has(body):
			bodies_guardados.append(body);

func _on_outer_area_3_body_exited(body: Node2D) -> void:
	if !is_instance_valid(body):
		return;
	if body.has_method("explote") and body != self:
		body.set_collision_mask_value(6,true);
		body.set_collision_layer_value(7,true);
		var b = bodies_guardados.find(body);
		bodies_guardados.pop_at(b);

func _restaurar_cuerpos():
	for body in bodies_guardados:
		if not is_instance_valid(body):
			continue
		body.set_collision_layer_value(7,true);
		body.set_collision_mask_value(6,true);
	bodies_guardados.clear();
	
func _exit_tree() -> void:
	_restaurar_cuerpos();
