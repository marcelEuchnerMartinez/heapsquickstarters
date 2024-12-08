package entities;

class Tree extends Entity {
    public function new(_){
        super(_);
        var tile = hxd.Res.tree.toTile();
        tile.dx -= tile.width/2;
        tile.dy -= tile.height;

        this.sprite = new h2d.Bitmap(tile);
        scene.add( sprite, layer );
    }
}