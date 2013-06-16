package app.model
{
	import app.ApplicationFacade;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class ContactPeopleProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "ContactPeopleProxy";
		
		public function ContactPeopleProxy()
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
					,["SELECT DISTINCT 委托单位联系人 FROM 报告信息  WHERE 委托单位联系人 <> NULL"],false
				]);
			
			function onGetResult(result:ArrayCollection):void
			{				
				list.removeAll();
				
				list.addItem("所有联系人");
				
				for each(var item:Object in result)
				{
					list.addItem(item.委托单位联系人);
				}
			}
		}
	}
}