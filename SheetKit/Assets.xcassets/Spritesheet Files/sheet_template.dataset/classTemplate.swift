import SpriteKit


public class $NAME$: SHKSpritesheet {

	private var image: SHKImage!

	public init() {
		super.init(count: $COUNT$)
		self.image = SHKImage(named: "$SPRITESHEET_NAME$")
	}

	// MARK: Animations
	$ANIMATIONS$

	// MARK: Textures
	$TEXTURES$
}
