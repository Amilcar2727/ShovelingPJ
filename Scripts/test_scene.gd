extends Node2D

@onready var player1 := $Player
 
func _ready() -> void:
	player1.show();
	player1.can_move = true;
	player1.left_action = "player1_left";
	player1.right_action = "player1_right";
	player1.shovel_action = "player1_shovel";
	player1.shovel_up_action = "player1_shovel_up";

func _on_switch_area_entered(area: Area2D) -> void:
	if(area.name == "CollisionArea"):
		print("EXPLOTANDO!!");
		#Eliminamos los objetos en el area
		$ExplosionArea.monitoring = true;
		await get_tree().physics_frame; #Espera un frame
		await get_tree().physics_frame; #Espera un frame
		print($ExplosionArea.monitoring);
		print("Bodies?", $ExplosionArea.has_overlapping_bodies());
		#
		#print("Bodies:", $ExplosionArea.get_overlapping_bodies().size())
		#print("Bodies?", $ExplosionArea.has_overlapping_bodies());
		#for body in $ExplosionArea.get_overlapping_areas():
			#print("1. ",body.name);
			#body.queue_free();
