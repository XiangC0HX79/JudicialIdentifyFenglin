package app.model
{
	import app.ApplicationFacade;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	import spark.formatters.DateTimeFormatter;
	
	public class MessageProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "MessageProxy";
						
		public function MessageProxy()
		{
			super(NAME, new ArrayCollection);
		}
		
		public function get list():ArrayCollection
		{
			return data as ArrayCollection;
		}
		
		public function refresh():void
		{
			var dateF:DateTimeFormatter = new DateTimeFormatter;
			dateF.dateTimePattern = "yyyy-MM-dd HH:mm:ss";
			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["GetTable",onGetTable
					,[
						"SELECT TOP 100 * FROM 留言板 ORDER BY 时间 DESC"
					]
				]);
			
			function onGetTable(arr:ArrayCollection):void
			{
				list.removeAll();
				
				for each(var item:Object in arr)
				{
					var s:String = "";					
					s += "[" + dateF.format(item["时间"]) + "] ";
					
					var name:String = item["姓名"];
					if(name.length == 2)
					{
						s += name.charAt(0) + "　" + name.charAt(1);
					}
					else
					{
						s += name;
					}
					
					s += "：";
					
					s += item["留言"];
					
					list.addItem(s);
				}
			}
		}
	}
}