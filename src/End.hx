import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import motion.Actuate;
import flash.Lib;
import openfl.Assets;
import flash.events.KeyboardEvent;

class End extends Sprite
{
	public function new(hell : Bool)
	{
		super();

	}

	public function keyPressed(event : KeyboardEvent)
	{
		Actuate.tween(this, 1, {alpha : 0}).onComplete(function()
			{
				if(onExit != null)
					onExit();
			});
	}

	public var onExit : Void -> Void;	
}