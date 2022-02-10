package;

/*import h2d.TileGroup;
import h2d.Interactive;
import h2d.Object;
import h2d.Scene;*/
import hxd.res.DefaultFont;

import scenes.*;

/**
 * The main class including all other classes here in the code.
 */
class GameApp extends hxd.App {

    public static var app : GameApp; // just represents this app as an individual "living" object (instance of this class)
    public var world : Scene_Game;

    override function update(dt:Float) {
        if( world!=null )
            world.update();
    }

    override function init() {
        this.setScene( new Scene_Intro() ); // starts with the intro scene
    }

    public static function getMyFont() {
        return DefaultFont.get();
    }

    static function main() {
        trace("inside my main function");
        trace("(You will need *trace* a lot to actively debug your game)");
        #if sys
        hxd.Res.initLocal(); // important! allows the app access to our game's resource files: images (sprites), audio, etc.
        #else
        hxd.Res.initEmbed(); // use hxd.Res.initEmbed(); for html5/js
        #end
        app = new GameApp(); // now HeapsIO starts...
    }

}

/**
 * A Non-player-character that inhabits the game world.
 * It can be clicked on using the left mouse button.
 */
/*class NPC extends Entity {

    private var interactive : h2d.Interactive;
    private var COLOR_DEFAULT : Int = 0xFFAAAAAA;
    private var COLOR_ONFOCUS : Int = 0xFFAAFFAA;

    override function update() {
        super.update();
        // loses focus when clicking somewhere else
        if( hxd.Key.isDown( hxd.Key.MOUSE_LEFT) )
            interactive.backgroundColor = COLOR_DEFAULT;
    }

    override function init( ){
        var myrandomgen = hxd.Rand.create();
        this.x = myrandomgen.random( scene.width );
        this.y = myrandomgen.random( scene.height );
        trace('${this} position is (${this.x}|${this.y})');
    }

    override function init_sprite() { // init sprite
        interactive = new h2d.Interactive( 50, 50, scene );
        interactive.backgroundColor = 0xFFAAAAAA;
        interactive.onClick = function(e){interactive.backgroundColor = COLOR_ONFOCUS;}; //regains focus when clicking *on* the entity
        this.sprite = interactive;
        var info = new h2d.Text( hxd.res.DefaultFont.get(), sprite ); info.text = "NPC";
    }
}*/
