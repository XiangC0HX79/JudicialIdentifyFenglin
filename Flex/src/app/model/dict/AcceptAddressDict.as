package app.model.dict
	{
		import flash.utils.Dictionary;
		
		import mx.collections.ArrayCollection;
		
		[Bindable]
		public class AcceptAddressDict
		{
			public static const NONE:AcceptAddressDict = new AcceptAddressDict(-2,"");
			public static const ALL:AcceptAddressDict = new AcceptAddressDict(-1,"所有地点");
			
			public var id:Number;
			public var label:String = "";	
			
			public function AcceptAddressDict(id:Number,label:String)
			{
				this.id = id;
				this.label = label;
			}
			
			public static var dict:Dictionary = new Dictionary;
			
			public static function get list():ArrayCollection
			{
				var arr:Array = new Array;
				for each (var item:AcceptAddressDict in dict)
				{
					arr.push(item);
				}			
				arr.sortOn("id",Array.NUMERIC);
				
				return new ArrayCollection(arr);
			}
						
			public static function get listAll():ArrayCollection
			{
				var arr:Array = new Array;
				arr.push(AcceptAddressDict.ALL);
				
				for each (var item:AcceptAddressDict in dict)
				{
					arr.push(item);
				}			
				arr.sortOn("id",Array.NUMERIC);
				
				return new ArrayCollection(arr);
			}
			
			public static function getItem(idorlabel:*):AcceptAddressDict
			{
				if(dict[idorlabel] != undefined)
				{
					return dict[idorlabel];
				}
				else
				{
					for each(var item:AcceptAddressDict in dict)
					{
						if(item.label == String(idorlabel))
							return item;
					}
				}
				
				return NONE;
			}
		}
	}