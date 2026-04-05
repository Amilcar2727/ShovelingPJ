extends Node2D

var on_laser := false;

func _ready():
	$ExplosionArea.monitoring = false; #Empieza apagado
	$ExplosionSprite.visible = false;
	on_laser = false;
	$Luces.visible = false;
	$ExplosionSprite2.visible = true;
	explote();

func explote():
	## Animacion de llamado a laser
	$Call.play();
	await $Call.finished;
	await get_tree().create_timer(1,false).timeout;
	$ExplosionSprite2.hide();
	## Laser
	$ExplosionArea.monitoring = true;
	#Esperamos 2 frames a que se actualizen las colisiones
	await get_tree().physics_frame; #Espera un frame
	await get_tree().physics_frame; #Espera un frame
	##Prendemos area
	on_laser = true;
	#Apagamos area
	$ExplosionSprite.visible = true;
	$Luces.visible = true;
	$BoomSound.play();
	$ExplosionArea/AnimationPlayer.play("laser_explosion_up_down");
	await get_tree().create_timer(1.6,false).timeout; #Simula animacion
	$ExplosionArea/AnimationPlayer.play("laser_explosion_down_up");
	await $ExplosionArea/AnimationPlayer.animation_finished;
	on_laser = false;
	# Apagamos area
	await $BoomSound.finished;
	$ExplosionArea.monitoring = false;
	queue_free();

func _on_explosion_area_area_entered(area: Area2D) -> void:
	if !on_laser:
		return;
	var rootNode = area.get_owner();
	if rootNode.has_method("_freezing") and rootNode != self:
		rootNode._freezing(1.75);
