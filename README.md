# PYNT

Your sitting in a relatively comfortable chair at your desk in front of your computer. Or maybe you are laying in bed with your smartphone or a tablet. (Really, does it matter? You've got something that has a web-browser that doesn't suck on it.) You open your browser and point it to google and perform a search for "interactive fiction". Amongst the top-results, PYNT, a new interactive fiction web hub.

## Conceptual Logic

A game instance represents two things: 

1. a graph of interconnected rooms, and
2. a per-room state-machine.

Each room consists of a number of interactable objects, each of which carries a description of itself. Interacting with an object can provide the player with more information, or it may result in some permanent change to the room or the player.

Objects can be:

* A part of the scenery, which forms part of the room description.
* An item which gets added to the player's inventory; items might be required to progress through other parts of the story.
* A portal leading from the room, causing a transition to another part of the global graph.

Each successful interaction --- i.e. a command entered by the user which is successfully parsed by the game engine into something it can perform --- causes a state transition to occur. These transitions represent the history of the playthrough, and are used to update the UI with new information. State changes may be, conceptually, no-ops: they might provide new information about an object, but do not alter anything within the room. On the other hand, a state change could update a player's inventory, alter a game-variable, or cause the player to go elsewhere.