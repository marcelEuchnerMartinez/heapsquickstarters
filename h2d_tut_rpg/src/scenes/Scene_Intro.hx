package scenes;

/**
 * A scene just to display who made this game.
 */
 class Scene_Intro extends h2d.Scene {
    public function new() {
        super();
        var flow = new h2d.Flow( this ); // will arange/place things nicely...
        flow.fillWidth  = true; // use entire scene space available
        flow.fillHeight = true;
        flow.horizontalAlign = h2d.Flow.FlowAlign.Middle;
        flow.verticalAlign   = h2d.Flow.FlowAlign.Middle;
        flow.layout          = h2d.Flow.FlowLayout.Vertical;
        var myfont = GameApp.getMyFont();
        //var text_object = new h2d.Text( myfont, flow ); text_object.text = "Made with";
        new h2d.Bitmap( hxd.Res.heaps.toTile(), flow );
        haxe.Timer.delay(
            () -> {GameApp.app.setScene( new Scene_MainMenu() ); },
            Math.floor(1.5) * 1000 // 1500 ms = 1.5 seconds
        );
    }
}