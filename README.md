# The Gold Is Too Heavy

Godot starter project for the game jam.

## Getting started

1. Clone this repository.
2. Open Godot 4.6 and import `project.godot`.
3. Press **F5** to run the starting screen, intro cutscene, main menu, and main level in order. Choose **PLAY** in the main menu to enter the level.
4. To run the main level directly, open `apocalyptic_world.tscn` and press **F6**. Move with **WASD** or the **arrow keys**.

The main level includes the teammate's tile map, dog house, animated gates, fleeing sandwiches, and patrolling salads. Sandwiches increase the dog's strength by 0.2; gates open at strength 1 and 2. Touching a salad returns the dog to its spawn and removes that salad. The project uses Godot 4.6 with the GL Compatibility renderer.

`main_scene.tscn` remains available as the earlier gameplay prototype.

Touch Sans to start a conversation from `dialogue_sans.txt`. Advance with **Enter**, **Space**, **E**, or a **left click**. The world pauses during the conversation. To talk again, leave and touch Sans again at least one second after closing the dialogue; subsequent conversations use the text after the `// if interructed again:` marker.

## Version control

Commit project files, scenes, scripts, and source assets. Godot's generated `.godot/` cache is excluded from Git and recreated when the project is opened.
