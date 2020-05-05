package arm;
import iron.object.Object;
import iron.system.Time;

class GenerateGame extends iron.Trait {
	var speed:Float = 0.1;
	var totalTicks:Int = 100;
	var totalTime:Float = 3.0;
	var currentTick:Int = 0;
	var currentTime:Float = 0.0;
	var tickInterval:Float = 0.0;

	public function new() {
		super();

		notifyOnInit(function() {
			tickInterval = (totalTime/totalTicks) * speed;
			trace("Generating Game. Tick interval: " + tickInterval);
			
		});

		notifyOnUpdate(function() {
			while ((currentTick <= totalTicks) && (currentTime > (currentTick*tickInterval))) {
				trace(currentTick);
				currentTick += 1;
			}
			currentTime += Time.delta;
			if (currentTick > totalTicks) {object.remove();}
		});

		notifyOnRemove(function() {
			iron.Scene.active.spawnObject('contGame', null, function(o:Object) {});
		});
	}
}
