extends BaseBox

var exploting := false;
var on_laser := false;

func _ready():
	typeName = "OxygenBomb"
	$ExplosionArea.monitoring = false; #Empieza apagado
	$ExplosionSprite.visible = false;
	$AnimatedSprite2D.visible = true;
	exploting = false;
	on_laser = false;
	$Luces.visible = false;
	super()
	
func ChangeColorRed():
	$AnimatedSprite2D.modulate = Color(1, 0.1, 0.1, 1);
	actual_modulate = "red";
func ChangeColorBlue():
	$AnimatedSprite2D.modulate = Color(0.1, 0.35, 1, 1);
	actual_modulate = "blue";

func _on_body_entered(_body):
	print("_on_body_entered:", _body);
	##Si el cuerpo choca con el jugador, hiteable, o piso, explota
	if (_body.name in ["Floor1", "Floor2"]) and _body != self:
		var piso = _body.name;
		print("Impacto en ",piso);
		if hitted:
			explote(piso);
		else:
			pass;
	super._on_body_entered(_body);
	
func explote(piso:="Floor1"):
	if exploting:
		return;
	exploting = true;
	print("EXPLOTANDO!!");
	# Apagamos el area de una vez para evitar fuerzas adicionales
	$CollisionShape2D.call_deferred("set_disabled",true);
	set_deferred("linear_velocity",Vector2.ZERO); #Lo detenemos
	set_deferred("angular_velocity", 0);
	#Rotacion Forzada
	if piso == "Floor1":
		set_deferred("rotation",0);
	else:
		set_deferred("rotation",deg_to_rad(180));
	## Animacion de llamado a laser
	$Call.play();
	await $Call.finished;
	## Laser
	$ExplosionArea.monitoring = true;
	#Esperamos 2 frames a que se actualizen las colisiones
	await get_tree().physics_frame; #Espera un frame
	await get_tree().physics_frame; #Espera un frame
	##Prendemos area
	#Eliminamos los objetos en el area
	for body in $ExplosionArea.get_overlapping_bodies(): #Hiteables
		if body.has_method("_on_explosion") and body != self:
			body._on_explosion(self);
			
	on_laser = true;
	#Apagamos area
	$AnimatedSprite2D.visible = false;
	$ExplosionSprite.visible = true;
	$Luces.visible = true;
	$BoomSound.play();
	if piso == "Floor1":
		set_deferred("rotation",deg_to_rad(180));
	else:
		set_deferred("rotation",0);
	$ExplosionArea/AnimationPlayer.play("laser_explosion_up_down");
	await get_tree().create_timer(1.6,false).timeout; #Simula animacion
	$ExplosionArea/AnimationPlayer.play("laser_explosion_down_up");
	on_laser = false;
	# Apagamos area
	await $BoomSound.finished;
	$ExplosionArea.monitoring = false;
	queue_free();
	
func _on_impact(_body):
	explote();
	_body.hide();
	_body.hit.emit();

func _on_explosion(_body):
	if exploting:
		return
	queue_free();

func _on_explosion_area_body_entered(body: Node2D) -> void:
	if !on_laser:
		return;
	if body.has_method("_on_explosion"):
		body._on_explosion(self);

func _on_explosion_area_area_entered(area: Area2D) -> void:
	if !on_laser:
		return;
	var rootNode = area.get_parent();
	if rootNode.has_method("_on_explosion") and rootNode != self:
		rootNode._on_explosion(self);
	
