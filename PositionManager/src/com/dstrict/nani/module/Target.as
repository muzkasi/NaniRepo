package com.dstrict.nani.module
{
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	/**
	 * @author nani
	 */
	[Event( name = "complete", type = "flash.events.Event" )]
	public class Target extends Sprite
	{
		private const PADDING_POS_INDICATOR:uint = 5;
		private var _sizeIndicator:FloatIndicator;
		private var _dot1:Sprite;
		private var _dot2:Sprite;
		private var _dot3:Sprite;
		private var _dot4:Sprite;
		private var _posIndicator1:FloatIndicator;
		private var _posIndicator2:FloatIndicator;
		private var _posIndicator3:FloatIndicator;
		private var _posIndicator4:FloatIndicator;
		private var _rect:Rectangle;
		private var _imageArea:Sprite;
		private var _image:Bitmap;
		private var _fileReference:FileReference;

		public function Target()
		{
			createImage();
		}
		
		private function createImage():void
		{
			_imageArea = new Sprite();
			_imageArea.doubleClickEnabled = true;
			addChild(_imageArea);
			
			loadTargetImage();
		}

		private function loadTargetImage():void
		{
			var imageLoader:Loader = new Loader();
			imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoaded);
			imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onImageLoadError);
			imageLoader.load(new URLRequest("inc/target.png"));
		}
		
		private function onImageLoaded(event:Event):void
		{
			_image = Bitmap(LoaderInfo(event.target).content);
			_imageArea.addChild(_image);
			_rect = _image.getRect(this);
			createLayout();
		}
		
		private function createLayout():void
		{
			createCornerDots();
			createIndicators();
			updateDots();
			updateIndicator();
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function onImageLoadError(event:IOErrorEvent):void
		{
			var bitmapData:BitmapData = new BitmapData(1024, 768, false, 0x555555);
			_image = new Bitmap(bitmapData);
			_imageArea.addChild(_image);
			_rect = _image.getRect(this);
			createLayout();
		}
		
		public function getTargetRect():Rectangle
		{
			return _rect;
		}

		
		private function createCornerDots():void
		{
			_dot1 = createDot(0x2233CC);
			this.addChild(_dot1);
			
			_dot2 = createDot(0x2233CC);
			this.addChild(_dot2);
			
			_dot3 = createDot(0x2233CC);
			this.addChild(_dot3);
			
			_dot4 = createDot(0xCC3322);
			this.addChild(_dot4);
		}
		
		private function createDot(bgcolor:uint):Sprite
		{
			var dot:Sprite = new Sprite();
			dot.graphics.beginFill(bgcolor);
			dot.graphics.lineStyle(2,0xFFFFFF);
			dot.graphics.drawCircle(0, 0, 5);
			dot.graphics.endFill();
			return dot;
		}
		
		private function createIndicators():void
		{
			_sizeIndicator = new FloatIndicator();
			this.addChild(_sizeIndicator);
			
			_posIndicator1 = new FloatIndicator();
			this.addChild(_posIndicator1);
			
			_posIndicator2 = new FloatIndicator();
			this.addChild(_posIndicator2);
			
			_posIndicator3 = new FloatIndicator();
			this.addChild(_posIndicator3);
			
			_posIndicator4 = new FloatIndicator();
			this.addChild(_posIndicator4);
		}

		public function updateDots():void
		{
			_dot2.x = _rect.width;
			_dot3.y = _rect.height;
			_dot4.x = _rect.width;
			_dot4.y = _rect.height;			
		}
		
		public function updateIndicator():void
		{
			//0x4AFFFF;
			
			_sizeIndicator.setSize(_rect.width, _rect.height);
			_sizeIndicator.x = (_rect.width - _sizeIndicator.width)/2;
			_sizeIndicator.y = (_rect.height - _sizeIndicator.height)/2;
			
			_posIndicator1.setPos(this.x, this.y);
			_posIndicator1.x = PADDING_POS_INDICATOR;
			_posIndicator1.y = PADDING_POS_INDICATOR;
			
			_posIndicator2.setPos(this.x+_rect.width, this.y);
			_posIndicator2.x = _rect.width - _posIndicator2.width - PADDING_POS_INDICATOR;
			_posIndicator2.y = PADDING_POS_INDICATOR;
			
			_posIndicator3.setPos(this.x, this.y+_rect.height);
			_posIndicator3.x = PADDING_POS_INDICATOR;
			_posIndicator3.y = _rect.height - _posIndicator3.height - PADDING_POS_INDICATOR;
			
			_posIndicator4.setPos(this.x+_rect.width, this.y+_rect.height);
			_posIndicator4.x = _rect.width - _posIndicator4.width - PADDING_POS_INDICATOR;
			_posIndicator4.y = _rect.height - _posIndicator4.height - PADDING_POS_INDICATOR;
		}

		public function toggleIndicatorVisible():void
		{
			_sizeIndicator.visible = !_sizeIndicator.visible; 
			_posIndicator1.visible = !_posIndicator1.visible;
			_posIndicator2.visible = !_posIndicator2.visible;
			_posIndicator3.visible = !_posIndicator3.visible;
			_posIndicator4.visible = !_posIndicator4.visible; 
		}
		
		public function isOnHandler(globalX:Number,globalY:Number):Boolean
		{
			return (_dot4.hitTestPoint(globalX, globalY)); 
		}
		
		public function updateSize(deltaW:int,deltaH:int,useRatio:Boolean=false):void
		{
			_image.width += deltaW;
			_image.height += deltaH;
			
			if(useRatio)
			{
				if(_image.scaleX>_image.scaleY) _image.scaleX = _image.scaleY;
				else _image.scaleY = _image.scaleX;
			}
			updateRect();
		}
		
		private function updateRect():void
		{
			if(_image.width<200) _image.width = 200;
			if(_image.height<200) _image.height = 200;
			
			_rect = _image.getRect(this);
			updateIndicator();
			updateDots();
		}
		
		public function updateScale(value:Number):void
		{
			if(_image.width>_image.height)
			{
				_image.height += (value * (_image.height / _image.width));
				_image.width += value;
			}
			else {
				_image.width += (value * (_image.width/ _image.height ));
				_image.height += value;
			}
			
			updateRect();
		}
		
		public function setOrigin():void
		{
			if(_image.width==_image.bitmapData.width && _image.height == _image.bitmapData.height)
			{
				_image.width = int(_image.bitmapData.width / 2);
				_image.height = int(_image.bitmapData.height / 2);				
			}
			else {
				_image.width = _image.bitmapData.width;
				_image.height = _image.bitmapData.height;
			}
			
			_rect = _image.getRect(this);
			updateIndicator();
			updateDots();
		}
		

		public function openNewImage(): void
		{
			_fileReference = new FileReference();
			_fileReference.addEventListener( Event.SELECT, selectHandler );
			_fileReference.addEventListener( Event.CANCEL, cancelHandler );
			_fileReference.browse( [ new FileFilter( "Image( *.jpg, *.gif, *.png )", "*.jpg; *.gif; *.png" ) ] );
		}
		
		private function selectHandler( e: Event ): void
		{
			_fileReference.addEventListener( Event.COMPLETE, completeHandler );
			_fileReference.addEventListener( IOErrorEvent.IO_ERROR, errorHandler );
			_fileReference.load();
		}
		
		private function cancelHandler( e: Event ): void
		{
			_fileReference = null;
		}
		
		private function completeHandler( e: Event ): void
		{
			var loader:Loader = new Loader();
			
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onComplete );
			loader.loadBytes(_fileReference.data);
		}
		
		private function onComplete( e: Event ): void
		{
			_imageArea.removeChild(_image);
			_image = Bitmap(LoaderInfo(e.target).content);
			_imageArea.addChild(_image);
			_rect = _image.getRect(this);
			updateDots();
			updateIndicator();
			dispatchEvent(new Event(Event.COMPLETE));
		}

		private function errorHandler( e: IOErrorEvent ): void
		{
			trace( "IOError : " + e.text );
		}		
		
	}
	
	
}
