package mobile;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.graphics.FlxGraphic;

class Hitbox extends FlxSpriteGroup
{
	public var buttonLeft:FlxButton;
	public var buttonDown:FlxButton;
	public var buttonUp:FlxButton;
	public var buttonRight:FlxButton;
	
	private var _location:String = 'bottom';
	
	/**
	 * Cria um novo Hitbox
	 * @param location Localização (bottom ou top)
	 */
	public function new(?location:String = 'bottom')
	{
		super();
		
		_location = location;
		
		// Criar os 4 botões
		var buttonWidth:Float = FlxG.width / 4;
		var buttonHeight:Float = FlxG.height / 4;
		
		if (MobileData.hitboxExtend)
			buttonHeight = FlxG.height / 3;
		
		var yPos:Float = _location == 'bottom' ? FlxG.height - buttonHeight : 0;
		
		// Botão LEFT (nota vermelha - esquerda)
		buttonLeft = new FlxButton(0, yPos, buttonWidth, buttonHeight, 0);
		buttonLeft.color = 0xFFC24B99; // Rosa/Roxo
		add(buttonLeft);
		
		// Botão DOWN (nota azul - baixo)
		buttonDown = new FlxButton(buttonWidth, yPos, buttonWidth, buttonHeight, 1);
		buttonDown.color = 0xFF00FFFF; // Ciano
		add(buttonDown);
		
		// Botão UP (nota verde - cima)
		buttonUp = new FlxButton(buttonWidth * 2, yPos, buttonWidth, buttonHeight, 2);
		buttonUp.color = 0xFF12FA05; // Verde
		add(buttonUp);
		
		// Botão RIGHT (nota vermelha - direita)
		buttonRight = new FlxButton(buttonWidth * 3, yPos, buttonWidth, buttonHeight, 3);
		buttonRight.color = 0xFFF9393F; // Vermelho
		add(buttonRight);
		
		// Aplicar alpha
		alpha = MobileData.hitboxAlpha;
		
		scrollFactor.set();
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		// Atualizar alpha se mudou
		if (alpha != MobileData.hitboxAlpha)
			alpha = MobileData.hitboxAlpha;
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
}

/**
 * Classe de botão customizada para o Hitbox
 */
class FlxButton extends FlxSprite
{
	public var pressed:Bool = false;
	public var justPressed:Bool = false;
	public var justReleased:Bool = false;
	
	private var _id:Int = 0;
	private var _lastPressed:Bool = false;
	
	public function new(x:Float, y:Float, width:Float, height:Float, id:Int)
	{
		super(x, y);
		
		_id = id;
		
		// Criar um retângulo colorido
		makeGraphic(Std.int(width), Std.int(height), FlxColor.WHITE);
		
		// Adicionar borda
		drawRect(0, 0, width, height, FlxColor.TRANSPARENT, {thickness: 3, color: FlxColor.BLACK});
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
		
		// Feedback visual
		alpha = pressed ? 1.0 : 0.6;
	}
	
	private function drawRect(x:Float, y:Float, width:Float, height:Float, fillColor:FlxColor, ?lineStyle:{thickness:Int, color:FlxColor}):Void
	{
		if (lineStyle != null)
		{
			var gfx = FlxGraphic.fromRectangle(Std.int(width), Std.int(height), fillColor, true);
			// Desenhar borda (simplificado)
			loadGraphic(gfx);
		}
	}
}