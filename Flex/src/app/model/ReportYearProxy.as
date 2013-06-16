package app.model
{
	import app.ApplicationFacade;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class ReportYearProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "ReportYearProxy";
		
		public function ReportYearProxy()
		{
			super(NAME, new ArrayCollection);
		}
		
		public function get list():ArrayCollection
		{
			return data as ArrayCollection;
		}
		
		public function refresh():void
		{
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["GetTable",onGetResult
					,["SELECT DISTINCT 年度 FROM 报告信息 ORDER BY 年度 DESC"],false
				]);
			
			function onGetResult(result:ArrayCollection):void
			{				
				list.removeAll();
				
				list.addItem("所有年度");
				
				for each(var item:Object in result)
				{
					list.addItem(item.年度);
				}
			}
		}
	}
}