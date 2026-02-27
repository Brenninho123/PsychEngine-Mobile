package mobile;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.addons.display.FlxBackdrop;

/**
 * SubState de configuração dos controles mobile
 * @author: Brenninho123
 */
class MobileControlsSubState extends MusicBeatSubstate
{
	private var bg:FlxSprite;
	private var optionsGroup:FlxTypedGroup<FlxText>;
	private var curSelected:Int = 0;
	private var options:Array<String> = [];
	private var optionsDesc:Array<String> = [];
	
	private var titleText:FlxText;
	private var descText:FlxText;
	
	private var previewControls:MobileControls;
	
	override public function create():Void
	{
		super.create();
		
		// Background
		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		add(bg);
		
		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		
		// Título
		titleText = new FlxText(0, 50, FlxG.width, "Mobile Controls Settings", 32);
		titleText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		titleText.borderSize = 2;
		add(titleText);
		
		// Opções
		setupOptions();
		
		optionsGroup = new FlxTypedGroup<FlxText>();
		add(optionsGroup);
		
		// Criar textos das opções
		for (i in 0...options.length)
		{
			var optionText:FlxText = new FlxText(0, 150 + (i * 80), FlxG.width, options[i], 24);
			optionText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
			optionText.borderSize = 1.5;
			optionText.ID = i;
			optionsGroup.add(optionText);
		}
		
		// Descrição
		descText = new FlxText(50, FlxG.height - 100, FlxG.width - 100, "", 18);
		descText.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		descText.borderSize = 1;
		add(descText);
		
		// Preview dos controles
		previewControls = new MobileControls();
		previewControls.alpha = 0.5;
		add(previewControls);
		
		changeSelection(0);
	}
	
	private function setupOptions():Void
	{
		options = [
			'Control Type: ${getControlTypeName()}',
			'Hitbox Location: ${MobileData.hitboxLocation.toUpperCase()}',
			'Hitbox Extended: ${MobileData.hitboxExtend ? "ON" : "OFF"}',
			'Control Alpha: ${Math.round(getCurrentAlpha() * 100)}%',
			'Button Size: ${Math.round(MobileData.buttonSize * 100)}%',
			'Vibration: ${MobileData.vibration ? "ON" : "OFF"}',
			'Reset to Default',
			'Back'
		];
		
		optionsDesc = [
			'Change between Hitbox and Virtual Pad',
			'Change hitbox position (Top or Bottom)',
			'Extend hitbox height for easier gameplay',
			'Adjust transparency of the controls',
			'Change the size of control buttons',
			'Toggle vibration feedback',
			'Reset all settings to default',
			'Return to previous menu'
		];
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		// Navegação
		if (controls.UI_UP_P)
			changeSelection(-1);
		if (controls.UI_DOWN_P)
			changeSelection(1);
		
		// Mudança de valores
		if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
			changeValue(controls.UI_RIGHT_P ? 1 : -1);
		
		// Confirmar
		if (controls.ACCEPT)
			selectOption();
		
		// Voltar
		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MobileData.save();
			close();
		}
	}
	
	private function changeSelection(change:Int = 0):Void
	{
		curSelected += change;
		
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;
		
		// Atualizar visual
		var i:Int = 0;
		for (text in optionsGroup)
		{
			text.alpha = (text.ID == curSelected) ? 1 : 0.6;
			text.scale.set(1, 1);
			
			if (text.ID == curSelected)
			{
				text.scale.set(1.1, 1.1);
				descText.text = optionsDesc[curSelected];
			}
			i++;
		}
		
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
	
	private function changeValue(change:Int):Void
	{
		switch(curSelected)
		{
			case 0: // Control Type
				MobileData.mode = (MobileData.mode + change + 2) % 2;
				previewControls.changeMode(MobileData.mode);
				
			case 1: // Hitbox Location
				MobileData.hitboxLocation = (MobileData.hitboxLocation == 'bottom') ? 'top' : 'bottom';
				previewControls.changeMode(MobileData.mode); // Refresh
				
			case 2: // Hitbox Extended
				MobileData.hitboxExtend = !MobileData.hitboxExtend;
				previewControls.changeMode(MobileData.mode); // Refresh
				
			case 3: // Alpha
				var currentAlpha = getCurrentAlpha();
				currentAlpha += change * 0.1;
				if (currentAlpha < 0.1) currentAlpha = 0.1;
				if (currentAlpha > 1.0) currentAlpha = 1.0;
				setCurrentAlpha(currentAlpha);
				previewControls.alpha = currentAlpha;
				
			case 4: // Button Size
				MobileData.buttonSize += change * 0.1;
				if (MobileData.buttonSize < 0.5) MobileData.buttonSize = 0.5;
				if (MobileData.buttonSize > 2.0) MobileData.buttonSize = 2.0;
				previewControls.changeMode(MobileData.mode); // Refresh
				
			case 5: // Vibration
				MobileData.vibration = !MobileData.vibration;
		}
		
		// Atualizar textos
		setupOptions();
		for (i in 0...optionsGroup.length)
		{
			optionsGroup.members[i].text = options[i];
		}
		
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
	
	private function selectOption():Void
	{
		switch(curSelected)
		{
			case 6: // Reset
				MobileData.reset();
				previewControls.changeMode(MobileData.mode);
				setupOptions();
				for (i in 0...optionsGroup.length)
				{
					optionsGroup.members[i].text = options[i];
				}
				FlxG.sound.play(Paths.sound('confirmMenu'));
				
			case 7: // Back
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MobileData.save();
				close();
		}
	}
	
	private function getControlTypeName():String
	{
		return (MobileData.mode == 0) ? "HITBOX" : "VIRTUAL PAD";
	}
	
	private function getCurrentAlpha():Float
	{
		return (MobileData.mode == 0) ? MobileData.hitboxAlpha : MobileData.virtualPadAlpha;
	}
	
	private function setCurrentAlpha(value:Float):Void
	{
		if (MobileData.mode == 0)
			MobileData.hitboxAlpha = value;
		else
			MobileData.virtualPadAlpha = value;
	}
}