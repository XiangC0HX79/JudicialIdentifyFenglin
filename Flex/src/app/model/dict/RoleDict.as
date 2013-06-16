package app.model.dict
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class RoleDict
	{
		public static const NONE:RoleDict = new RoleDict(-2,"");
		
		public var id:Number;
		public var label:String = "";	
		
		public var selected:Boolean = false;
		
		public function RoleDict(id:Number,label:String)
		{
			this.id = id;
			this.label = label;
		}
		
		public static var dict:Dictionary = new Dictionary;
		
		public static function get list():ArrayCollection
		{
			var arr:Array = new Array;
			for each (var item:RoleDict in dict)
			{
				arr.push(item);
			}			
			arr.sortOn("id",Array.NUMERIC);
			
			return new ArrayCollection(arr);
		}
		
		public static function getItem(idorlabel:*):RoleDict
		{
			if(dict[idorlabel] != undefined)
			{
				return dict[idorlabel];
			}
			else
			{
				for each(var item:RoleDict in dict)
				{
					if(item.label == String(idorlabel))
						return item;
				}
			}
			
			return NONE;
		}
	}
}