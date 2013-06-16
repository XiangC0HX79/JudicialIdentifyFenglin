package app.model.dict
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	public class GroupDict
	{		
		public static const NONE:GroupDict = new GroupDict(-2,"");
		public static const ALL:GroupDict = new GroupDict(-1,"所有");
		
		public var id:Number;
		public var label:String;	
		
		public var selected:Boolean = true;
		
		public function GroupDict(id:Number,label:String)
		{
			this.id = id;
			this.label = label;
		}
				
		public static var dict:Dictionary = new Dictionary;
				
		public static function get list():ArrayCollection
		{
			var arr:Array = new Array;
			for each (var item:GroupDict in dict)
			{
				arr.push(item);
			}			
			arr.sortOn("id",Array.NUMERIC);
			
			return new ArrayCollection(arr);
		}
		
		public static function get listAll():ArrayCollection
		{
			var arr:Array = new Array;
			arr.push(GroupDict.ALL);
			
			for each (var item:GroupDict in dict)
			{
				arr.push(item);
			}			
			arr.sortOn("id",Array.NUMERIC);
			
			return new ArrayCollection(arr);
		}
		
		public static function getItem(idorlabel:*):GroupDict
		{
			if(dict[idorlabel] != undefined)
			{
				return dict[idorlabel];
			}
			else
			{
				for each(var item:GroupDict in dict)
				{
					if(item.label == String(idorlabel))
						return item;
				}
			}
			
			return NONE;
		}
	}
}