# StairsSteppingBody3D
### CharacterBody3D that automatically controlls movement up and down the stairs

## How to use
- Set `PLAYER_COLLIDER` to whichever collider you want your body to use.
- Set `velocity` every physical frame to whatever value you wish to move;
- Don't forget to call `super(delta)` at the start of `_physics_process` if you are overriding it.


## Credits
Most of the code in this addon has been forked from other [projects](https://github.com/JheKWall/Godot-Stair-Step-Demo). Check out full list for more:
- Special thanks to [Majikayo Games](https://www.youtube.com/@MajikayoGames)
for [original solution to stair_step_down](https://youtu.be/-WjM1uksPIk)!
- Special thanks to [Myria666](https://github.com/myria666/)
for [paper on Quake movement mechanics](https://github.com/myria666/qMovementDoc)
(used for stair_step_up)!
- Special thanks to [Andicraft](https://github.com/Andicraft)
for help with implementation of stair_step_up!
- Special thanks to [JheKWall](https://github.com/JheKWall/) for
[original character controller demo](https://github.com/JheKWall/Godot-Stair-Step-Demo)
this is based on!
- [Vissa](https://github.com/Visssarion) refactored previous code
so that it could be used with Entity Component System or with Node Inheritance

## Notes:
0. All shape colliders are supported. But Capsule colliders are recommended for enemies
		due to its compatibility with the Navigation Meshes. Its up to you what shape you want to use
		for players.

1. To adjust the step-up/down height, just change the `MAX_STEP_UP`/`MAX_STEP_DOWN`.

2. This uses Jolt Physics as the default Godot Physics has a few bugs:
    - Small gaps that you should be able to fit through both ways will block you in Godot Physics.
		You can see this demonstrated with the floating boxes in front of the big stairs.
    - Walking into some objects may push the player downward by a small amount which causes
		jittering and causes the floor to be detected as a step.

TLDR: This still works with default Godot Physics, although it feels a lot better in Jolt Physics.
