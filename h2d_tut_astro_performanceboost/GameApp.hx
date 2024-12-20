// note: init. resources by cond. comp. for rpg

import h2d.Bitmap;
import hxd.res.DefaultFont;

/**
 * A space ship game: "Astro shooter" (**Performance boosted version**)
 * 
 * ---
 * What changed in this version? **In short**: We only got rid of `findAll()` in our game's `update()` function and just maintain
 * our own arrays right from the start.
 * 
 * ---
 * In detail:
 * - We maintain a `rocks` and `lasers` array (instead of using `h2d.Object.findAll()` to generate arrays everytime)
 *   to regain performance. This involves *several*(!) of our update functions (which didn't change except for that):
 *     - `move_laser_shots()`
 *     - `collision_between_player_and_rocks()`
 *     - `collision_between_rocks_and_lasers()`
 *     - `move_all_rocks()`
 * - we use a static var `game_app_instance` so objects can add themselves to our lists `rocks` and `lasers` from outside
 *   (in their own `new()` constructor)
 * - we also use an override of `h2d.Object.onRemove()` to let each object remove itself from the lists `rocks` and `lasers`
 * ---
 * - Minor change: We delete any `rocks` and `lasers` that got too far away from the scene's center by `delete_objects_too_far_away()`
 * - Minor change: This sample also displays the game's FPS (`info_about_fps`)
 * - Minor change: Increased window size by `.hxml` file.
 */
class GameApp extends hxd.App {

    public var rocks  : Array<h2d.Object> = []; // the only core thing changed in this version
    public var lasers : Array<h2d.Object> = [];

    static public var game_app_instance : GameApp; // allows access on the object (an instance of) `GameApp`

    var info_about_fps : h2d.Text;

    // ---
    
    var intro_as_object : h2d.Object;

    //var rocks : Array<h2d.Object> = [];

    var player : Player;
    var player_health_bar : h2d.Graphics;

    var gameIsPaused : Bool = true;

    var score : Int = 0;
    var score_text : h2d.Text;

    static function main() {
        trace("inside my main function");
        trace("(You will need *trace* a lot to actively debug your game)");
        #if sys
        hxd.Res.initLocal(); // important! allows the app access to our game's resource files: images (sprites), audio, etc.
        #else
        hxd.Res.initEmbed(); // use hxd.Res.initEmbed(); for html5/js
        #end
        game_app_instance = new GameApp(); // now HeapsIO starts...
    }

    override function update(dt:Float) {
        if( !gameIsPaused ){
            player_movement_and_firing();
            move_laser_shots();
            collision_between_player_and_rocks();
            collision_between_rocks_and_lasers();
            move_all_rocks();
            update_health_bar_and_score();

            delete_objects_too_far_away();
        }
        game_can_be_paused();
    }

    override function init() {
        initializeAndShowIntroScene();
    }

    function initializeAndShowIntroScene() {
        var flow = new h2d.Flow( s2d ); // will arange/place things nicely...
        flow.fillWidth  = true; // use entire scene space available
        flow.fillHeight = true;
        flow.horizontalAlign = h2d.Flow.FlowAlign.Middle;
        flow.verticalAlign   = h2d.Flow.FlowAlign.Middle;
        flow.layout          = h2d.Flow.FlowLayout.Vertical;
        var myfont = DefaultFont.get();
        //var text_object = new h2d.Text( myfont, flow ); text_object.text = "Made with";
        new h2d.Bitmap( hxd.Res.heaps.toTile(), flow );
        haxe.Timer.delay(
            () -> { start_game(); },
            Math.floor(1.5) * 1000 // 1500 ms = 1.5 seconds
        );

        intro_as_object = flow; // save reference, so we can control/dispose it that way
    }

