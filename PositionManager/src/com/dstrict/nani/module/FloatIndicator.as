package com.dstrict.nani.module
{
	import flash.text.TextFormatAlign;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.display.Sprite;
	/**
	 * @author nani
	 */
	public class FloatIndicator extends Sprite
	{
		private var _text:TextField;
		
		public function FloatIndicator()
		{
			createLayout();
		}
		
		public function createLayout():void
		{
			createBg();
			createText();
		}
		
		private function createBg():void
		{
			var bg:Sprite = new Sprite();
			bg.graphics.beginFill(0x000000,0.7);
			bg.graphics.lineStyle(1,0xFFFFFF,1,true);
			bg.graphics.drawRoundRect(0, 0, 150, 40, 8);
			bg.graphics.endFill();
			addChild(bg);
		}
		
		private function createText():void
		{
			var format:TextFormat = new TextFormat();
			format.color = 0xFFFFFF;
			format.size = 25;
			format.align = TextFormatAlign.CENTER;
			
			_text = new TextField();
			_text.selectable = false;
			_text.defaultTextFormat = format;
			_text.width = 150;
			_text.height = 30;
			_text.y = 5;
			_text.text = "0,0";
			addChild(_text);
		}
		
		public function setPos(x:int,y:int):void
		{
			_text.text = x+", "+y;
		}
		
		public function setSize(w:int,h:int):void
		{
			_text.text = w+" x "+h;
		}

	}
}
