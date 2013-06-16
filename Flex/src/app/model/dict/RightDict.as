package app.model.dict
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class RightDict
	{
		public static const NONE:RightDict = new RightDict(-2,"");
		
		public var id:Number;
		public var label:String = "";	
		
		public var selected:Boolean = false;
		
		public function RightDict(id:Number,label:String)
		{
			this.id = id;
			this.label = label;
		}
		
		public static var dict:Dictionary = new Dictionary;
		
		public static function get list():ArrayCollection
		{
			var arr:Array = new Array;
			for each (var item:RightDict in dict)
			{
				arr.push(item);
			}			
			arr.sortOn("id",Array.NUMERIC);
			
			return new ArrayCollection(arr);
		}
		
		public static function getItem(idorlabel:*):RightDict
		{
			if(dict[idorlabel] != undefined)
			{
				return dict[idorlabel];
			}
			else
			{
				for each(var item:RightDict in dict)
				{
					if(item.label == String(idorlabel))
						return item;
				}
			}
			
			return NONE;
		}
	}
}