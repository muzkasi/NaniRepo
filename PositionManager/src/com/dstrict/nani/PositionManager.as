package com.dstrict.nani
{
	import com.dstrict.nani.module.Target;

	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	[SWF(frameRate=50,width=4000,height=4000,backgroundColor="#000000")]
	public class PositionManager extends Sprite
	{
		private const STAGE_WIDTH:uint = 4000;
		private const STAGE_HEIGHT:uint = 4000;
		private var _target:Target;
		private var _rect:Rectangle;
		private var _targetLine:Sprite;

		private var _prevX:int;
		private var _prevY:int;
		
		private var _lostDeltaX:int;
		private var _lostDeltaY:int;
		
		public function PositionManager()
		{
			this.addEventListener(Event.ADDED_TO_STAGE, onStage);
		}
		
		private function onStage(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onStage);
			this.stage.doubleClickEnabled = true;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			
			createLayout();
			addKeyEvent();
		}
		
		private function createLayout():void
		{
			createBg();
			createTargetLine();
			createTarget();
		}
		
		private function createBg():void
		{
			var bg:Sprite = new Sprite();
			bg.graphics.beginFill(0,1);
			bg.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			bg.graphics.endFill();
			
			bg.graphics.lineStyle(1,0x888888,0.5);
			
			var loopW:uint = Math.ceil(STAGE_WIDTH/100);
			var loopH:uint = Math.ceil(STAGE_HEIGHT/100);
			
			for(var i:uint=0;i<loopW;i++)
			{
				bg.graphics.moveTo(i*100, 0);
				bg.graphics.lineTo(i*100, STAGE_HEIGHT);
			}
			
			for(var j:uint=0;j<loopH;j++)
			{				
				bg.graphics.moveTo(0, j*100);
				bg.graphics.lineTo(STAGE_WIDTH, j*100);				
			}
			
			addChild(bg);
		}
		
				
		private function createTargetLine():void
		{
			_targetLine = new Sprite();
			addChild(_targetLine);
		}
		
		private function updateTargeLine():void
		{
			_rect = _target.getTargetRect();
			if(_rect==null) return;
			
			_targetLine.graphics.clear();
			_targetLine.graphics.lineStyle(1,0x4AFFFF);
			_targetLine.graphics.moveTo(_target.x, 0);
			_targetLine.graphics.lineTo(_target.x, STAGE_HEIGHT);
			_targetLine.graphics.moveTo(_target.x+_rect.width, 0);
			_targetLine.graphics.lineTo(_target.x+_rect.width, STAGE_HEIGHT);
			_targetLine.graphics.moveTo(0,_target.y);
			_targetLine.graphics.lineTo(STAGE_WIDTH,_target.y);
			_targetLine.graphics.moveTo(0,_target.y+_rect.height);
			_targetLine.graphics.lineTo(STAGE_HEIGHT,_target.y+_rect.height );			
		}
		
		private function addKeyEvent():void
		{
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			this.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		private function createTarget():void
		{
			_target = new Target();
			_target.addEventListener(MouseEvent.MOUSE_DOWN, onTargetDown);
			_target.addEventListener(MouseEvent.DOUBLE_CLICK, onDoublieClicked);
			_target.addEventListener(MouseEvent.RIGHT_CLICK, onRightClicked);
			_target.addEventListener(Event.COMPLETE, onTargetLoaded);
			_target.doubleClickEnabled = true;
			addChild(_target);
		}
		
		private function onTargetLoaded(event:Event):void
		{
			updateTargeLine();
		}
		
		private function onTargetDown(event:MouseEvent):void
		{
			_lostDeltaX = 0;
			_lostDeltaY = 0;
			
			_prevX = stage.mouseX;
			_prevY = stage.mouseY;
			
			if(_target.isOnHandler(_prevX, _prevY))
			{
				this.addEventListener(MouseEvent.MOUSE_MOVE, onHandlerMouseMove);
			}
			else { 
				this.addEventListener(MouseEvent.MOUSE_MOVE, onTargetMouseMove);
			}
			
			this.addEventListener(MouseEvent.MOUSE_UP, onTargetUp);
		}
		
		private function onHandlerMouseMove(event:MouseEvent):void
		{
			var deltaX:int = (stage.mouseX - _prevX);
			var deltaY:int = (stage.mouseY - _prevY);
			
			if(event.altKey)
			{
				_target.updateSize(deltaX+_lostDeltaX, 0);
				_lostDeltaX = 0;
				_lostDeltaY += deltaY;
			}
			else if(event.ctrlKey)
			{
				_target.updateSize(0, deltaY+_lostDeltaY);
				_lostDeltaY = 0;
				_lostDeltaX += deltaX;
			}
			else
			{
				_target.updateSize(deltaX+_lostDeltaX, deltaY+_lostDeltaY,event.shiftKey);
				_lostDeltaX = 0;
				_lostDeltaY = 0;
			}
			
			updateTargeLine();
			
			_prevX = stage.mouseX;
			_prevY = stage.mouseY;
			
			event.updateAfterEvent();
		}
		
		private function addLostValue():void
		{
			_target.updateSize(_lostDeltaX, _lostDeltaY);
			_lostDeltaX = 0;
			_lostDeltaY = 0;
			
			updateTargeLine();
		}
		
		private function updateScale(value:int):void
		{
			_target.updateScale(value);
			updateTargeLine();
		}
		
		private function onTargetMouseMove(event:MouseEvent):void
		{
			var deltaX:int = (stage.mouseX - _prevX);
			var deltaY:int = (stage.mouseY - _prevY);
			 
			if(!event.altKey) _target.x += deltaX;
			if(!event.ctrlKey) _target.y += deltaY;
			
			_prevX = stage.mouseX;
			_prevY = stage.mouseY;
			
			_target.updateIndicator();
			updateTargeLine();
			
			event.updateAfterEvent();
		}
		
		
				
		private function onTargetUp(event:MouseEvent):void
		{
			if(this.hasEventListener(MouseEvent.MOUSE_MOVE))
			{
				_lostDeltaX = 0;
				_lostDeltaY = 0;				
				this.removeEventListener(MouseEvent.MOUSE_MOVE, onTargetMouseMove);
				this.removeEventListener(MouseEvent.MOUSE_MOVE, onHandlerMouseMove);
			}
		}
		
		private function onDoublieClicked(event:MouseEvent):void
		{
			trace("onDoublieClicked");
			_target.setOrigin();
			updateTargeLine();
		}
		
		
		private function onRightClicked(event:MouseEvent):void
		{
			if(this.hasEventListener(MouseEvent.MOUSE_MOVE))
			{
				_target.openNewImage();
				onTargetUp(null);
			}
			else {
				_target.toggleIndicatorVisible();	
			}
		}
		
		private function onKeyDown(event:KeyboardEvent):void
		{
			var code:int = event.keyCode;
			
			switch(code)
			{
				case Keyboard.LEFT:
					if((event.ctrlKey && event.altKey) || (event.ctrlKey && event.shiftKey)) _target.x -= 100;
					else if(event.altKey || event.ctrlKey || event.shiftKey) _target.x -= 10;
					else _target.x -= 1;
					_target.updateIndicator();
					updateTargeLine();
					break;
				case Keyboard.RIGHT:
					if((event.ctrlKey && event.altKey) || (event.ctrlKey && event.shiftKey)) _target.x += 100;
					else if(event.altKey || event.ctrlKey || event.shiftKey) _target.x += 10;
					else _target.x += 1;
					_target.updateIndicator();
					updateTargeLine();
					break;
				case Keyboard.UP:
					if((event.ctrlKey && event.altKey) || (event.ctrlKey && event.shiftKey)) _target.y -= 100;
					else if(event.altKey || event.ctrlKey || event.shiftKey) _target.y -= 10;
					else _target.y -= 1;
					_target.updateIndicator();
					updateTargeLine();
					break;
				case Keyboard.DOWN:
					if((event.ctrlKey && event.altKey) || (event.ctrlKey && event.shiftKey)) _target.y += 100;
					else if(event.altKey || event.ctrlKey || event.shiftKey) _target.y += 10;
					else _target.y += 1;
					_target.updateIndicator();
					updateTargeLine();
					break;
				case Keyboard.MINUS:
				case Keyboard.NUMPAD_SUBTRACT:
					if(event.altKey || event.ctrlKey || event.shiftKey) updateScale(-10);
					else updateScale(-1);
					break;
				case Keyboard.EQUAL:
				case Keyboard.NUMPAD_ADD:
					if(event.altKey || event.ctrlKey || event.shiftKey) updateScale(+10);
					else updateScale(1);
					break;					
				case Keyboard.H:
				case Keyboard.F:
					_target.toggleIndicatorVisible();
					updateTargeLine();
					break;
				case Keyboard.Q:
				case Keyboard.W:
					if(event.ctrlKey)
					{
						NativeApplication.nativeApplication.exit();	
					}
					break;
				case Keyboard.O:
				 	if(event.ctrlKey)
				 	{
						_target.openNewImage();
					}
					break;

			}
			
		}
		
		private function onKeyUp(event:KeyboardEvent):void
		{
			var code:int = event.keyCode;
			
			switch(code)
			{
				case Keyboard.CONTROL:
				case Keyboard.ALTERNATE:
					addLostValue();
					break;
			}
		}


	}
}
