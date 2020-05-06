package arm;
import iron.Scene;
import iron.system.Input;

class MainGame extends iron.Trait {
	var keyboard:Keyboard;
	var mouse:Mouse;

	//Cam
	var camSpeed:Float = 0.5;
	var camX:Float;
	var camY:Float;
	
	public function new() {
		super();

		notifyOnInit(function() {
			trace('Welcome to the main game');
			keyboard = Input.getKeyboard();
			mouse = Input.getMouse();

			var camera = Scene.active.getChild("Camera");
			camX = camera.transform.loc.x+0.245;
			camY = camera.transform.loc.y+0.245;
		});

		notifyOnUpdate(function() {
			camControl();
			

		});

		// notifyOnRemove(function() {
		// });
	}

	function camControl() {
		var camera = Scene.active.getChild("Camera");
		//Cam control
		//Arrow keys move
		if (keyboard.down("right")) {
			camX += camSpeed;
		}
		if (keyboard.down("left")) {
			camX -= camSpeed;
		}
		if (keyboard.down("up")) {
			camY += camSpeed;
		}
		if (keyboard.down("down")) {
			camY -= camSpeed;
		}

		//Scroll wheel zoom
		if (InitGame.inst.camDistance < 80.0) {
			if (mouse.wheelDelta == 1) {
				InitGame.inst.camDistance += 4;
				camY -= 3;
			}
		}
		if (InitGame.inst.camDistance > 4.0) {
			if (mouse.wheelDelta == -1) {
				InitGame.inst.camDistance -= 4;
				camY += 3;
			}
		}

		var curCamX = camera.transform.loc.x;
		var curCamY = camera.transform.loc.y;
		if (roundValue(InitGame.inst.camDistance, 2) != roundValue(camera.transform.loc.z, 2)) {
			camera.transform.loc.z += -(camera.transform.loc.z-InitGame.inst.camDistance)/10;
		}
		if (roundValue(curCamX, 2) != roundValue(camX, 2)) {
			camera.transform.loc.x += -(camera.transform.loc.x-camX)/10;
		}
		if (roundValue(curCamY, 2) != roundValue(camY, 2)) {
			camera.transform.loc.y += -(camera.transform.loc.y-camY)/10;
		}
		//trace(curCamX + ' : ' + curCamY + ' To go to: ' + camX + ' : ' + camY);
	}
	function roundValue(n:Float, prec:Int) {
		n = Math.round(n * Math.pow(10, prec));
		return n;
	}
}
