import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import openfl.Assets;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import motion.Actuate;

class Soul extends Sprite
{
	public function new()
	{
		super();
		bitmap = new Bitmap(Assets.getBitmapData("assets/soul.png"));
		bitmap.x = -bitmap.width/2;
		bitmap.y = -65;

		var shadow = new Bitmap(Assets.getBitmapData("assets/shadow.png"));
		shadow.x = -shadow.width/2;
		shadow.y = -60;

		soulShield = new Bitmap(Assets.getBitmapData("assets/soulShield.png"));
		soulShield.x = -soulShield.width/2;
		soulShield.y = -60;
		soulShield.alpha = 0;

		target = {x : 0, y : 0};
		canMove = false;
		clock = new Clock();
		speed = 175;
		direction = 0;
		shield = false;
		baseSpeed = speed;
		shieldStack = 0;
		speedStack = 0;

		addChild(bitmap);
		addChild(shadow);
		addChild(soulShield);

		Actuate.apply(this, {alpha : 0.75});
		Actuate.tween(this, 0.75, {alpha : 0.5}).ease(motion.easing.Linear.easeNone).repeat().reflect();
		Actuate.tween(bitmap, 1, {y : bitmap.y + 6}).ease(motion.easing.Linear.easeNone).repeat().reflect();
	}

	public function setTarget(x : Int, y : Int)
	{
		target = {x : x, y : y};
	}

	public function setPosition(x : Int, y : Int)
	{
		this.x = x;
		this.y = y;
		
		if(onMove != null)
			onMove(x, y);
	}

	public function update()
	{
		var time = clock.getTime();
		clock.reset();

		if(canMove)
		{
			direction = Math.atan2(target.y-y, target.x-x);
			var distance = Point.distance(new Point(x, y), new Point(target.x, target.y));

			if(distance <= speed * time)
				setPosition(target.x, target.y);
			else
				setPosition(cast (x + Math.cos(direction) * speed * time), cast (y + Math.sin(direction) * speed * time));
		}
	}

	public function enableMove(event : MouseEvent)
	{
		canMove = true;
	}

	public function disableMove(event : MouseEvent)
	{
		canMove = false;
	}

	public function giveShield(duration : Float)
	{
		shield = true;
		shieldStack += 1;
		soulShield.alpha = 1;

		function tmp(soul : Soul)
		{
			shieldStack--;
			if(shieldStack <= 0)
			{
				soul.shield = false;
				soulShield.alpha = 0;
			}
		}

		Actuate.timer(duration).onComplete(tmp.bind(this));
	}

	public function boostSpeed(factor : Float, duration : Float)
	{
		speed = baseSpeed * factor;
		speedStack += 1;
		function tmp(soul : Soul)
		{
			speedStack--;
			if(speedStack <= 0)
				soul.speed = soul.baseSpeed;
		}

		Actuate.timer(duration).onComplete(tmp.bind(this));
	}

	public var bitmap : Bitmap;
	public var soulShield : Bitmap;
	public var canMove : Bool;
	public var onMove : Int -> Int -> Void;
	public var target : Dynamic;
	private var clock : Clock;
	public var speed : Float;
	public var baseSpeed : Float;
	public var shield : Bool;
	public var direction : Float;
	public var shieldStack : Int;
	public var speedStack : Int;
}