package;

import GameApp;

/**
 * A base class for all game objects (entities) that will be added to the game.
 * These might be the player, enemies, trees, stones... anything that is put in the game world.
 */
 class Entity {
    public var scene : h2d.Scene; // the entity should know the scene/"level" it belongs to
    public var sprite : h2d.Object; // can be anything that extends h2d.Object
    public var x : Float = 0;
    public var y : Float = 0;

    public function new( scene:h2d.Scene ) {
        GameApp.app.world.gameObjects.push( this );
        this.scene = scene;
    }
    /**
     * Call super.update() when overriding.
     */
    public function update() {
        // this will update the sprite to the right position
        sprite.setPosition( this.x, this.y );
    }
}