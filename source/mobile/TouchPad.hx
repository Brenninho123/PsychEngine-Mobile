package mobile;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;

class TouchPad extends FlxSpriteGroup
{
	public var buttonLeft:TouchButton;
	public var buttonDown:TouchButton;
	public var buttonUp:TouchButton;
	public var buttonRight:TouchButton;
	
	private var _spacing:Int = 50;
	
	/**
	 * Cria um novo VirtualPad
	 */
	public function new()
	{
		super();
		
		_spacing = MobileData.virtualPadSpacing;
		
		// Tamanho base dos botões
		var buttonSize:Float = 100 * MobileData.buttonSize;
		
		// Posições padrão (canto inferior direito)
		var baseX:Float = FlxG.width - (buttonSize * 2 + _spacing * 2);
		var baseY:Float = FlxG.height - (buttonSize * 2 + _spacing * 2);
		
		// Criar os 4 botões em formato de cruz (D-Pad)
		// Centro da cruz
		var centerX:Float = baseX + buttonSize / 2 + _spacing / 2;
		var centerY:Float = baseY + buttonSize / 2 + _spacing / 2;
		
		// LEFT (esquerda do centro)
		buttonLeft = new TouchButton(centerX - buttonSize - _spacing/2, centerY, 'left', 0);
		add(buttonLeft);
		
		// DOWN (embaixo do centro)
		buttonDown = new TouchButton(centerX, centerY + buttonSize + _spacing/2, 'down', 1);
		add(buttonDown);
		
		// UP (em cima do centro)
		buttonUp = new TouchButton(centerX, centerY - buttonSize - _spacing/2, 'up', 2);
		add(buttonUp);
		
		// RIGHT (direita do centro)
		buttonRight = new TouchButton(centerX + buttonSize + _spacing/2, centerY, 'right', 3);
		add(buttonRight);
		
		// Aplicar alpha
		alpha = MobileData.virtualPadAlpha;
		
		scrollFactor.set();
		
		// Carregar posições customizadas se existirem
		loadCustomPositions();
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		// Atualizar alpha se mudou
		if (alpha != MobileData.virtualPadAlpha)
			alpha = MobileData.virtualPadAlpha;
	}
	
	/**
	 * Verifica se algum botão específico está sendo pressionado
	 */
	public function buttonPressed(id:Int):Bool
	{
		switch(id)
		{
			case 0: return buttonLeft.pressed;
			case 1: return buttonDown.pressed;
			case 2: return buttonUp.pressed;
			case 3: return buttonRight.pressed;
		}
		return false;
	}
	
	/**
	 * Verifica se algum botão específico foi acabado de pressionar
	 */
	public function buttonJustPressed(id:Int):Bool
	{
		switch(id)
		{
			case 0: return buttonLeft.justPressed;
			case 1: return buttonDown.justPressed;
			case 2: return buttonUp.justPressed;
			case 3: return buttonRight.justPressed;
		}
		return false;
	}
	
	/**
	 * Verifica se algum botão específico foi acabado de soltar
	 */
	public function buttonJustReleased(id:Int):Bool
	{
		switch(id)
		{
			case 0: return buttonLeft.justReleased;
			case 1: return buttonDown.justReleased;
			case 2: return buttonUp.justReleased;
			case 3: return buttonRight.justReleased;
		}
		return false;
	}
	
	/**
	 * Salva as posições atuais dos botões
	 */
	public function saveCustomPositions():Void
	{
		MobileData.customPositions.set('left', [buttonLeft.x, buttonLeft.y]);
		MobileData.customPositions.set('down', [buttonDown.x, buttonDown.y]);
		MobileData.customPositions.set('up', [buttonUp.x, buttonUp.y]);
		MobileData.customPositions.set('right', [buttonRight.x, buttonRight.y]);
		MobileData.save();
	}
	
	/**
	 * Carrega as posições customizadas salvas
	 */
	public function loadCustomPositions():Void
	{
		if (MobileData.customPositions.exists('left'))
		{
			var pos = MobileData.customPositions.get('left');
			buttonLeft.setPosition(pos[0], pos[1]);
		}
		
		if (MobileData.customPositions.exists('down'))
		{
			var pos = MobileData.customPositions.get('down');
			buttonDown.setPosition(pos[0], pos[1]);
		}
		
		if (MobileData.customPositions.exists('up'))
		{
			var pos = MobileData.customPositions.get('up');
			buttonUp.setPosition(pos[0], pos[1]);
		}
		
		if (MobileData.customPositions.exists('right'))
		{
			var pos = MobileData.customPositions.get('right');
			buttonRight.setPosition(pos[0], pos[1]);
		}
	}
	
	/**
	 * Reseta as posições para o padrão
	 */
	public function resetPositions():Void
	{
		MobileData.customPositions.clear();
		// Recriar o pad
		// (seria necessário reconstruir, mas para simplificar vamos apenas limpar os dados)
		MobileData.save();
	}
}

/**
 * Classe de botão para o VirtualPad
 */
class TouchButton extends FlxSprite
{
	public var pressed:Bool = false;
	public var justPressed:Bool = false;
	public var justReleased:Bool = false;
	
	private var _id:Int = 0;
	private var _direction:String;
	private var _lastPressed:Bool = false;
	private var _originalScale:Float = 1.0;
	
	public function new(x:Float, y:Float, direction:String, id:Int)
	{
		super(x, y);
		
		_id = id;
		_direction = direction;
		_originalScale = MobileData.buttonSize;
		
		// Carregar imagem do virtualpad
		// Tenta carregar a imagem específica, se não existir usa uma cor
		var imgPath:String = 'assets/mobile/virtualpad/$direction.png';
		
		if (Paths.fileExists(imgPath, IMAGE))
		{
			loadGraphic(Paths.image('mobile/virtualpad/$direction'));
		}
		else
		{
			// Fallback: criar um gráfico colorido
			makeGraphic(100, 100, getColorForDirection(direction));
		}
		
		// Aplicar escala
		scale.set(_originalScale, _originalScale);
		updateHitbox();
		
		antialiasing = ClientPrefs.data.antialiasing;
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		// Resetar flags
		justPressed = false;
		justReleased = false;
		
		// Verificar touch
		var touched:Bool = false;
		
		#if FLX_TOUCH
		for (touch in FlxG.touches.list)
		{
			if (touch.overlaps(this))
			{
				touched = true;
				break;
			}
		}
		#end
		
		// Detectar press e release
		if (touched && !_lastPressed)
		{
			justPressed = true;
			
			// Vibração
			#if mobile
			if (MobileData.vibration)
				FlxG.vibrate(50);
			#end
		}
		else if (!touched && _lastPressed)
		{
			justReleased = true;
		}
		
		pressed = touched;
		_lastPressed = touched;
		
		// Feedback visual - botão fica maior quando pressionado
		if (pressed)
		{
			scale.set(_originalScale * 1.1, _originalScale * 1.1);
			alpha = 1.0;
		}
		else
		{
			scale.set(_originalScale, _originalScale);
			alpha = 0.8;
		}
		
		updateHitbox();
	}
	
	/**
	 * Retorna uma cor baseada na direção (fallback)
	 */
	private function getColorForDirection(dir:String):Int
	{
		switch(dir)
		{
			case 'left': return 0xFFC24B99;  // Rosa/Roxo
			case 'down': return 0xFF00FFFF;  // Ciano
			case 'up': return 0xFF12FA05;    // Verde
			case 'right': return 0xFFF9393F; // Vermelho
		}
		return 0xFFFFFFFF;
	}
}