    function start_game() {
        intro_as_object.visible = false; // we could also `.remove()` it
        gameIsPaused = false;

        // how-to / info
        var t = new h2d.Text( DefaultFont.get(), s2d ); t.text = "Use W-A-S-D / arrow keys / mouse to move the player around.\nUse SPACE / right mouse click to shoot\n\nPress P / ENTER to pause game";

        // info about fps
        var t = new h2d.Text( DefaultFont.get(), s2d ); t.setPosition( s2d.width-128, s2d.height-48 );
        info_about_fps = t;

        // create the player
        player = new Player( s2d );

        // and player's health bar
        player_health_bar = new h2d.Graphics( s2d );
        player_health_bar.setPosition( 4, s2d.height-36 );
        var t = new h2d.Text( DefaultFont.get(), player_health_bar ); t.text = "Life"; t.x = 4;

        // score text
        var t = new h2d.Text( DefaultFont.get(), s2d ); t.setPosition( s2d.width - 250, 64 );
        t.textColor = 0xFFFFFF;
        score_text = t; // pass reference for later

        // add random rockets every x seconds
        var timer = new haxe.Timer( 2 * 1000 ); // 2000ms = 2 seconds
        timer.run = () -> {
            // this is a dynamic function
            if( !gameIsPaused ){
                var number_of_rocks : Int = 1 + Math.floor( hxd.Math.random( Math.floor(score/5) ) ); // with score comes difficulty >:)
                for( i in 0...number_of_rocks ){
                    var rock = new Rock( s2d );
                    var random_distance = 600 + hxd.Math.random( 300 );
                    var random_angle = hxd.Math.PI * hxd.Math.random( 2 ); // two PI make one full circle in radians
                    rock.rotate( random_angle );
                    rock.setPosition(
                        player.x + (hxd.Math.cos( random_angle ) * random_distance),
                        player.y + (hxd.Math.sin( random_angle ) * random_distance)
                    );
                }
                trace('Throwing ${number_of_rocks} new rocks towards player!');
            }
        };
    }

    function player_movement_and_firing() {
        player.movement();
        player.check_if_shooting();
    }

    function move_all_rocks() {
        //var rocks = s2d.findAll( o -> { (o.name=="rock")? o : null; } ); // var rocks : Array<Rock> =
        for( o in rocks ){
            //var r = cast( o, Rock ); // safe cast
            var r = cast o;// unsafe cast
            r.move( -r.speed, -r.speed );
        }
    }

    function collision_between_player_and_rocks() {
        //var rocks = s2d.findAll( o -> { (o.name=="rock")? o : null; } );
        for( r in rocks ){
            if( r.getBounds().intersects( player.getBounds() ) ){
                // boooom !
                r.remove();
                if( player.lifepoints > 1 )
                    player.lifepoints -= 1;
                else {
                    // show "game over" message
                    var t = new h2d.Text( DefaultFont.get(), s2d ); t.text = "GAME OVER"; t.setPosition( s2d.width/2, s2d.height/2 );
                    t.textAlign = h2d.Text.Align.Center;
                    t.scale(2);
                    // remove message after 4 seconds...
                    haxe.Timer.delay(
                        ()->{
                                t.remove();
                                player.lifepoints = player.lifepoints_max; // ...and reset life points
                                score = 0; // ...and score :|
                            },
                        4 * 1000
                    );
                }
            }
        }
    }

    function collision_between_rocks_and_lasers() {
        //var rocks  = s2d.findAll( o -> { (o.name=="rock" )? o : null; } );
        //var lasers = s2d.findAll( o -> { (o.name=="laser")? o : null; } );
        var to_remove : Array<h2d.Object> = [];
        for( l in lasers ){
            var laser_bounds = l.getBounds();
            for( r in rocks ){
                if( r.getBounds().intersects( laser_bounds ) ){
                    to_remove.push(r); // both get removed, but outside this for loop
                    to_remove.push(l);
                    break; // break here because the laser has been destroyed
                }
            }
        }
        for( o in to_remove ){
            o.remove();
            score++; // score goes up by +1
            // score text "pops" up for 2 seconds
            score_text.scale(1.2); // setScale(2);
            score_text.rotation = (hxd.Math.degToRad(-20+hxd.Math.random(40))); // random rotation by [-30,30]°
            //var t = new haxe.Timer( 50 ); // wiggle
            //t.run = () -> { score_text.rotate(-0.02+hxd.Math.random(0.04)); };
            haxe.Timer.delay( ()->{score_text.setScale(1);score_text.rotation=0;/*t.stop();*/}, 2*1000 ); // reset to normal after delay
        }
    }

    function update_health_bar_and_score() {
        // health bar
        player_health_bar.clear(); // clear what this object has drawn before
        player_health_bar.lineStyle( 1, 0xFFFFFF );
        player_health_bar.beginFill( 0x0 ); // black = 0x000000 = 0x0
        player_health_bar.drawRect( 0, 0, 200, 32 ); // will draw relative from its own position
        player_health_bar.beginFill( 0xFF0000 ); // red
        var health_in_percent = player.lifepoints / player.lifepoints_max;
        player_health_bar.drawRect( 0, 0, 200 * health_in_percent, 32 );
        player_health_bar.endFill();

        // score
        if(score_text.scaleX==1)
            score_text.text = 'Score: ${score}';
        else
            score_text.text = 'Score: ${score} !!!';

        // also update fps info
        info_about_fps.text = 'Object count: ${s2d.numChildren}\nFPS: ${Math.floor( hxd.Timer.fps() )}';
    }

