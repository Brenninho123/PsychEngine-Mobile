package mobile;

import flixel.util.FlxSave;

/**
 * Classe para gerenciar dados e configurações dos controles mobile
 * @author: Brenninho123
 */
class MobileData
{
	// Configurações de controles
	public static var mode:Int = 0; // 0 = Hitbox, 1 = VirtualPad
	public static var hitboxLocation:String = 'bottom'; // bottom, top
	public static var hitboxAlpha:Float = 0.75;
	public static var hitboxExtend:Bool = false;
	
	// VirtualPad settings
	public static var virtualPadAlpha:Float = 0.75;
	public static var virtualPadSpacing:Int = 50;
	
	// Posições customizadas (se o usuário mover os controles)
	public static var customPositions:Map<String, Array<Float>> = new Map();
	
	// Outras opções
	public static var vibration:Bool = true;
	public static var buttonSize:Float = 1.0; // Multiplicador de tamanho
	
	private static var _save:FlxSave;
	
	/**
	 * Inicializa o sistema de save
	 */
	public static function init():Void
	{
		if (_save == null)
		{
			_save = new FlxSave();
			_save.bind('mobile-controls', 'psychengine');
		}
		load();
	}
	
	/**
	 * Carrega as configurações salvas
	 */
	public static function load():Void
	{
		if (_save == null)
			init();
			
		if (_save.data.mode != null)
			mode = _save.data.mode;
			
		if (_save.data.hitboxLocation != null)
			hitboxLocation = _save.data.hitboxLocation;
			
		if (_save.data.hitboxAlpha != null)
			hitboxAlpha = _save.data.hitboxAlpha;
			
		if (_save.data.hitboxExtend != null)
			hitboxExtend = _save.data.hitboxExtend;
			
		if (_save.data.virtualPadAlpha != null)
			virtualPadAlpha = _save.data.virtualPadAlpha;
			
		if (_save.data.virtualPadSpacing != null)
			virtualPadSpacing = _save.data.virtualPadSpacing;
			
		if (_save.data.vibration != null)
			vibration = _save.data.vibration;
			
		if (_save.data.buttonSize != null)
			buttonSize = _save.data.buttonSize;
			
		if (_save.data.customPositions != null)
			customPositions = _save.data.customPositions;
	}
	
	/**
	 * Salva as configurações atuais
	 */
	public static function save():Void
	{
		if (_save == null)
			init();
			
		_save.data.mode = mode;
		_save.data.hitboxLocation = hitboxLocation;
		_save.data.hitboxAlpha = hitboxAlpha;
		_save.data.hitboxExtend = hitboxExtend;
		_save.data.virtualPadAlpha = virtualPadAlpha;
		_save.data.virtualPadSpacing = virtualPadSpacing;
		_save.data.vibration = vibration;
		_save.data.buttonSize = buttonSize;
		_save.data.customPositions = customPositions;
		
		_save.flush();
	}
	
	/**
	 * Reseta todas as configurações para o padrão
	 */
	public static function reset():Void
	{
		mode = 0;
		hitboxLocation = 'bottom';
		hitboxAlpha = 0.75;
		hitboxExtend = false;
		virtualPadAlpha = 0.75;
		virtualPadSpacing = 50;
		vibration = true;
		buttonSize = 1.0;
		customPositions.clear();
		save();
	}
}
