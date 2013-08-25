import flash.display.Sprite;
import flash.display.Graphics;
import flash.Lib;

class HUDTimer extends Sprite
{

	public function new()
	{
		super();
		clock = new Clock();
		stop();

		width = Lib.current.stage.stageWidth;
		height = Lib.current.stage.stageHeight;
		update();
	}

	public function addTime(amount : Float)
	{
		clock.addTime(-amount);
	}

	public function stop()
	{
		clock.stop();
	}

	public function start()
	{
		clock.start();
	}

	public function update()
	{
		var time = clock.getTime();
		var width = Lib.current.stage.stageWidth;
		var height = Lib.current.stage.stageHeight;
		var remaining = (2*width + 2*height) * Math.max(0, 10.0 - time) / 10;

		var color = 0xFFFFFF;
		if(time > 8 && time <= 10)
		{
			var remainingLimit = (10 - time) / 2;
			color = (0xFF << 16) + (Math.floor(remainingLimit * 0xFF) << 8) + Math.floor(remainingLimit * 0xFF);
		}

		graphics.clear();
		if(remaining > 0)
		{
			graphics.lineStyle(30, color, true, flash.display.LineScaleMode.NORMAL, flash.display.CapsStyle.ROUND, flash.display.JointStyle.BEVEL);
			graphics.moveTo(width/2, 0);
			if(remaining >= width / 2)
			{
				graphics.lineTo(width, 0);
				remaining -= width/2;
				if(remaining >= height)
				{
					graphics.lineTo(width, height);
					remaining -= height;
					if(remaining >= width)
					{
						graphics.lineTo(0, height);
						remaining -= width;
						if(remaining >= height)
						{
							graphics.lineTo(0, 0);
							remaining -= height;
							if(remaining >= width/2)
							{
								graphics.lineTo(width/2, 0);
							}
							else
								graphics.lineTo(remaining, 0);
						}
						else
							graphics.lineTo(0, height-remaining);
					}
					else
						graphics.lineTo(width-remaining, height);
				}
				else
					graphics.lineTo(width, remaining);
			}
			else
				graphics.lineTo(width/2 + remaining, 0);
		}
		else if(onTimeout != null)
			onTimeout();
	}

	var clock : Clock;
	public var onTimeout : Void -> Void;
}