    function move_laser_shots() {
        //var lasers = s2d.findAll( o -> { (o.name=="laser")? o : null; } );
        for( l in lasers ){
            l.move( 16, 16 );
        }
    }

    function game_can_be_paused() {
        if( hxd.Key.isPressed( hxd.Key.ENTER ) || hxd.Key.isPressed( hxd.Key.P ) )
            this.gameIsPaused = !this.gameIsPaused; // switch on/off
    }

    function delete_objects_too_far_away() {
        var objects_to_delete = rocks.concat( lasers ); // an Array of both Arrays rocks and lasers
        for( o in objects_to_delete ){
            if( hxd.Math.distance( o.x - (s2d.width/2), o.y - (s2d.height/2) ) > 2000 ){
                o.remove();
            }
        }
    }
}

//
// our "game objects" AKA "entities"
//

class Player extends h2d.Bitmap {
    public var lifepoints     : Int = 5;
    public var lifepoints_max : Int = 5;
    public function new( s2d:h2d.Scene ) {
        var tile_for_gpu = hxd.Res.spaceship.toTile().center();
        super( tile_for_gpu, s2d );

        this.setPosition( s2d.width/2, s2d.height/2 );
    }
    public function movement() {
        var s2d = this.getScene(); // we can know the scene this object is added to :O
        // different ways to move the player around
        var speed = 3;
        if(hxd.Key.isDown(hxd.Key.W)||hxd.Key.isDown(hxd.Key.UP   )) {this.move(speed,speed);}
        if(hxd.Key.isDown(hxd.Key.A)||hxd.Key.isDown(hxd.Key.LEFT )) {this.rotate(hxd.Math.degToRad(-3));} // turn by 3°
        if(hxd.Key.isDown(hxd.Key.D)||hxd.Key.isDown(hxd.Key.RIGHT)) {this.rotate(hxd.Math.degToRad( 3));}
        if(hxd.Key.isDown(hxd.Key.S)||hxd.Key.isDown(hxd.Key.DOWN )) {this.move(-speed,-speed);}
        if(hxd.Key.isDown(hxd.Key.MOUSE_LEFT)){
            var mx = s2d.mouseX;
            var my = s2d.mouseY;
            if( hxd.Math.distance( this.x - mx, this.y - my ) > 8 ){ // to avoid "vibrating" check if mouse is not too close
                var direction_in_radians = hxd.Math.atan2( my - this.y, mx - this.x );
                this.x += speed * hxd.Math.cos( direction_in_radians );
                this.y += speed * hxd.Math.sin( direction_in_radians );
                this.rotation = direction_in_radians;
            }
        }
    }
    public function check_if_shooting() {
        if(hxd.Key.isPressed(hxd.Key.SPACE)||hxd.Key.isPressed(hxd.Key.MOUSE_RIGHT)) {
            var laser = new Laser( this.getScene() );
            laser.rotation = this.rotation;
            laser.name = "laser";
            laser.setPosition( this.x, this.y );
        }
    }
}

class Laser extends h2d.Graphics {
    public function new( s2d:h2d.Scene ) {
        super( s2d );
        this.lineStyle( 1, 0xFFFFFF );
        this.beginFill( 0x00FF00 );
        this.drawRect( 0, 0, 20, 5 );
        //this.drawRoundedRect( 0, 0, 20, 5, 20 );
        this.endFill();

        GameApp.game_app_instance.lasers.push( this );
    }
    override function onRemove() {
        super.onRemove();
        GameApp.game_app_instance.lasers.remove(this);
    }
}

class Rock extends h2d.Bitmap {
    public var speed : Float;
    public function new( s2d:h2d.Scene ) {
        var tile = h2d.Tile.fromColor( 0x505050, 30, 30 ).center();
        super( tile, s2d );
        this.name = "rock"; // so we can find it later more easy
        this.speed = 0.4 + hxd.Math.random( 3.6 );
        // "sub" rocks
        for( i in 0...4 ){
            var subrock = new h2d.Bitmap( h2d.Tile.fromColor( 0x606060, 15, 15 ).center(), this );
            subrock.setPosition( -15+hxd.Math.random(30), -15+hxd.Math.random(30) ); // will be relative to parent ;)
        }

        GameApp.game_app_instance.rocks.push( this );
    }
    override function onRemove() {
        super.onRemove();
        GameApp.game_app_instance.rocks.remove(this);
    }
}