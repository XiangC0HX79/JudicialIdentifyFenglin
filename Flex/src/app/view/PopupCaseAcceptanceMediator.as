package app.view
{
	import app.AppEvent;
	import app.ApplicationFacade;
	import app.model.AttachProxy;
	import app.model.EntrustPeopleProxy;
	import app.model.EntrustUnitProxy;
	import app.model.LoginProxy;
	import app.model.ReportProxy;
	import app.model.UserProxy;
	import app.model.dict.AcceptAddressDict;
	import app.model.dict.GroupDict;
	import app.model.dict.ReportStatusDict;
	import app.model.vo.AttachImageVO;
	import app.model.vo.PrinterVO;
	import app.model.vo.ReportVO;
	import app.model.vo.UserVO;
	import app.view.components.PopupCaseAcceptance;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	import mx.utils.StringUtil;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.components.ComboBox;
	import spark.formatters.DateTimeFormatter;
	
	public class PopupCaseAcceptanceMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupCaseAcceptanceMediator";
		
		private var preGroupIndex:Number = -1;
		private var preDate:Date;
		
		private var preUnit:String = "";
		private var prePeople:String = "";
		private var preContact:String = "";
		private var preAddressIndex:Number = 0;
		private var preAccepterType:String = "临床";
		
		private var reportProxy:ReportProxy;
		private var userProxy:UserProxy;
		private var loginProxy:LoginProxy;
		private var attachProxy:AttachProxy;
		
		public function PopupCaseAcceptanceMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			popupPanelCaseAcceptance.addEventListener(FlexEvent.CREATION_COMPLETE,onCreation);
			popupPanelCaseAcceptance.addEventListener(PopupCaseAcceptance.COMBOUNITCHANGE,onComboUnitChange);
			popupPanelCaseAcceptance.addEventListener(PopupCaseAcceptance.COMBOPEOPLECHANGE,onComboPeopleChange);
			
			popupPanelCaseAcceptance.addEventListener(PopupCaseAcceptance.SUBMIT,onSubmit);
			popupPanelCaseAcceptance.addEventListener(PopupCaseAcceptance.PRINT,onPrint);
			popupPanelCaseAcceptance.addEventListener(PopupCaseAcceptance.CONSULT,onConsult);
			popupPanelCaseAcceptance.addEventListener(PopupCaseAcceptance.CANCEL,onCancel);
			popupPanelCaseAcceptance.addEventListener(PopupCaseAcceptance.CLOSE,onClose);
						
			popupPanelCaseAcceptance.addEventListener(PopupCaseAcceptance.LISTGROUPCHANGE,listGroupChange);
			popupPanelCaseAcceptance.addEventListener(PopupCaseAcceptance.DATEACCEPTCHANGE,onDateAcceptChange);
			
			popupPanelCaseAcceptance.addEventListener(AppEvent.UPLOADATTACH,onUploadAttach);
			popupPanelCaseAcceptance.addEventListener(AppEvent.DELETEATTACH,onDeleteAttach);
			popupPanelCaseAcceptance.addEventListener(AppEvent.NAVIATTACH,onNaviImage);
			
			reportProxy = facade.retrieveProxy(ReportProxy.NAME) as ReportProxy;
			userProxy = facade.retrieveProxy(UserProxy.NAME) as UserProxy;
			loginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			attachProxy = facade.retrieveProxy(AttachProxy.NAME) as AttachProxy;
		}
		
		protected function get popupPanelCaseAcceptance():PopupCaseAcceptance
		{
			return viewComponent as PopupCaseAcceptance;
		}
				
		private function onCreation(event:FlexEvent):void
		{								
			popupPanelCaseAcceptance.maxHeight = popupPanelCaseAcceptance.height;
			
			initSubNo();
						
			initGridPrint();
			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_CREATE);
		}
		
		private function onComboUnitChange(event:Event):void
		{							
			var combo:ComboBox = popupPanelCaseAcceptance.comboEntrustUnit;
			
			var arr:ArrayCollection = combo.dataProvider as ArrayCollection;
			
			combo.dataProvider = null;
			
			var name:String = combo.textInput.text;
			if(name != "")
			{
				arr.filterFunction = roadFilterFunction;
			}
			else
			{
				arr.filterFunction = null;
			}
			arr.refresh();
			
			combo.dataProvider = arr;
			
			function roadFilterFunction(item:Object):Boolean
			{
				return (item.label.toUpperCase().indexOf(name.toUpperCase()) >= 0);
			}
		}
				
		private function onComboPeopleChange(event:Event):void
		{							
			var combo:ComboBox = popupPanelCaseAcceptance.comboEntrustPeople;
			
			var arr:ArrayCollection = combo.dataProvider as ArrayCollection;
			
			combo.dataProvider = null;
			
			var name:String = combo.textInput.text;
			if(name != "")
			{
				arr.filterFunction = roadFilterFunction;
			}
			else
			{
				arr.filterFunction = null;
			}
			arr.refresh();
			
			combo.dataProvider = arr;
			
			function roadFilterFunction(item:Object):Boolean
			{
				return (item.label.toUpperCase().indexOf(name.toUpperCase()) >= 0);
			}
		}
		
		private function createInsertSQL(type:String):String
		{
			var payAmount:Number = 0;
			/*switch(popupPanelCaseAcceptance.comboGroup.selectedIndex)
			{
				case 0:
					payAmount = 1800;
					break;
				case 1:
					payAmount = 800;
					break;
				case 2:
					payAmount = 800;
					break;
				case 3:
					payAmount = 2500;
					break;
				default:
					payAmount = 1800;
					break;
			}*/
			
			var sql:String = "INSERT INTO 报告信息 (编号,次级编号,类别,年度,受理日期,受理人,委托单位,委托单位联系方式" +
				",委托单位联系人,受检人,受检人联系方式,受理地点,案件类型,影像资料,应缴金额" +
				",受理人A,受理人B,受理人C,备注,预计报告日期,预计报告类型,打印人,案件状态) " +
				"VALUES (/NO/" + //Number(popupPanelCaseAcceptance.textReportNo.text) +  			//编号
				",0"  + 					//次级编号
				"," + popupPanelCaseAcceptance.comboGroup.selectedIndex + 					//类别
				",'" + popupPanelCaseAcceptance.textReportYear.text + "'" +				//年度
				",#" + popupPanelCaseAcceptance.dateAccept.text	+ 							//受理日期
				"#," + loginProxy.loginUser.id + 											//受理人
				",'" + StringUtil.trim(popupPanelCaseAcceptance.comboEntrustUnit.textInput.text) + //委托单位
				"','" + StringUtil.trim(popupPanelCaseAcceptance.textUnitContact.text) + 	//联系方式
				"','" + StringUtil.trim(popupPanelCaseAcceptance.comboEntrustPeople.textInput.text) + 	//委托联系人
				"','" + StringUtil.trim(popupPanelCaseAcceptance.textCheckedPeople.text) + 	//受检人
				"','" + StringUtil.trim(popupPanelCaseAcceptance.textCheckedContact.text) + //受检人联系方式
				"'," + popupPanelCaseAcceptance.comboAcceptAddress.selectedIndex + 			//受理地点
				",'" + popupPanelCaseAcceptance.comboAcceptType.selectedItem + 			//受理地点
				"'," + popupPanelCaseAcceptance.numImageCount.value + 						//影像资料
				"," + payAmount + 															//应缴金额
				//"," + popupPanelCaseAcceptance.numPaidAmount.value + 						//已缴金额
				//"," + popupPanelCaseAcceptance.numRefund.value + 							//退费金额
				//"," + popupPanelCaseAcceptance.comboBillStatus.selectedIndex + 				//开票情况
				//",'" + StringUtil.trim(popupPanelCaseAcceptance.textBillNo.text) + 			//票号
				"," + popupPanelCaseAcceptance.comboAccepterA.selectedItem.id + 			//受理人A
				"," + popupPanelCaseAcceptance.comboAccepterB.selectedItem.id + 			//受理人B
				"," + popupPanelCaseAcceptance.comboAccepterC.selectedItem.id + 			//受理人C
				",'" + StringUtil.trim(popupPanelCaseAcceptance.textRemark.text) + 			//备注
				"',#" + popupPanelCaseAcceptance.dateFinish.text + 							//预计报告日期
				"#," + popupPanelCaseAcceptance.comboFinish.selectedIndex + 				//预计报告类型
				"," + popupPanelCaseAcceptance.gridPrint.selectedItem.id;					//打印人
			
			//案件状态
			if(type == "SUBMIT")				
				sql += "," + ReportStatusDict.getItem("受理").id; 	
			else if(type == "PRINT")				
				sql += "," + ReportStatusDict.getItem("打印").id; 	
			else if(type == "CONSULT")				
				sql += "," + ReportStatusDict.getItem("会诊").id; 	
			
			sql += ")";
			
			return sql;
		}
		
		private function createUpdateSQL(type:String):String
		{
			//if(popupPanelCaseAcceptance.editable)
			//{
				var sql:String = "UPDATE 报告信息 SET "  
					+ "年度 = '" + popupPanelCaseAcceptance.textReportYear.text + "'"	
					+ ",编号 = /NO/" //+ Number(popupPanelCaseAcceptance.textReportNo.text)								
					+ ",类别 = " + popupPanelCaseAcceptance.comboGroup.selectedIndex									
					+ ",受理日期 = #" + popupPanelCaseAcceptance.dateAccept.text										
					+ "#,委托单位 = '" + StringUtil.trim(popupPanelCaseAcceptance.comboEntrustUnit.textInput.text)
					+ "',委托单位联系方式 = '" + StringUtil.trim(popupPanelCaseAcceptance.textUnitContact.text)		
					+ "',委托单位联系人 = '" + StringUtil.trim(popupPanelCaseAcceptance.comboEntrustPeople.textInput.text)	
					+ "',受检人 = '" + StringUtil.trim(popupPanelCaseAcceptance.textCheckedPeople.text)				
					+ "',受检人联系方式 = '" + StringUtil.trim(popupPanelCaseAcceptance.textCheckedContact.text)	
					+ "',受理地点 = " + popupPanelCaseAcceptance.comboAcceptAddress.selectedIndex	
					+ ",案件类型 = '" + popupPanelCaseAcceptance.comboAcceptAddress.selectedIndex			
					+ "',影像资料 = " + popupPanelCaseAcceptance.numImageCount.value	
					//+ ",应缴金额 = " + popupPanelCaseAcceptance.numPayAmount.value		
					//+ ",已缴金额 = " + popupPanelCaseAcceptance.numPaidAmount.value			
					//+ ",退费金额 = " + popupPanelCaseAcceptance.numRefund.value			
					//+ ",开票情况 = " + popupPanelCaseAcceptance.comboBillStatus.selectedIndex		
					//+ ",票号 = '" + StringUtil.trim(popupPanelCaseAcceptance.textBillNo.text)	
					+ ",受理人A = " + popupPanelCaseAcceptance.comboAccepterA.selectedItem.id	
					+ ",受理人B = " + popupPanelCaseAcceptance.comboAccepterB.selectedItem.id	
					+ ",受理人C = " + popupPanelCaseAcceptance.comboAccepterC.selectedItem.id		
					+ ",备注 = '" + StringUtil.trim(popupPanelCaseAcceptance.textRemark.text)			
					+ "',打印人 = " + popupPanelCaseAcceptance.gridPrint.selectedItem.id			
					+ ",预计报告日期 = #" + popupPanelCaseAcceptance.dateFinish.text	
					+ "#,预计报告类型 = " + popupPanelCaseAcceptance.comboFinish.selectedIndex;
				
				//案件状态
				/*if(type == "SUBMIT")				
					sql += ",案件状态  = " + ReportStatusDict.getItem("受理").id; 	
				else */if(type == "PRINT")				
					sql += ",案件状态  = " + ReportStatusDict.getItem("打印").id; 	
				else if(type == "CONSULT")				
					sql += ",案件状态  = " + ReportStatusDict.getItem("会诊").id; 	
					
				sql += " WHERE ID = " + popupPanelCaseAcceptance.report.id;
			/*}
			else
			{
				sql = "UPDATE 报告信息 SET "  
				+ "应缴金额 = " + popupPanelCaseAcceptance.numPayAmount.value		
				+ ",已缴金额 = " + popupPanelCaseAcceptance.numPaidAmount.value			
				+ ",退费金额 = " + popupPanelCaseAcceptance.numRefund.value		
				+ ",开票情况 = " + popupPanelCaseAcceptance.comboBillStatus.selectedIndex		
				+ ",票号 = '" + StringUtil.trim(popupPanelCaseAcceptance.textBillNo.text)	
				+ "' WHERE ID = " + popupPanelCaseAcceptance.report.id;						
			}*/
				
			return sql;
		}
		
		private function submitReprot(type:String):void
		{
			var isNew:Boolean = popupPanelCaseAcceptance.report.id < 0;	
			//新建案件
			if(isNew)
			{
				sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
					["SubmitCase1",onSubmitCaseResult
						,[
							popupPanelCaseAcceptance.comboGroup.selectedIndex
							,createInsertSQL(type)
							,popupPanelCaseAcceptance.dateAccept.selectedDate.fullYear
						]
					]);	
			}
			//未更换类型
			else if(popupPanelCaseAcceptance.report.type == popupPanelCaseAcceptance.comboGroup.selectedIndex)
			{
				sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
					["SubmitCase2",onSubmitCaseResult
						,[
							popupPanelCaseAcceptance.textReportNo.text,createUpdateSQL(type)
						]
					]);	
			}
			//更换类型
			else
			{
				sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
					["SubmitCase1",onSubmitCaseResult
						,[
							popupPanelCaseAcceptance.comboGroup.selectedIndex
							,createUpdateSQL(type)
							,popupPanelCaseAcceptance.dateAccept.selectedDate.fullYear
						]
					]);	
			}
			/*sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["SetTable",onSetResult
					,[
						(popupPanelCaseAcceptance.report.id < 0)?createInsertSQL(type):createUpdateSQL(type)
					]
				]);	*/
			
			function onSubmitCaseResult(result:Number):void
			{		
				popupPanelCaseAcceptance.report.type = popupPanelCaseAcceptance.comboGroup.selectedIndex;
				popupPanelCaseAcceptance.report.no = result;//Number(popupPanelCaseAcceptance.textReportNo.text);
				popupPanelCaseAcceptance.report.year = popupPanelCaseAcceptance.textReportYear.text;
					
				reportProxy.refreshReport(popupPanelCaseAcceptance.report,resultHandle);
			}
			
			function resultHandle():void
			{
				preGroupIndex = popupPanelCaseAcceptance.comboGroup.selectedIndex;
				preDate = popupPanelCaseAcceptance.dateAccept.selectedDate;
				
				preAccepterType = popupPanelCaseAcceptance.comboAcceptType.selectedItem;
				
				var entrustUnitProxy:EntrustUnitProxy = facade.retrieveProxy(EntrustUnitProxy.NAME) as EntrustUnitProxy;
				entrustUnitProxy.save(popupPanelCaseAcceptance.report,handleUnitSave);
				
				attachProxy.save(popupPanelCaseAcceptance.report);	
										
				if(isNew)
				{						
					reportProxy.list.addItemAt(popupPanelCaseAcceptance.report,0);
				}
									
				sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
				
				if(type == "SUBMIT")				
					sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"案件受理成功。")
				else if(type == "PRINT")				
					sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"案件已提交文员进行打印。");
				else if(type == "CONSULT")	
					sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"案件已提交会诊人员进行会诊。");
			}
			
			function handleUnitSave(maxID:Number):void
			{				
				var entrustPeopleProxy:EntrustPeopleProxy = facade.retrieveProxy(EntrustPeopleProxy.NAME) as EntrustPeopleProxy;
				entrustPeopleProxy.save(maxID,popupPanelCaseAcceptance.report);
								
				preUnit = popupPanelCaseAcceptance.comboEntrustUnit.textInput.text;
				prePeople = popupPanelCaseAcceptance.comboEntrustPeople.textInput.text;
				preContact = popupPanelCaseAcceptance.textUnitContact.text;
				preAddressIndex = popupPanelCaseAcceptance.comboAcceptAddress.selectedIndex;
			}
		}
		
		private function onSubmit(event:Event):void
		{			
			submitReprot("SUBMIT");
		}
				
		private function onPrint(event:Event):void
		{			
			submitReprot("PRINT");			
		}
				
		private function onConsult(event:Event):void
		{		
			if(popupPanelCaseAcceptance.report.ConsultDate != "")
			{
				sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
					,[facade.retrieveMediator(PopupConsultMediator.NAME).getViewComponent(),popupPanelCaseAcceptance.report,true]);		
			}
			else
			{
				submitReprot("CONSULT");
			}
		}
		
		private function onCancel(event:Event):void
		{						
			if(popupPanelCaseAcceptance.report.id >= 0)
			{
				sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
					,[facade.retrieveMediator(PopupCancelResonMediator.NAME).getViewComponent(),popupPanelCaseAcceptance.report,true]);	
			}
		}
		
		private function onClose(event:Event):void
		{
			sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
		}
		
		private function onDateAcceptChange(event:Event):void
		{
			initSubNo();
			
			initFinish();
		}
		
		private function onUploadAttach(event:AppEvent):void
		{
			attachProxy.uploadImage();
		}
		
		private function onDeleteAttach(event:AppEvent):void
		{
			attachProxy.deleteImage(event.data);
		}
		
		private function onNaviImage(event:AppEvent):void
		{			
			/*var attachImage:AttachImageVO = event.data as AttachImageVO;
			if(attachImage.bitmapData != null)
			{
				sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
					,[facade.retrieveMediator(PopupNaviImageMediator.NAME).getViewComponent(),attachImage.bitmapData]);	
			}*/
			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
				,[facade.retrieveMediator(PopupNaviImageMediator.NAME).getViewComponent(),popupPanelCaseAcceptance.report,popupPanelCaseAcceptance.listAttach,event.data]);	
		}
		
		private function listGroupChange(event:Event):void
		{			
			initSubNo();
			
			initFinish();
			
			initGridPrint();
		}
				
		private function initSubNo():void
		{					
			var entrustUnitProxy:EntrustUnitProxy = facade.retrieveProxy(EntrustUnitProxy.NAME) as EntrustUnitProxy;
			popupPanelCaseAcceptance.listEntrustUnit = entrustUnitProxy.getListByType(popupPanelCaseAcceptance.comboGroup.selectedIndex);
			
			var entrustPeopleProxy:EntrustPeopleProxy = facade.retrieveProxy(EntrustPeopleProxy.NAME) as EntrustPeopleProxy;
			popupPanelCaseAcceptance.listEntrustPeople = entrustPeopleProxy.list;
			
			if((popupPanelCaseAcceptance.report.no == 0)
				|| (popupPanelCaseAcceptance.report.type != popupPanelCaseAcceptance.comboGroup.selectedIndex)
				|| (popupPanelCaseAcceptance.textReportYear.text != String(popupPanelCaseAcceptance.dateAccept.selectedDate.fullYear))
				)
			{
				popupPanelCaseAcceptance.textReportYear.text = String(popupPanelCaseAcceptance.dateAccept.selectedDate.fullYear);
				
				sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
					["GetNewID",onGetNewIDResult
						,[
							popupPanelCaseAcceptance.comboGroup.selectedIndex
							,popupPanelCaseAcceptance.textReportYear.text
						]						
					]);				
			}
			else
			{
				popupPanelCaseAcceptance.textReportNo.text = popupPanelCaseAcceptance.report.SubNo;
			}
			
			function onGetNewIDResult(maxID:Number):void
			{								
				var no:String = String(maxID);
				var l:Number = no.length;
				for(var i:Number = 4; i>l ; i--)
					no = "0" + no;
				
				popupPanelCaseAcceptance.textReportNo.text = no;
			}
		}
		
		private function initFinish():void
		{			
			var finish:Number = 14;
			
			//switch(popupPanelCaseAcceptance.report.type)
			switch(popupPanelCaseAcceptance.comboGroup.selectedIndex)
			{
				case 0://残
				case 1://三
					break;
				
				case 2://伤
					finish = 7;
					break;
				
				case 3://精
					finish = 21;
					break;
			}
			
			popupPanelCaseAcceptance.dateFinish.selectedDate = new Date(popupPanelCaseAcceptance.dateAccept.selectedDate.fullYear
				,popupPanelCaseAcceptance.dateAccept.selectedDate.month
				,popupPanelCaseAcceptance.dateAccept.selectedDate.date + finish);
		}
		
		private function initGridPrint():void
		{			
			var sql:String = "SELECT A.ID,A.姓名,A.联系方式,iif(IsNull( B.打印数量 ), 0, B.打印数量 ) AS 打印数量 "
				+ "FROM [SELECT DISTINCT 用户信息.ID,用户信息.姓名,用户信息.联系方式 "
				+ "FROM 用户信息,类型用户表,用户角色表,角色表 "
				+ "WHERE 用户信息.ID = 类型用户表.用户ID  "
				+ "AND 用户信息.ID = 用户角色表.用户ID  "
				+ "AND 角色表.ID = 用户角色表.角色ID  ";
			
			if(popupPanelCaseAcceptance.comboGroup.selectedItem.label != "待定")
				sql += "AND 类型用户表.类型ID = " + popupPanelCaseAcceptance.comboGroup.selectedIndex;
			
			sql += " AND 角色表.角色 = '文员'" 
				+ " AND 用户信息.是否使用]. AS A  "
				+ "LEFT JOIN [SELECT 打印人,COUNT(*) AS 打印数量 FROM 报告信息 " 
				+ "WHERE 案件状态  = " + ReportStatusDict.getItem("打印").id 
				//+ " AND 案件状态  <> " + ReportStatusDict.getItem("重新受理").id 
				//+ " AND 案件状态  <> " + ReportStatusDict.getItem("案件取消").id 
				+ " GROUP BY 打印人]. AS B  "
				+ "ON A.ID = B.打印人";
			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["GetTable",onPrintResult
					,[sql]
				]);
						
			function onPrintResult(result:ArrayCollection):void
			{				
				var arr:ArrayCollection = new ArrayCollection;
				for each(var item:Object in result)
				{
					arr.addItem(new PrinterVO(item));
				}					
								
				var minPrint:Object = null;
				if((popupPanelCaseAcceptance.report.no == 0)
					|| (popupPanelCaseAcceptance.report.type != popupPanelCaseAcceptance.comboGroup.selectedIndex)
					|| (popupPanelCaseAcceptance.report.printer == 0))
				{
					var min:Number = 100;
					for each(var print:PrinterVO in arr)
					{
						if(print.printCount < min)
						{
							min = print.printCount;
							minPrint = print;
						}
					}					
				}
				else
				{					
					for each(print in arr)
					{
						if(print.id == popupPanelCaseAcceptance.report.printer)
						{
							minPrint = print;
							break;
						}
					}
				}
				
				popupPanelCaseAcceptance.listPrinter = arr;
				popupPanelCaseAcceptance.gridPrint.selectedItem = minPrint;
			}
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				ApplicationFacade.NOTIFY_APP_INIT,
				ApplicationFacade.NOTIFY_POPUP_SHOW
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{
				case ApplicationFacade.NOTIFY_APP_INIT:
					popupPanelCaseAcceptance.listGroup = GroupDict.list;
					
					popupPanelCaseAcceptance.listAcceptAddress = AcceptAddressDict.list;
					break;
				
				case ApplicationFacade.NOTIFY_POPUP_SHOW:
					if(notification.getBody()[0] == popupPanelCaseAcceptance)
					{
						if(notification.getBody().length > 1)
						{
							popupPanelCaseAcceptance.report = notification.getBody()[1] as ReportVO;	
							
							popupPanelCaseAcceptance.editable = loginProxy.checkReport(popupPanelCaseAcceptance.report)
								&& (popupPanelCaseAcceptance.report.ReportStatus.label == "受理");
							
							popupPanelCaseAcceptance.jurisdiction = loginProxy.checkRight("受理") 
								&& (loginProxy.loginUser.id == popupPanelCaseAcceptance.report.accepter)
								&& (popupPanelCaseAcceptance.report.ReportStatus.label != "重新受理")
								&& (popupPanelCaseAcceptance.report.ReportStatus.label != "案件取消");
						}
						else
						{
							popupPanelCaseAcceptance.report = new ReportVO;
							popupPanelCaseAcceptance.editable = true;
							
							if(preGroupIndex != -1)
							{
								popupPanelCaseAcceptance.report.type = preGroupIndex;
								
								popupPanelCaseAcceptance.comboGroup.selectedIndex = preGroupIndex;
								popupPanelCaseAcceptance.dateAccept.selectedDate = preDate;
								
								listGroupChange(null);
							}
							
							
							popupPanelCaseAcceptance.report.unitEntrust = preUnit;
							popupPanelCaseAcceptance.report.unitPeople = prePeople;
							popupPanelCaseAcceptance.textUnitContact.text = preContact;
							popupPanelCaseAcceptance.comboAcceptAddress.selectedIndex = preAddressIndex;
							popupPanelCaseAcceptance.comboAcceptType.selectedItem = preAccepterType;
						}
						
						attachProxy.refresh(popupPanelCaseAcceptance.report,AttachProxy.IMAGE,popupPanelCaseAcceptance.jurisdiction);
						
						popupPanelCaseAcceptance.listAccepterA = userProxy.listAccepterA;
						var accepterA:UserVO = userProxy.getUser(popupPanelCaseAcceptance.report.accepterA);
						popupPanelCaseAcceptance.accepterA =(accepterA != null)?accepterA:popupPanelCaseAcceptance.listAccepterA[0];
						
						popupPanelCaseAcceptance.listAccepterB = userProxy.listAccepterB;
						var accepterB:UserVO = userProxy.getUser(popupPanelCaseAcceptance.report.accepterB);
						popupPanelCaseAcceptance.accepterB = (accepterB != null)?accepterB:popupPanelCaseAcceptance.listAccepterB[0];			
						
						popupPanelCaseAcceptance.listAccepterC = userProxy.listAccepterC;
						var accepterC:UserVO = userProxy.getUser(popupPanelCaseAcceptance.report.accepterC);
						popupPanelCaseAcceptance.accepterC = (accepterC != null)?accepterC:popupPanelCaseAcceptance.listAccepterC[0];		
						
						popupPanelCaseAcceptance.listAttach = attachProxy.attach.listImage;
																		
						if(popupPanelCaseAcceptance.initialized)
						{										
							initSubNo();
							
							initGridPrint();
						}
					}
					break;
			}
		}
	}
}