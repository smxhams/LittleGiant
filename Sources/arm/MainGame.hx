package arm;

class MainGame extends iron.Trait {
	public function new() {
		super();

		notifyOnInit(function() {
			trace('Welcome to the main game');
		});

		// notifyOnUpdate(function() {
		// });

		// notifyOnRemove(function() {
		// });
	}
}
