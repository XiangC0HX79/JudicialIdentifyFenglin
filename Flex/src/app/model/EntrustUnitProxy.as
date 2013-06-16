package app.model
{
	import app.ApplicationFacade;
	import app.model.vo.EntrustUnitVO;
	import app.model.vo.ReportVO;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class EntrustUnitProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "EntrustUnitProxy";
		
		public function EntrustUnitProxy()
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
			arr.addItemAt(EntrustUnitVO.ALL,0);
			
			return arr;
		}
		
		public function refresh():void
		{	
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["GetTable",onGetResult
					,["SELECT * FROM 委托单位 ORDER BY ID"],false
				]);
			
			function onGetResult(result:ArrayCollection):void
			{				
				list.removeAll();
				
				for each(var item:Object in result)
				{
					list.addItem(new EntrustUnitVO(item));
				}
			}
		}
		
		public function getListByType(type:Number):ArrayCollection
		{
			var arr:ArrayCollection = new ArrayCollection;
			for each(var entrustUnit:EntrustUnitVO in list)
			{
				if((type == -1) || (entrustUnit.type == type))
					arr.addItem(entrustUnit);
			}
			
			return arr;
		}
		
		public function save(report:ReportVO,handleFunction:Function):void
		{
			if(report.unitEntrust == "")
				return;
			
			for each(var entrustUnit:EntrustUnitVO in list)
			{
				if((entrustUnit.type == report.type)
					&& (entrustUnit.label == report.unitEntrust))
				{
					handleFunction(entrustUnit.id);
					return;
				}
			}
						
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["SetTable",onSetResult
					,["INSERT INTO 委托单位 (类别,单位名称) VALUES (" + report.type + ",'" + report.unitEntrust + "')"],false
				]);
			
			function onSetResult(result:Number):void
			{			
				sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
					["GetTable",onGetResult
						,["SELECT MAX(ID) AS MAXID FROM 委托单位"],false
					]);
			}
			
			function onGetResult(result:ArrayCollection):void
			{			
				handleFunction(Number(result[0].MAXID));
			}
		}
	}
}