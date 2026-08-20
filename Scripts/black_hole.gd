extends Node2D

var on_blackh:=true;
var forceMid := 600;
var forceOuter := 450; 
var fuerzas_guardadas := {};
var bodies_guardados := [];
## Laser Congelante
@export var laser_scene:PackedScene;
var on_laser := false;
var instancia_laser1 = null;
var instancia_laser2 = null;
#Tweens
var active_tweens := []

##Referencias nodos
@onready var ExplosionArea = $BlackHole/ExplosionArea;
@onready var MidArea2 = $BlackHole/MidArea2;
@onready var OuterArea3 = $BlackHole/OuterArea3;

@onready var ExplosionSprite = $BlackHole/ExplosionSprite;
@onready var Luces = $BlackHole/Luces;
@onready var BoomSound = $BlackHole/BoomSound;

var finished := false;

func _ready():
	ExplosionArea.monitoring = false; #Empieza apagado
	MidArea2.monitoring = false; #Empieza apagado
	OuterArea3.monitoring = false; #Empieza apagado
	ExplosionSprite.visible = false;
	on_blackh = false;
	Luces.visible = false;
	fuerzas_guardadas = {};
	explote();

func _StartTimerLaser(time:=4) -> void:
	$TimerLaser.wait_time = time;
	if on_laser:
		return;
	$TimerLaser.start();
	
func _ChangeForces(force:Vector2):
	forceOuter = force.x;
	forceMid = force.y;
	
func _physics_process(_delta: float) -> void:
	if !on_blackh:
		return;
	_apply_force(OuterArea3, forceOuter);
	_apply_force(MidArea2, forceMid);

func _apply_force(area:Area2D, fuerza:float):
	for body in area.get_overlapping_bodies():
		if body is BaseBox and body != self:
			body.hitted = true;
			# Direccion del agujero negro al objeto
			var dir = ($BlackHole.global_position - body.global_position).normalized();
			var force_vector = dir * fuerza * body.mass;
			# Aplicamos impulso
			body.apply_central_force(force_vector);
	##Players
	for area_overlapped:Area2D in area.get_overlapping_areas():
		var rootNode = area_overlapped.get_owner();
		if not fuerzas_guardadas.has(rootNode):
			fuerzas_guardadas[rootNode] = rootNode.fuerzaExterna;
		# Direccion del agujero negro al objeto
		var dir = ($BlackHole.global_position - rootNode.global_position).normalized();
		var fuerza_aplicada = fuerza * 0.58;
		rootNode.fuerzaExterna = fuerza_aplicada * sign(dir.x);
	
func explote():
	## BlackHole
	ExplosionArea.monitoring = true;
	MidArea2.monitoring = true;
	OuterArea3.monitoring = true;
	#Esperamos 2 frames a que se actualizen las colisiones
	await get_tree().physics_frame; #Espera un frame
	await get_tree().physics_frame; #Espera un frame
	## Desactivamos el mask si estan en area cercana (la outer abarca todo)
	for body in OuterArea3.get_overlapping_bodies():
		if !is_instance_valid(body):
			continue;
		if body.has_method("explote") and body != self:
			body.set_collision_layer_value(7,false);
			body.set_collision_mask_value(6,false);
			if not bodies_guardados.has(body):
				bodies_guardados.append(body);
	
	#Eliminamos los objetos en el area
	for body in ExplosionArea.get_overlapping_bodies(): #Hiteables
		if body.has_method("_on_explosion") and body != self:
			if body.typeName == "OxygenBomb":
				body.queue_free();
				continue;
			body._on_explosion(self);
	for area in ExplosionArea.get_overlapping_areas(): #Players
		var rootNode = area.get_owner();
		if rootNode.has_method("_on_explosion") and rootNode != self:
			rootNode._on_explosion(self);
	
	on_blackh = true;
	ExplosionSprite.visible = true;
	Luces.visible = true;
	BoomSound.play();
	#
	_animacion_entrada();
	_animacion_giro();

func _finish_event():
	if finished:
		return;
	finished = true;
	print("Finalizando Evento")
	#Apagamos area
	var tween_finish = create_tween();
	tween_finish.set_parallel(true);
	active_tweens.append(tween_finish);
	tween_finish.tween_property(ExplosionSprite, "scale",Vector2(0.1,0.1),1);
	tween_finish.tween_property(ExplosionArea, "scale",Vector2(0.1,0.1),1);
	tween_finish.tween_property(MidArea2, "scale",Vector2(0.1,0.1),1);
	await tween_finish.finished;
	##Tweens
	print("active tweens:",len(active_tweens));
	for t in active_tweens:
		if t.is_valid():
			t.kill()
	active_tweens.clear();
	on_blackh = false;
	$BlackHole.hide();
	##Apagamos timer
	if !$TimerLaser.is_stopped():
		$TimerLaser.stop();
	## Restaurar fuerzas
	for jugador in fuerzas_guardadas.keys():
		if jugador.get_owner().rondaT:
			continue;
		var fuerza_original = fuerzas_guardadas[jugador];
		jugador.fuerzaEmpujeCinta = fuerza_original;
	## Restauramos orbes
	_restaurar_cuerpos();
	# Apagamos area
	if BoomSound.playing:
		BoomSound.stop();
	ExplosionArea.monitoring = false;
	MidArea2.monitoring = false;
	OuterArea3.monitoring = false;
	if is_instance_valid(instancia_laser1):
		await instancia_laser1.tree_exited;
	if is_instance_valid(instancia_laser2):
		await instancia_laser2.tree_exited;

func _animacion_entrada():
	var tween_aparicion = create_tween();
	tween_aparicion.set_parallel(true);
	active_tweens.append(tween_aparicion);
	tween_aparicion.tween_property(ExplosionSprite, "scale",Vector2(1,1),10);
	tween_aparicion.tween_property(ExplosionArea, "scale",Vector2(1,1),5);
	tween_aparicion.tween_property(MidArea2, "scale",Vector2(1,1),5);
	
func _animacion_giro():
	var tween_rot = create_tween()
	active_tweens.append(tween_rot);
	tween_rot.set_loops();
	tween_rot.tween_property(ExplosionSprite, "rotation", PI * 2, 2.0)\
		.as_relative()\
		.set_trans(Tween.TRANS_LINEAR);
		
	var tween_luces = create_tween();
	active_tweens.append(tween_luces);
	tween_luces.set_loops();
	tween_luces.tween_property(Luces, "rotation", PI * 2, 2.0)\
		.as_relative()\
		.set_trans(Tween.TRANS_LINEAR);
		
	var tween_scale = create_tween()
	active_tweens.append(tween_scale);
	tween_scale.set_loops()  # Loop infinito
	tween_scale.tween_property(ExplosionSprite, "scale", Vector2(1.1,1.1), 0.8)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT);
		
	tween_scale.tween_property(ExplosionSprite, "scale", Vector2(0.9,0.9), 0.8)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN);

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

func instanciar_laser() -> void:
	if on_laser:
		return;
	print("Instanciando Laser!!");
	on_laser = true;
	instancia_laser1 = laser_scene.instantiate();
	instancia_laser2 = laser_scene.instantiate();
	const spawn_y = 500;
	var spawn1_x = randi_range(40,410);
	var spawn2_x = randi_range(860,1230);
	instancia_laser1.position = Vector2(spawn1_x,spawn_y);
	instancia_laser2.position = Vector2(spawn2_x,spawn_y);
	add_child(instancia_laser1);
	add_child(instancia_laser2);
	on_laser = false;
	
func _on_timer_laser_timeout() -> void:
	if on_laser or finished:
		return;
	instanciar_laser();
