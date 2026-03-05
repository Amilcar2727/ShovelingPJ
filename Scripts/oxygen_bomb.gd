extends BaseBox

var exploting = false;

func _ready():
	typeName = "OxygenBomb"
	$ExplosionArea.monitoring = false; #Empieza apagado
	$ExplosionSprite.visible = false;
	$AnimatedSprite2D.visible = true;
	exploting = false;
	$Luces.visible = false;
	super()
	
func ChangeColorRed():
	$AnimatedSprite2D.modulate = Color(1, 0.1, 0.1, 1);
	actual_modulate = "red";
func ChangeColorBlue():
	$AnimatedSprite2D.modulate = Color(0.1, 0.35, 1, 1);
	actual_modulate = "blue";

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
	print("EXPLOTANDO!!");
	linear_velocity = Vector2.ZERO #Lo detenemos
	$ExplosionArea.monitoring = true;
	#Esperamos 2 frames a que se actualizen las colisiones
	await get_tree().physics_frame; #Espera un frame
	await get_tree().physics_frame; #Espera un frame
	#Eliminamos los objetos en el area
	for body in $ExplosionArea.get_overlapping_bodies(): #Hiteables
		if body.has_method("_on_explosion") and body != self:
			#print(body.name);
			body._on_explosion(self);
	for area in $ExplosionArea.get_overlapping_areas(): #Players
		var rootNode = area.get_parent();
		if rootNode.has_method("_on_explosion") and rootNode != self:
			rootNode._on_explosion(self);
	#Apagamos area
	$ExplosionArea.monitoring = false;
	$CollisionShape2D.disabled = true;
	$AnimatedSprite2D.visible = false;
	$ExplosionSprite.visible = true;
	$Luces.visible = true;
	await get_tree().create_timer(0.5,false).timeout; #Simula animacion
	queue_free();
	
func _on_impact(_body):
	explote();
	_body.hide();
	_body.hit.emit();

func _on_explosion(_body):
	if exploting:
		return
	await get_tree().create_timer(0.08,false).timeout;
	explote();
