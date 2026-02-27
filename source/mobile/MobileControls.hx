package mobile;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;

class MobileControls extends FlxSpriteGroup
{
	public var hitbox:Hitbox;
	public var virtualPad:TouchPad;
	
	private var _mode:Int = 0; // 0 = Hitbox, 1 = VirtualPad
	
	/**
	 * Cria o sistema de controles mobile
	 */
	public function new()
	{
		super();
		
		// Inicializar dados se necessário
		MobileData.init();
		
		// Carregar modo salvo
		_mode = MobileData.mode;
		
		// Criar o controle apropriado
		setupControls();
	}
	
	/**
	 * Configura os controles baseado no modo selecionado
	 */
	private function setupControls():Void
	{
		// Limpar controles existentes
		if (hitbox != null)
		{
			remove(hitbox);
			hitbox.destroy();
			hitbox = null;
		}
		
		if (virtualPad != null)
		{
			remove(virtualPad);
			virtualPad.destroy();
			virtualPad = null;
		}
		
		// Criar o controle apropriado
		switch(_mode)
		{
			case 0: // Hitbox
				hitbox = new Hitbox(MobileData.hitboxLocation);
				add(hitbox);
				
			case 1: // VirtualPad
				virtualPad = new TouchPad();
				add(virtualPad);
		}
	}
	
	/**
	 * Muda o modo de controle
	 */
	public function changeMode(newMode:Int):Void
	{
		if (newMode == _mode)
			return;
			
		_mode = newMode;
		MobileData.mode = newMode;
		MobileData.save();
		
		setupControls();
	}
	
	/**
	 * Verifica se um botão está sendo pressionado
	 * @param id 0=LEFT, 1=DOWN, 2=UP, 3=RIGHT
	 */
	public function buttonPressed(id:Int):Bool
	{
		if (hitbox != null)
			return hitbox.buttonPressed(id);
		else if (virtualPad != null)
			return virtualPad.buttonPressed(id);
			
		return false;
	}
	
	/**
	 * Verifica se um botão foi acabado de pressionar
	 */
	public function buttonJustPressed(id:Int):Bool
	{
		if (hitbox != null)
			return hitbox.buttonJustPressed(id);
		else if (virtualPad != null)
			return virtualPad.buttonJustPressed(id);
			
		return false;
	}
	
	/**
	 * Verifica se um botão foi acabado de soltar
	 */
	public function buttonJustReleased(id:Int):Bool
	{
		if (hitbox != null)
			return hitbox.buttonJustReleased(id);
		else if (virtualPad != null)
			return virtualPad.buttonJustReleased(id);
			
		return false;
	}
	
	/**
	 * Retorna se QUALQUER controle está ativo
	 */
	public static function isActive():Bool
	{
		#if mobile
		return true;
		#else
		return false;
		#end
	}
	
	/**
	 * Atalho para verificar as 4 direções de uma vez
	 * Retorna um array [LEFT, DOWN, UP, RIGHT]
	 */
	public function getInputs():{left:Bool, down:Bool, up:Bool, right:Bool}
	{
		return {
			left: buttonPressed(0),
			down: buttonPressed(1),
			up: buttonPressed(2),
			right: buttonPressed(3)
		};
	}
	
	/**
	 * Atalho para just pressed
	 */
	public function getJustPressed():{left:Bool, down:Bool, up:Bool, right:Bool}
	{
		return {
			left: buttonJustPressed(0),
			down: buttonJustPressed(1),
			up: buttonJustPressed(2),
			right: buttonJustPressed(3)
		};
	}
	
	/**
	 * Atalho para just released
	 */
	public function getJustReleased():{left:Bool, down:Bool, up:Bool, right:Bool}
	{
		return {
			left: buttonJustReleased(0),
			down: buttonJustReleased(1),
			up: buttonJustReleased(2),
			right: buttonJustReleased(3)
		};
	}
}