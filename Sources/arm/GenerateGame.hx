package arm;
import iron.object.Object;
import iron.system.Time;

class GenerateGame extends iron.Trait {
	@prop 
	var speed:Float;
	var totalTicks:Int = 100;
	@prop
	var totalTime:Float;
	var currentTick:Int = 0;
	var currentTime:Float = 0.0;
	var tickInterval:Float = 0.0;

	public function new() {
		super();

		notifyOnInit(function() {
			tickInterval = (totalTime/totalTicks) * speed;
			trace("Generating Game. Tick interval: " + tickInterval);

			//Generate grid - radius 4
			var radius = 10; //Final radius is this minus 1
			var data = InitGame.inst.hexTilesData;
			var index = 0;
			var distance = 0;
			var temp:Array<{i:Int, x:Int, y:Int, z:Int, t:Int, v:Int, p:Int}> = [];
			// 	{i:0, x:0, y:0, z:0, t:'Home', v:1000, p:1000}
			// ];
			// data.unshift(temp);
			for (q in -radius...radius+1) { //Iterates through all possible hexagon positions
				for (r in -radius...radius+1) {
					for (s in -radius...radius+1) {
						if (q+r+s == 0) { //Filters to only applicable hexagons
							if (q==0&&r==0&&s==0) {
								InitGame.inst.homeIndex = index;
								temp = [{i:index, x:q, y:r, z:s, t:-1, v:1000, p:1000}];
								data.push(temp);
							}
							else {
								distance = Std.int((Math.abs(q)+Math.abs(r)+Math.abs(s)) / 2);
								temp = [{i:index, x:q, y:r, z:s, t:Std.random(20), v:Std.int((distance*750*(Math.random()+0.5))), p:0}];
								data.push(temp);
							}
							index += 1;
						}
					}
				}
			}
			trace(data[0][0].v);
			
			
		});

		notifyOnUpdate(function() {
			while ((currentTick <= totalTicks) && (currentTime > (currentTick*tickInterval))) {
				//trace(currentTick);
				currentTick += 1;
			}
			currentTime += Time.delta;
			//trace(currentTime);
			if (currentTick > totalTicks) {object.remove();}
		});

		notifyOnRemove(function() {
			iron.Scene.active.spawnObject('contGame', null, function(o:Object) {});
		});
	}
}
