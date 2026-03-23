extends Node2D

@export var antena_scene:PackedScene;
@export var bomb_scene:PackedScene;
@export var max_bombs:=6;

var objetos_adentro:=[];

func _ready() -> void:
	var rayo1 = _instanciar_rayo(Vector2(-72,384),
					Vector2(0,-5),
					Vector2(100,-5),
					2);
	var rayo2 = _instanciar_rayo(Vector2(1352,384),
					Vector2(0,-5),
					Vector2(-100,-5),
					2);
	await rayo2.finished;
	$Portal/AnimationPlayer.play("Portal_appearing");
	$Portal.play("default");
	await $Portal/AnimationPlayer.animation_finished;
	$Timer.wait_time = 0.75;
	$Timer.start();
	
func _instanciar_rayo(pos_global, pos_init, pos_end, tiempo=10):
	var new_antena = antena_scene.instantiate();
	new_antena.position = pos_global;
	new_antena.punto_init = pos_init;
	new_antena.punto_final = pos_end;
	new_antena.tiempo = tiempo;
	add_child(new_antena);
	return new_antena

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is BaseBox and body.typeName == "Cow":
		await get_tree().physics_frame; #Espera un frame
		await get_tree().physics_frame;
		objetos_adentro.clear();
		for object in $Area2D.get_overlapping_bodies(): #Hiteables
			if object is BaseBox:
				if object.typeName == "Cow":
					continue;
				objetos_adentro.append(object);
				
func spawnBomb():
	var obj = bomb_scene.instantiate();
	obj.on_SD = true;
	obj.use_local_direction = true;
	obj.hitted = true;
	obj.global_position = _get_random_position();
	objetos_adentro.append(obj);
	get_tree().current_scene.add_child(obj);
	
func _get_random_position():
	var shape = $Area2D/CollisionShape2D.shape;
	var extents = shape.extents;
	var x = randf_range(-extents.x+20, extents.x-20);
	var y = -10;
	return $Area2D.global_position + Vector2(x,y);
	
func _on_timer_timeout() -> void:
	if objetos_adentro.size() < max_bombs:
		spawnBomb();
