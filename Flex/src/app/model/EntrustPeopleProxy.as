package app.model
{
	import app.ApplicationFacade;
	import app.model.vo.EntrustPeopleVO;
	import app.model.vo.ReportVO;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class EntrustPeopleProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "EntrustPeopleProxy";
		
		public function EntrustPeopleProxy()
		{
			super(NAME, new ArrayCollection);
		}
		
		public function get list():ArrayCollection
		{
			return data as ArrayCollection;
		}
		
		public function get listAll():ArrayCollection
		{
			var arr:ArrayCollection = new ArrayCollection;
			arr.addItemAt(EntrustPeopleVO.ALL,0);
			
			return arr;
		}
		
		public function refresh():void
		{	
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["GetTable",onGetResult
					,["SELECT * FROM 委托联系人 ORDER BY ID"],false
				]);
			
			function onGetResult(result:ArrayCollection):void
			{				
				list.removeAll();
				
				for each(var item:Object in result)
				{
					list.addItem(new EntrustPeopleVO(item));
				}
			}
		}
		
		public function save(unitID:Number, report:ReportVO):void
		{			
			if(report.unitPeople == "")
				return;
			
			for each(var entrustPeople:EntrustPeopleVO in list)
			{
				if((entrustPeople.unitID == unitID)
					&& (entrustPeople.label == report.unitPeople))
				{
					return;
				}
			}
			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["SetTable",onSetResult
					,["INSERT INTO 委托联系人 (姓名,联系方式,单位ID) VALUES ('" 
						+ report.unitPeople + "','" 
						+ report.unitContact + "'," 
						+ unitID + ")"],false
				]);
			
			function onSetResult(result:Number):void
			{			
				refresh();
			}
		}
	}
}