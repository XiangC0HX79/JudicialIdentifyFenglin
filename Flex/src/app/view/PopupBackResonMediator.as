package app.view
{
	import app.ApplicationFacade;
	import app.model.LoginProxy;
	import app.model.ReportProxy;
	import app.model.UserProxy;
	import app.model.dict.ReportStatusDict;
	import app.model.vo.ReportVO;
	import app.view.components.PopupBackReson;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.formatters.DateTimeFormatter;
	
	public class PopupBackResonMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupBackResonMediator";
		
		public function PopupBackResonMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			popupBackReson.addEventListener(FlexEvent.CREATION_COMPLETE,onCreation);
			
			popupBackReson.addEventListener(PopupBackReson.CLOSE,onClose);
			popupBackReson.addEventListener(PopupBackReson.SUBMIT,onSubmit);
		}
		
		protected function get popupBackReson():PopupBackReson
		{
			return viewComponent as PopupBackReson;
		}
		
		private function onCreation(event:FlexEvent):void
		{								
			popupBackReson.maxHeight = popupBackReson.height;
			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_CREATE);
		}			
				
		private function onClose(event:Event):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
		}
		
		/*private function createInsertSQL():String
		{
			var dateF:DateTimeFormatter = new DateTimeFormatter;
			dateF.dateTimePattern = "yyyy-MM-dd";
			
			var sql:String = "INSERT INTO 报告信息 (编号,类别,年度,受理日期,受理人,委托单位,委托单位联系方式" +
				",委托单位联系人,受检人,受检人联系方式,受理地点,影像资料" +
				",受理人A,受理人B,受理人C,备注,预计报告日期,预计报告类型,打印人,案件状态" +
				",缴费方式,应缴金额,已缴金额,退费金额,是否返佣,返佣金额,开票情况,票号,开票金额) " +
				"VALUES (" + popupBackReson.report.no +  			//编号
				"," + popupBackReson.report.type + 					//类别
				",'" + popupBackReson.report.year  + "'" +				//年度
				",#" + dateF.format(popupBackReson.report.acceptDate)	+ 							//受理日期
				"#," + popupBackReson.report.accepter + 											//受理人
				",'" + popupBackReson.report.unitEntrust + //委托单位
				"','" + popupBackReson.report.unitContact + 	//联系方式
				"','" + popupBackReson.report.unitPeople + 	//委托联系人
				"','" + popupBackReson.report.checkedPeople + 	//受检人
				"','" + popupBackReson.report.checkedContact + //受检人联系方式
				"'," + popupBackReson.report.accepterAddress + 			//受理地点
				"," + popupBackReson.report.imageCount + 						//影像资料
				"," + popupBackReson.report.accepterA + 			//受理人A
				"," + popupBackReson.report.accepterB + 			//受理人B
				"," + popupBackReson.report.accepterC + 			//受理人C
				",'" + popupBackReson.report.remark + 			//备注
				"',#" + dateF.format(popupBackReson.report.finishDate) + 							//预计报告日期
				"#," + popupBackReson.report.finishType + 				//预计报告类型
				"," + popupBackReson.report.printer +					//打印人					
				"," + ReportStatusDict.getItem("受理").id +		//报告状态	
				",'" + popupBackReson.report.payType + 						//缴费方式
				"'," + popupBackReson.report.payAmount + 						//应缴金额
				"," + popupBackReson.report.paidAmount + 						//已缴金额
				"," + popupBackReson.report.refund + 						//退费金额
				"," + popupBackReson.report.refund + 						//是否返佣
				"," + popupBackReson.report.refund + 						//返佣金额
				"," + popupBackReson.report.billStatus + 				//开票情况
				",'" + popupBackReson.report.billNo + 			//票号	
				")";	
			
			return sql;
		}*/
		
		private function onSubmit(event:Event):void
		{								
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["BackCase",onBackCaseResult
					,[popupBackReson.report.no,popupBackReson.report.type,popupBackReson.report.backer,ApplicationFacade.NOW,popupBackReson.textReson.text]
				]);		
			
			function onBackCaseResult(result:Number):void
			{							
				sendNotification(ApplicationFacade.NOTIFY_REPORT_REFRESH);		
				
				sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
				
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"案件重新受理成功。");
			}
		}
			/*sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["GetTable",onGetResult
					,["SELECT MAX(次级编号) AS MAXID FROM 报告信息"
						+ " WHERE 类别 = " + popupBackReson.report.type + " AND 编号 = " + popupBackReson.report.no]
				]);
			
			var maxID:Number = 0;
			
			function onGetResult(result:ArrayCollection):void
			{							
				if(result.length > 0)
				{
					maxID = Number(result[0].MAXID);
				}
								
				sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
					["SetTable",onSetResult
						,["UPDATE 报告信息 SET 次级编号 = " + (maxID + 1)
							+ ",案件状态 = " + ReportStatusDict.getItem("重新受理").id
							+ ",退回人 = " + popupBackReson.report.backer
							+ ",退回日期 = #"+ ApplicationFacade.NOW
							+"#,退回原因 = '" + popupBackReson.textReson.text + "'"
							+ " WHERE ID = " + popupBackReson.report.id]
					]);
				
			}
			
			function onSetResult(result:Number):void
			{									
				sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
					["SetTable",onInsertResult
						,["INSERT INTO 报告信息 SELECT * FROM 报告信息 WHERE ID = " + popupBackReson.report.id]
					]);	
			}
			
			function onInsertResult(result:Number):void
			{				
				var curNo:String = popupBackReson.report.FullNO;
				
				popupBackReson.report.subNo = maxID + 1;
				
				var backNo:String = popupBackReson.report.FullNO;
				
				sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
					["BackCase",onBackCaseResult
						,[curNo,backNo]
					]);
			}
			
			function onBackCaseResult(result:String):void
			{						
				//var reportProxy:ReportProxy = facade.retrieveProxy(ReportProxy.NAME) as ReportProxy;
				//reportProxy.refresh();
				
				sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
				
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"案件重新受理成功。");
			}
		}*/
				
		override public function listNotificationInterests():Array
		{
			return [
				ApplicationFacade.NOTIFY_POPUP_SHOW
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{
				case ApplicationFacade.NOTIFY_POPUP_SHOW:
					if(notification.getBody()[0] == popupBackReson)
					{
						popupBackReson.report = notification.getBody()[1] as ReportVO;
						
						if(popupBackReson.report.ReportStatus.label == "重新受理")
						{
							popupBackReson.currentState = "VIEW";
						}
						else
						{
							popupBackReson.currentState = "EDIT";
							
							var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
							popupBackReson.report.backer = loginProxy.loginUser.id;
							popupBackReson.report.backerName = loginProxy.loginUser.name;
							popupBackReson.report.backDate = ApplicationFacade.getNow();
						}
						
						popupBackReson.backDate = popupBackReson.report.BackDate;
						
						
						/*popupBackReson.editable = notification.getBody()[2] as Boolean;
						
						if(popupBackReson.editable)
						{
							popupBackReson.report.backer = loginProxy.loginUser.id;
						}*/
						
						//var userProxy:UserProxy = facade.retrieveProxy(UserProxy.NAME) as UserProxy;
						//popupBackReson.textPrintName.text = popupBackReson.report.backerName;
						
						//popupBackReson.textPrintDate.text = ApplicationFacade.NOW;
						
						//popupBackReson.textReson.text = popupBackReson.report.backReson;
					}
					break;
			}
		}
	}
}