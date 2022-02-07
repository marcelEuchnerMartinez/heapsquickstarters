package scenes;

/**
 * The game's main menu, where the user can start a new game.
 */
 class Scene_MainMenu extends h2d.Scene {
    public function new() {
        super();
        // flow design will auto arange/place things nicely...
        var flow = new h2d.Flow( this );
        flow.fillWidth  = true; // use entire scene space available
        flow.fillHeight = true;
        flow.horizontalAlign = h2d.Flow.FlowAlign.Middle;
        flow.verticalAlign   = h2d.Flow.FlowAlign.Middle;
        flow.layout = h2d.Flow.FlowLayout.Vertical; // ...with vertical layout
        flow.verticalSpacing = 4;

        var button_play  = new h2d.Interactive( 500, 50, flow );
        var button_quit_backgroundbitmap = new h2d.Bitmap( hxd.Res.stone_surface.toTile(), flow );

        button_play.backgroundColor = 0xFF00FF00;

        button_quit_backgroundbitmap.width = 200;
        button_quit_backgroundbitmap.height = 20;
        var button_quit = new h2d.Interactive( 200, 20, button_quit_backgroundbitmap );
        // define button actions
        button_play.onClick = (e) -> {
            var new_game_scene = new Scene_Game();
            GameApp.app.setScene( new_game_scene );
            GameApp.app.world = new_game_scene;
            new_game_scene.init(); // this function is separated to make sure gameObjects (from Scene_Game) has been initialized. This is why it's not just in new() of Scene_Game
        };
        button_quit.onClick = (e) -> {
            hxd.System.exit(); // halts the app
        };
        // add button colors
        //button_play.emitTile( this.ctx, hxd.Res.stone_surface.toTile() );
        //button_quit.emitTile( this.ctx, hxd.Res.stone_surface.toTile() );
        // add button labels
        var myfont = GameApp.getMyFont();
        var label = new h2d.Text( myfont, button_play ); label.text = "NEW GAME";
        //var label = new h2d.Text( myfont, button_play ); label.text = "CONTINUE";
        var label = new h2d.Text( myfont, button_quit ); label.text = "QUIT";
    }
}