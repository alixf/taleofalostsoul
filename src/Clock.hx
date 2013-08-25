class Clock
{
    private var lastTime : Float;
	private var factor : Float;
	private var elapsedTime : Float;
	private var run : Bool;
 
	public function new(factor : Float = 1.0)
	{
		this.factor = factor;
		run = true;
		reset();
	}
 
	public function start()
	{
		run = true;
		#if flash
			lastTime = flash.Lib.getTimer();
		#else
			lastTime = Sys.time();
		#end
	}
 
	public function stop()
	{
		run = false;
		reset();
	}
 
	public function reset()
	{
		#if flash
			lastTime = flash.Lib.getTimer();
		#else
			lastTime = Sys.time();
		#end
		elapsedTime = 0;
	}
 
	public function pause()
	{
		run = false;
	}

	public function addTime(amount : Float)
	{
		elapsedTime += amount;
	}
 
	public function getFactor()
	{
		return factor;
	}
 
	public function setFactor(factor : Float)
	{
		getTime();
		this.factor = factor;
	}
 
	public function getTime()
	{
		#if flash
			var time = flash.Lib.getTimer();
		#else
			var time = Sys.time();
		#end

		if(run)
			elapsedTime += (time - lastTime) * factor;
		lastTime = time;

		#if flash
			return elapsedTime/1000;
		#else
			return elapsedTime;
		#end
	}
}