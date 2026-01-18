extends Node

@export var animCamera:AnimationPlayer;
const animaciones = [
	"camera_movement_1",
	"camera_movement_2",
]

func animationCameraInitPlay():
	for a in animaciones:
		animCamera.play(a);
		await animCamera.animation_finished
