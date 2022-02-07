package entities;

import Entity;

class Player extends Entity {

    override function update() {
        super.update(); // don't forget this
        // movement
        var speed = 3;
        if(hxd.Key.isDown(hxd.Key.W)||hxd.Key.isDown(hxd.Key.UP   )) {this.y -= speed;}
        if(hxd.Key.isDown(hxd.Key.A)||hxd.Key.isDown(hxd.Key.LEFT )) {this.x -= speed;}
        if(hxd.Key.isDown(hxd.Key.D)||hxd.Key.isDown(hxd.Key.RIGHT)) {this.x += speed;}
        if(hxd.Key.isDown(hxd.Key.S)||hxd.Key.isDown(hxd.Key.DOWN )) {this.y += speed;}
        if(hxd.Key.isDown(hxd.Key.MOUSE_LEFT)){
            // ok, I know this is a bit terrible...
            // we transform the windows's mouse position so the position in the world
            var mp = new h2d.col.Point( scene.mouseX, scene.mouseY );
            var mp_inWorldCam = mp.clone(); /*transform point correctly*/ scene.camera.sceneToCamera( mp_inWorldCam );
            var mx = mp.x;
            var my = mp.y;
            //
            if( hxd.Math.distance(x-mx,y-my)>8 ){ // to avoid "vibrating" check if mouse is not too close
                var direction_in_radians = hxd.Math.atan2( my - this.y, mx - this.x );
                this.x += speed * hxd.Math.cos( direction_in_radians );
                this.y += speed * hxd.Math.sin( direction_in_radians );
            }
        }
    }

    public function new(_){ // underscore just passes all parameters from extended Entity class
        super(_);
        // place in the center of the scene/"level"
        x = scene.width/2;
        y = scene.height/2;
        // give player a sprite (visuals)
        var tile = hxd.Res.hero.toTile();
        // tile/sprite pivot at the bottom
        tile.dx -= tile.width/2;
        tile.dy -= tile.height;

        this.sprite = new h2d.Bitmap(tile, scene);
        var infotext_about_entity = new h2d.Text( hxd.res.DefaultFont.get(), sprite ); infotext_about_entity.text = "Player";
    }
}

/*
if(hxd.Key.isDown(hxd.Key.MOUSE_LEFT)){
            if( hxd.Math.distance(x-scene.mouseX,y-scene.mouseY)>8 ){ // to avoid "vibrating" check if mouse is not too close
                var direction_in_radians = hxd.Math.atan2( this.scene.mouseY - this.y, this.scene.mouseX - this.x );
                this.x += speed * hxd.Math.cos( direction_in_radians );
                this.y += speed * hxd.Math.sin( direction_in_radians );
            }
        }

 */
