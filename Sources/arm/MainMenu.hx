package arm;
import iron.Scene;
import iron.App;
import armory.trait.internal.CanvasScript;
import armory.system.Event;
import iron.object.Object;

class MainMenu extends iron.Trait {
	var canvas:CanvasScript;
	var winW:Int = 0;
	var winH:Int = 0;

	public function new() {
		super();

		notifyOnInit(function() {
			canvas = Scene.active.getTrait(CanvasScript);
			canvas.getElement('contMainMenu').visible = true;

			//Load Music1 channel (And play for main menu)
			if (InitGame.inst.music1 == null) {
				var musicInt = Std.random(4)+1;
				InitGame.inst.currentTrack = musicInt;
				InitGame.inst.music1.stop()
				iron.data.Data.getSound('Music/Track'+(musicInt)+".wav", function(sound:kha.Sound) {
					//sound.sampleRate = 40200; // File is 44100, game is 48000, drop to 40200 to account for speed up.
					InitGame.inst.music1 = iron.system.Audio.play(sound, false, true);
					InitGame.inst.music1.volume = 1.0; //Add settings multiplier here is relevant
				});
			}

			//Events
			Event.add("playgame", startGame);
			Event.add("difficulty", difficulty);

			difficulty();
		});

		notifyOnUpdate(function() {
			//If rescale - reposition
			if (App.w() != winW || App.h() != winH) {
				trace('Window dimensions changed to (' + App.w() + 'x' + App.h() + ')');
				winW = App.w();
				winH = App.h();
				var MM = canvas.getElement('contMainMenu');
				MM.x = winW/2;
				canvas.getElement('mmTitle').y = winH/10;
				canvas.getElement('butPlay').y = winH/2;
				canvas.getElement('butPlayOutline').y = winH/2 - 7;
				canvas.getElement('diffRadio').y = winH/2 + 81;
				canvas.getElement('diffOutline').y = winH/2 + 80 - 6;
				canvas.getElement('diffText1').y = winH/2 + 130;
				canvas.getElement('diffText2').y = winH/2 + 160;
				canvas.getElement('diffText3').y = winH/2 + 190;
				canvas.getElement('diffText4').y = winH/2 + 220;
			}
		});

		notifyOnRemove(function() {
			canvas.getElement('contMainMenu').visible = false;
			InitGame.inst.difficulty = canvas.getElement('diffRadio').text;
			InitGame.inst.mapRadius = Std.parseInt(canvas.getElement('diffText2').text.substr(11));
			iron.Scene.active.spawnObject('contGenerateGame', null, function(o:Object) {});
		});
	}

	function startGame() {
		trace("Start the game!");
		canvas.getElement('contMainMenu').visible = false;
		object.remove();
	}

	function difficulty() {
		if (canvas.getElement('diffRadio').text == "STANDARD") {
			canvas.getElement('diffRadio').text = "HARD";
			canvas.getElement('diffText1').text = "Mass multiplier x0.75";
			canvas.getElement('diffText2').text = "Map Radius: 6";
			canvas.getElement('diffText3').text = "Mass exchange rate 0.03%";
			InitGame.inst.massExchangeRate = 0.03;
		}
		else if (canvas.getElement('diffRadio').text == "EASY") {
			canvas.getElement('diffRadio').text = "STANDARD";
			canvas.getElement('diffText1').text = "Mass multiplier x1.0";
			canvas.getElement('diffText2').text = "Map Radius: 8";
			canvas.getElement('diffText3').text = "Mass exchange rate 0.06%";
			InitGame.inst.massExchangeRate = 0.06;
		}
		else {
			canvas.getElement('diffRadio').text = "EASY";
			canvas.getElement('diffText1').text = "Mass multiplier x1.5";
			canvas.getElement('diffText2').text = "Map Radius: 10";
			canvas.getElement('diffText3').text = "Mass exchange rate 0.08%";
			InitGame.inst.massExchangeRate = 0.08;
		}
	}
}
