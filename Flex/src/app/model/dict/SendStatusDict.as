package app.model.dict
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class SendStatusDict
	{
		public var id:Number;
		public var label:String = "";	
		
		public function SendStatusDict(id:Number,label:String)
		{
			this.id = id;
			this.label = label;
		}
		
		public static var dict:Dictionary = new Dictionary;
		
		public static function get list():ArrayCollection
		{
			var arr:Array = new Array;
			for each (var item:SendStatusDict in dict)
			{
				arr.push(item);
			}			
			arr.sortOn("id",Array.NUMERIC);
			
			return new ArrayCollection(arr);
		}
		
		public static function get listDropdown():ArrayCollection
		{
			var arr:Array = new Array;
			for each (var item:SendStatusDict in dict)
			{
				if(item.label != "未通知")
					arr.push(item);
			}			
			arr.sortOn("id",Array.NUMERIC);
			
			return new ArrayCollection(arr);
		}
	}
}