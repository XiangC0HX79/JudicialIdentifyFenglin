package app.controller
{
	import app.ApplicationFacade;
	import app.view.AppAlertMediator;
	
	import mx.rpc.AbstractOperation;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.Operation;
	import mx.rpc.soap.WebService;
	import mx.utils.ObjectProxy;
	
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class WebServiceCommand extends SimpleCommand implements ICommand
	{		
		public static var WSDL:String = "";
		
		public static var VIEW_REPORT:String
				= "(SELECT 报告信息.返佣金额,报告信息.开票金额,报告信息.是否返佣,报告信息.ID, 报告信息.编号, 报告信息.次级编号, 报告信息.类别, 报告信息.年度, 报告信息.受理日期, 报告信息.受理人, 受理人.姓名 AS 受理人姓名, 报告信息.委托单位, 报告信息.委托单位联系人, 报告信息.委托单位联系方式, 报告信息.受检人, 报告信息.受检人联系方式, 报告信息.受理地点, 报告信息.影像资料, 报告信息.应缴金额, 报告信息.已缴金额, 报告信息.开票情况, 报告信息.票号, 报告信息.备注, 报告信息.受理人A, 受理人A.姓名 AS 受理人A姓名, 报告信息.受理人B, 受理人B.姓名 AS 受理人B姓名, 报告信息.受理人C, 受理人C.姓名 AS 受理人C姓名, 报告信息.预计报告日期, 报告信息.预计报告类型, 报告信息.案件状态, 报告信息.分配日期, 报告信息.打印接受日期, 报告信息.打印日期, 报告信息.打印人, 打印人.姓名 AS 打印人姓名, 报告信息.初审接受日期, 报告信息.初审日期, 报告信息.初审分数, 报告信息.初审人, 初审人.姓名 AS 初审人姓名, 报告信息.复审接受日期, 报告信息.复审日期, 报告信息.复审分数, 报告信息.复审人, 复审人.姓名 AS 复审人姓名, 报告信息.修订接受日期, 报告信息.修订日期, 报告信息.装订接受日期, 报告信息.装订日期, 报告信息.装订人, 装订人.姓名 AS 装订人姓名, 报告信息.签字接受日期, 报告信息.签字日期, 报告信息.发放接受日期, 报告信息.发放状态, 报告信息.发放日期, 报告信息.签收人, 报告信息.签收日期, 报告信息.归档接受日期, 报告信息.归档日期, 报告信息.归档人, 归档人.姓名 AS 归档人姓名, 报告信息.反馈意见, 报告信息.退回人, 报告信息.退回日期, 报告信息.退回原因, 退回人.姓名 AS 退回人姓名, 报告信息.会诊接受日期, 报告信息.会诊日期, 报告信息.会诊人, 报告信息.其他会诊人, 报告信息.签字人, 报告信息.其他签字人, 视图_跟踪反馈.反馈数量, 报告信息.退费金额, 视图_受理地点.参数值 AS 受理地点名称, 报告信息.退案原因, 报告信息.开票日期, 报告信息.预收款日期, 报告信息.尾款日期, 报告信息.缴费方式, 报告信息.卡号, 报告信息.退案日期," +
					"报告信息.案件类型"
					+ " FROM (((((((((((报告信息 LEFT JOIN 用户信息 AS 受理人 ON 报告信息.受理人 = 受理人.ID) LEFT JOIN 用户信息 AS 受理人A ON 报告信息.受理人A = 受理人A.ID) LEFT JOIN 用户信息 AS 受理人B ON 报告信息.受理人B = 受理人B.ID) LEFT JOIN 用户信息 AS 受理人C ON 报告信息.受理人C = 受理人C.ID) LEFT JOIN 用户信息 AS 打印人 ON 报告信息.打印人 = 打印人.ID) LEFT JOIN 用户信息 AS 初审人 ON 报告信息.初审人 = 初审人.ID) LEFT JOIN 用户信息 AS 复审人 ON 报告信息.复审人 = 复审人.ID) LEFT JOIN 用户信息 AS 装订人 ON 报告信息.装订人 = 装订人.ID) LEFT JOIN 用户信息 AS 归档人 ON 报告信息.归档人 = 归档人.ID) LEFT JOIN 用户信息 AS 退回人 ON 报告信息.退回人 = 退回人.ID) LEFT JOIN 视图_跟踪反馈 ON 报告信息.ID = 视图_跟踪反馈.报告ID) LEFT JOIN 视图_受理地点 ON 报告信息.受理地点 = 视图_受理地点.参数ID"
					+ " ORDER BY ((Now() > DateAdd('d',-2,预计报告日期)) OR 案件状态  = 9 OR 案件状态  = 10 OR 案件状态  = 11),报告信息.ID DESC) AS 视图_报告信息";
				
		override public function execute(note:INotification):void
		{			 
			var webService:WebService = new WebService;
			webService.wsdl = WebServiceCommand.WSDL + "Service.asmx?wsdl";					
			webService.loadWSDL();
			
			var arr:Array = note.getBody() as Array;
			var opreatorName:String = arr[0];
			var resultFunction:Function = arr[1];
			var args:Array = arr[2];
			var showLoading:Boolean = (arr.length > 3)?arr[3]:true;
			var resultFormat:String = (arr.length > 4)?arr[4]:"object";
			var loadingText:String = (arr.length > 5)?arr[5]:"正在查询数据，请等待系统响应...";
			
			var operation:Operation = webService.getOperation(opreatorName) as Operation;
			operation.addEventListener(ResultEvent.RESULT,onResult);
			operation.addEventListener(FaultEvent.FAULT,onFault);
			operation.arguments = args;
			operation.resultFormat = resultFormat;
			operation.send();	
							
			if(showLoading)
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGSHOW,loadingText);
			}
			
			function onResult(event:ResultEvent):void
			{								
				if(showLoading)
				{
					sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGHIDE);
				}
				
				if(event.result == null)
					return;
				
				if(operation.resultFormat == "object")
				{
					if(event.result is ObjectProxy)
					{
						if(event.result.hasOwnProperty("Tables"))
						{
							var tables:Object = event.result.Tables;
							if(tables.hasOwnProperty("Table"))
							{
								resultFunction(tables.Table.Rows);
							}
							if(tables.hasOwnProperty("Count"))
							{
								resultFunction(tables.Count.Rows[0].Count);
							}
							else if(tables.hasOwnProperty("Error"))
							{
								if(showLoading)
								{
									sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGHIDE);
								}
								
								sendNotification(ApplicationFacade.NOTIFY_APP_ALERTERROR,tables.Error.Rows[0]["ErrorInfo"]);
							}
						}
						else
						{
							resultFunction(event.result);
						}
					}
					else //if(event.result is String)
					{
						resultFunction(event.result);
					}
				}
				else if(operation.resultFormat == "e4x")
				{
					resultFunction(XML(event.result));
				}
			}
			
			function onFault(event:FaultEvent):void
			{
				if(showLoading)
				{
					sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGHIDE);
				}
				
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTERROR,event.fault.faultString + "\n" + event.fault.faultDetail);
			}
		}
	}
}