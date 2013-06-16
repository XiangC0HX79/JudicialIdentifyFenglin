package app.model.vo
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	
	import mx.graphics.codec.JPEGEncoder;

	[Bindable]
	public class AttachImageVO
	{		
		public var bitmapName:String;		
		
		public function get bitmapType():String
		{
			return bitmapName.substr(bitmapName.indexOf('.'),bitmapName.length);
		}
		
		public var bitmapArray:ByteArray;
		
		public var bitmapData:BitmapData;
		
		/*public function get facBitmapName():String
		{
			var fileName:String = bitmapName.substr(0,bitmapName.indexOf('.'));
			
			return fileName + ".fac";
		}*/
				
		public var facBitmapArray:ByteArray;
		
		public var facBitmapData:BitmapData;
		
		
		public function AttachImageVO()
		{
		}
	}
}