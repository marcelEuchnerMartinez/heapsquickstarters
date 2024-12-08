package scenes;

import entities.*;

/**
 * The scene that represents the actual world of our game.
 * 
 * ... // This sample shows how multiple entities get updated in the game (main hxd.App).\nIt requires an array for these objects. Here they all extend a custom class Entity\nthat represents any object added to the game.
 */
 class Scene_Game extends h2d.Scene {
    public var gameObjects : Array<Entity> = [];
    public var player : Player;
    static public final LAYER_WORLD : Int = 0; // layer for entities and stuff in the game world
    static public final LAYER_HUD   : Int = 1; // layer for UI, in-game menu buttons etc.
    var info_about_camera : h2d.Text; // declare reference to be able to update this in function
    public function new() {super();}
    public function init() {

        // place all entities in this scenario/level
        // some trees
        for( i in 0...30 ){
            var t = new Tree(this);
            // assign each tree here a random position
            t.x = hxd.Math.random(this.width);
            t.y = hxd.Math.random(this.height);
        }
        // and the player
        player = new Player( this );

        // camera properties
        // default camera for world (LAYER_WORLD)
        var camera_in_the_world = this.camera;
		camera_in_the_world.layerVisible = (L) -> (L != LAYER_HUD); // skip UI layer
        camera_in_the_world.setScale( 2, 2 ); // start with zoomed in camera
        camera_in_the_world.setAnchor( 0.5, 0.5 ); // followed object (player) is centered
        camera_in_the_world.follow = player.sprite; // follow object is player's sprite actually
        // an extra camera only for the user interface buttons (HUD)
        var camera_only_for_HUD = new h2d.Camera(this);
		camera_only_for_HUD.layerVisible = (L) -> (L == LAYER_HUD); // only show UI layer in this camera
        this.addCamera(camera_only_for_HUD);
        this.interactiveCamera = camera_only_for_HUD; // tells scene to use this camera for button interaction (h2d.Interactive)
        
        // add HUD-menu-buttons
        new InGameHUDMenu( this, LAYER_HUD );

        // info in game explains button control
        var t = new h2d.Text( GameApp.getMyFont() ); t.text = "Use W-A-S-D / arrow keys / mouse to move the player around.\nUse mouse wheel to zoom in/out";
        this.add( t, LAYER_HUD );
        // info about camera
        var t = new h2d.Text( GameApp.getMyFont() );
        this.add( t, LAYER_HUD );
        info_about_camera = t; // save object reference here (so we can update it in update function)

        // landmark in the world to represent the origin point
        var origin = new h2d.Bitmap( h2d.Tile.fromColor(0xFF0000,2,2) );
        var t = new h2d.Text( GameApp.getMyFont(), origin ); t.text = "Origin (0,0)";
        this.add( origin, LAYER_WORLD );

        GameApp.app.engine.backgroundColor = 0xFF267326; // this will color the background in "lawn" green
    }
    public function update() {
        for( ent in gameObjects ) // this is a very minimalisic way to call each entities update function each frame
            ent.update();

        this.ysort(LAYER_WORLD); // draw graphics in this layer so that sprites in the back are behind the ones in the front

        // camera: zoom in/out by mouse wheel
        if( hxd.Key.isPressed( hxd.Key.MOUSE_WHEEL_UP) ) { // zoom in
            this.camera.scale( 1.1, 1.1 ); // just add 10%
        }
        if( hxd.Key.isPressed( hxd.Key.MOUSE_WHEEL_DOWN) ) { // zoom out
            this.camera.scale( 1-(1/11), 1-(1/11) ); // cannot pick 0.9 as we want to remove the 1/11 from before (and which is not 10%) ... it's just math
        }

        // update info about camera
        var mp = new h2d.col.Point( this.mouseX, this.mouseY );
        var mp_inWorldCam = mp.clone(); /*transform point correctly*/ this.camera.sceneToCamera( mp_inWorldCam );
        info_about_camera.text = 'worldcam (${Math.floor(this.camera.x)} | ${Math.floor(this.camera.y)})\nmouse (${mp.toString()})\nmouse in world ${mp_inWorldCam.toString()}';
        info_about_camera.y = this.height - info_about_camera.getBounds().height; // text position
    }
}

/**
 * The HUD / UI / menu that can be seen inside actual game.
 * 
 * Only consists of a constructor that adds all elements.
 */
class InGameHUDMenu {
    
    public function new( scene:h2d.Scene, layer:Int ) {

        // hidable in-game menu

        var b = new h2d.Interactive( 300, 100 );
        scene.add( b, layer );
        b.setPosition( (scene.width/2)-150, (scene.height/2)-50 );
        b.backgroundColor = 0xFFFFFFFF;
        b.onOut = function(e){
            b.backgroundColor = 0xFFFFFFFF;
        };
        b.onOver = function(e){
            b.backgroundColor = 0xFFDDDDDD;
        };
        b.onClick = function(e){
            GameApp.app.setScene( new Scene_MainMenu() );
        };
        var t = new h2d.Text( GameApp.getMyFont(), b );
        t.text = "Return to main menu";
        t.textColor = 0x000000;
        var menu = b; // pass reference
        menu.visible = false; // hide

        // little HUD button in the corner to open menu

        var w : Int = 160;
        var h : Int = 40;
        var b = new h2d.Interactive( w, h );
        scene.add( b, layer );
        b.setPosition( scene.width-w, scene.height-h );
        var backgroundColorDefault = 0xFF004d1a;
        b.backgroundColor = backgroundColorDefault;
        b.onOut = function(e){
            b.backgroundColor = backgroundColorDefault;
        };
        b.onOver = function(e){
            b.backgroundColor = 0xFF009933;
        };
        b.onClick = function(e){
            menu.visible = !menu.visible;
        };
        var t = new h2d.Text( GameApp.getMyFont(), b );
        t.text = "Menu";
        t.textColor = 0xFFFFFF;
    }
}