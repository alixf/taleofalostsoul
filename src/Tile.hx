import flash.display.Sprite;
import flash.display.Bitmap;
import openfl.Assets;
import motion.Actuate;
import motion.easing.Linear;

class Tile extends Sprite
{
	public function new()
	{
		super();
		type = VOID;
	}
	
	public var type : TileType;

	public static function fromType(type : TileType) : Tile
	{
		var tile = new Tile();
		tile.type = type;

		// Define tileBitmap
		var tileBitmap = switch(type)
		{
			case GROUND, SPEED, TIME, SHIELD 							: new Bitmap(Assets.getBitmapData("assets/tiles/graveyard"+(Std.random(3) + 1)+".png"));
			case HEAVENGROUND, HEAVENSPEED, HEAVENTIME, HEAVENSHIELD 	: new Bitmap(Assets.getBitmapData("assets/tiles/heaven"+(Std.random(1) + 1)+".png"));
			case HELLGROUND, HELLSPEED, HELLTIME, HELLSHIELD 			: new Bitmap(Assets.getBitmapData("assets/tiles/hell"+(Std.random(1) + 1)+".png"));
			case START 													: new Bitmap(Assets.getBitmapData("assets/tiles/graveyardstart.png"));
			case EXIT 													: new Bitmap(Assets.getBitmapData("assets/tiles/graveyardexit.png"));
			case HEAVENSTART 											: new Bitmap(Assets.getBitmapData("assets/tiles/heavenstart.png"));
			case HEAVENEXIT 											: new Bitmap(Assets.getBitmapData("assets/tiles/heavenexit.png"));
			case HELLSTART 												: new Bitmap(Assets.getBitmapData("assets/tiles/hellstart.png"));
			case HELLEXIT 												: new Bitmap(Assets.getBitmapData("assets/tiles/hellexit.png"));
			default : null;
		}
		// Define powerup
		var powerUp = switch(type)
		{
			case SHIELD, HEAVENSHIELD, HELLSHIELD : new Bitmap(Assets.getBitmapData("assets/puShield.png"));
			case TIME, HEAVENTIME, HELLTIME : new Bitmap(Assets.getBitmapData("assets/puTime.png"));
			case SPEED, HEAVENSPEED, HELLSPEED : new Bitmap(Assets.getBitmapData("assets/puSpeed.png"));
			default : null;
		}

		if(tileBitmap != null)
		{
			tileBitmap.x = -tileBitmap.width/2;
			tileBitmap.y = -tileBitmap.height/2;
			tile.addChild(tileBitmap);
			tileBitmap.y -= 25;
			tileBitmap.alpha = 0;
			Actuate.tween(tileBitmap, 0.5 + Math.random()*0.5, {alpha : 1, y : tileBitmap.y + 25}).delay(Math.random()*0.33);
		}

		if(powerUp != null)
		{
			powerUp.x = -powerUp.width/2;
			powerUp.y = -60;
			var shadow = new Bitmap(Assets.getBitmapData("assets/shadow.png"));
			shadow.x = -shadow.width/2;
			shadow.y = -60;
			
			Actuate.tween(powerUp, 1, {y : powerUp.y - 10}).ease(Linear.easeNone).repeat().reflect();
			tile.addChild(shadow);
			tile.addChild(powerUp);
		}


		return tile;
	}
}