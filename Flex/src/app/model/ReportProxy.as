package app.model
{
	import app.ApplicationFacade;
	import app.controller.WebServiceCommand;
	import app.model.vo.ReportVO;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class ReportProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "ReportProxy";
		
		public function ReportProxy()
		{
			super(NAME, new ArrayCollection);
		}
		
		public function get list():ArrayCollection
		{
			return data as ArrayCollection;
		}
				
		public function refresh(whereClause:String,pageIndex:Number = 1,pageSize:Number = 20):void
		{			
			var sql:String = "SELECT * FROM " + WebServiceCommand.VIEW_REPORT;
			if(whereClause != "")
				sql += " WHERE " + whereClause;
			
			//if((dateBegin != "") && (dateEnd != ""))
			//	sql += " WHERE 受理日期  <= #" + dateEnd + "# AND 受理日期 >= #" + dateBegin + "#";
			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["GetReportCount",onGetReportCount
					,[sql]
				]);
			
			function onGetReportCount(result:Number):void
			{				
				var pageCount:Number = Math.ceil(result / pageSize);
				
				sendNotification(ApplicationFacade.NOTIFY_REPORT_PAGECOUNT,pageCount);
				
				sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
					["GetReport",onGetReport
						,[sql,pageIndex,pageSize]
					]);
			}
			
			function onGetReport(result:ArrayCollection):void
			{				
				list.removeAll();
				
				//var arr:ArrayCollection = new ArrayCollection
				for each(var item:Object in result)
				{
					list.addItem(new ReportVO(item));
				}
				//arr.filterFunction = filterFunction;
				//arr.refresh();
				
				//setData(arr);
				
				//handleFunction();
			}
		}
				
		public function filter(whereClause:String,pageIndex:Number = 1,pageSize:Number = 20):void
		{			
			var sql:String = "SELECT * FROM " + WebServiceCommand.VIEW_REPORT;
			if(whereClause != "")
				sql += " WHERE " + whereClause;
			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["GetReport",onGetReport
					,[sql,pageIndex,pageSize]
				]);
			
			function onGetReport(result:ArrayCollection):void
			{				
				list.removeAll();
				
				//var arr:ArrayCollection = new ArrayCollection
				for each(var item:Object in result)
				{
					list.addItem(new ReportVO(item));
				}
				//arr.filterFunction = filterFunction;
				//arr.refresh();
				
				//setData(arr);
				
				//handleFunction();
			}
		}
		
		public function refreshReport(report:ReportVO,resultHandle:Function):void
		{
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["GetTable",onGetTabelResult
					,[
						"SELECT * FROM " + WebServiceCommand.VIEW_REPORT + " WHERE " +
						"年度  = '" + report.year +
						"' AND 类别  = " + report.type +
						" AND 编号 = " + report.no +
						" AND 次级编号  = 0"
					]
				]);	
			
			function onGetTabelResult(result:ArrayCollection):void
			{
				if(result.length == 1)
				{					
					report.copy(result[0]);
					
					resultHandle();
				}
			}
		}
	}
}