package app.view
{
	import app.ApplicationFacade;
	import app.model.LoginProxy;
	import app.model.ReportProxy;
	import app.model.ReportYearProxy;
	import app.model.dict.GroupDict;
	import app.model.dict.ReportStatusDict;
	import app.model.vo.ReportVO;
	import app.view.components.MainPanel;
	import app.view.components.subComponents.BaseCheckBox;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.components.Group;
	import spark.formatters.DateTimeFormatter;
	
	public class MainPanelMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "MainPanelMediator";
		
		private var loginProxy:LoginProxy;
		private var reportProxy:ReportProxy;
		private var reportYearProxy:ReportYearProxy;
		
		public function MainPanelMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			facade.registerMediator(new ToolBarMessageMediator(mainPanel.toolbarMessage));
			
			mainPanel.addEventListener(MainPanel.CASEACCEPT,onCaseAccept);
			mainPanel.addEventListener(MainPanel.FEEDBACK,onFeedback);
			mainPanel.addEventListener(MainPanel.CASESTATIS,onCaseStatis);
			mainPanel.addEventListener(MainPanel.SYSMANAGER,onSysManager);
			mainPanel.addEventListener(MainPanel.EXIT,onExit);
						
			mainPanel.addEventListener(MainPanel.REPORTFILTER,onReportFilter);
			mainPanel.addEventListener(MainPanel.REPORTSEARCH,onReportSearch);
			
			mainPanel.addEventListener(MainPanel.REPORTBACK,onReportBack);
			mainPanel.addEventListener(MainPanel.REPORTCANCEL,onReportCancel);
			
			mainPanel.addEventListener(MainPanel.REPORTINFO,onReportInfo);
			
			mainPanel.addEventListener(MainPanel.REPORTFINANCIAL,onReportFinancial);
			mainPanel.addEventListener(MainPanel.REPORTCONSULT,onReportConsult);
			mainPanel.addEventListener(MainPanel.REPORTPRINT,onReportPrint);
			mainPanel.addEventListener(MainPanel.REPORTFIRSTEXAMINE,onReportFirstExamine);
			mainPanel.addEventListener(MainPanel.REPORTLASTEXAMINE,onReportLastExamine);
			mainPanel.addEventListener(MainPanel.REPORTREVISION,onReportRevision);
			mainPanel.addEventListener(MainPanel.REPORTBINDING,onReportBinding);
			mainPanel.addEventListener(MainPanel.REPORTSIGN,onReportSign);
			mainPanel.addEventListener(MainPanel.REPORTSEND,onReportSend);
			mainPanel.addEventListener(MainPanel.REPORTFILE,onReportFile);
			mainPanel.addEventListener(MainPanel.REPORTFEEDBACK,onReportFeedback);
			
			mainPanel.addEventListener(MainPanel.PRINTACCEPT,onPrintAccept);
			mainPanel.addEventListener(MainPanel.PRINTFINANCIAL,onPrintFinancial);
			
			reportYearProxy = facade.retrieveProxy(ReportYearProxy.NAME) as ReportYearProxy;
			reportProxy = facade.retrieveProxy(ReportProxy.NAME) as ReportProxy;
			loginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
		}
		
		protected function get mainPanel():MainPanel
		{
			return viewComponent as MainPanel;
		}
				
		private function onCaseAccept(event:Event):void
		{
			sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
				,[facade.retrieveMediator(PopupCaseAcceptanceMediator.NAME).getViewComponent()]);
		}
		
		private function onFeedback(event:Event):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
				,[facade.retrieveMediator(PopupFeedbackMediator.NAME).getViewComponent()]);
		}
		
		private function onCaseStatis(event:Event):void
		{
			sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
				,[facade.retrieveMediator(PopupStatisMediator.NAME).getViewComponent()]);
		}
		
		private function onSysManager(event:Event):void
		{
			sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
				,[facade.retrieveMediator(PopupSysManagerMediator.NAME).getViewComponent()]);
		}
		
		private function onExit(event:Event):void
		{
			sendNotification(ApplicationFacade.NOTIFY_MENU_EXIT);
		}
		
		private function onReportFilter(event:Event):void
		{						
			reportProxy.list.refresh();
		}
				
		private function onReportSearch(event:Event):void
		{				
			reportProxy.refresh(mainPanel.sDateBegin,mainPanel.sDateEnd,filterFunction,handleFunction);
			
			function handleFunction():void
			{
				mainPanel.gridReport.dataProvider = reportProxy.list;
			}
		}
		
		private function filterFunction(item:ReportVO):Boolean
		{			
			for each(var group:GroupDict in mainPanel.dataGroupGroup.dataProvider)
			{
				if((item.Group.label == group.label) && (!group.selected))
					return false;
			}
			
			for each(var reportStatus:ReportStatusDict in mainPanel.dataGroupStatus.dataProvider)
			{
				if((item.ReportStatus.label == reportStatus.label) && (!reportStatus.selected))
					return false;
			}
			
			return (!mainPanel.checkFilter.selected || loginProxy.checkReport(item) || (loginProxy.checkRight("缴费") && (item.ReportStatus.label != "重新受理")))
				&& (!mainPanel.checkFeedback.selected || (item.feedbackNum != ""))
				&& (((mainPanel.checkDebt.checked == BaseCheckBox.SELECTED) && (item.Paydebt > 0)) || ((mainPanel.checkDebt.checked == BaseCheckBox.UNSELECTED) && (item.Paydebt <= 0)) || (mainPanel.checkDebt.checked == BaseCheckBox.DEFAULT))
				&& (((mainPanel.checkCommision.checked == BaseCheckBox.SELECTED) && (item.commision)) || ((mainPanel.checkCommision.checked == BaseCheckBox.UNSELECTED) && (!item.commision)) || (mainPanel.checkCommision.checked == BaseCheckBox.DEFAULT))
				&& (((mainPanel.checkBill.checked == BaseCheckBox.SELECTED) && (item.billStatus != "")) || ((mainPanel.checkBill.checked == BaseCheckBox.UNSELECTED) && (item.billStatus == "")) || (mainPanel.checkBill.checked == BaseCheckBox.DEFAULT))
				&& (item.SubNo.indexOf(mainPanel.textNo.text) >= 0)
				&& (item.checkedPeople.indexOf(mainPanel.textChechPeople.text) >= 0)
				&& ((item.unitEntrust.indexOf(mainPanel.textUnit.text) >= 0)
					|| ((item.unitEntrust == "") && mainPanel.textUnit.text.indexOf("缺委托书") >= 0))
				&& (item.unitPeople.indexOf(mainPanel.textPeople.text) >= 0);
		}
		
		private function onReportBack(event:Event):void
		{
			var report:ReportVO = mainPanel.gridReport.selectedItem as ReportVO;
			
			if(report != null)
			{				
				sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
					,[facade.retrieveMediator(PopupBackResonMediator.NAME).getViewComponent(),report,true]);				
			}
		}
		
		private function onReportCancel(event:Event):void
		{
			var report:ReportVO = mainPanel.gridReport.selectedItem as ReportVO;
			
			if(report != null)
			{				
				sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
					,[facade.retrieveMediator(PopupCancelResonMediator.NAME).getViewComponent(),report,true]);				
			}
		}
		
		private function onReportInfo(event:Event):void
		{
			var report:ReportVO = mainPanel.gridReport.selectedItem as ReportVO;
			
			if(report != null)
			{
				sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
					,[facade.retrieveMediator(PopupCaseAcceptanceMediator.NAME).getViewComponent(),report]);				
			}
		}
				
		private function onReportFinancial(event:Event):void
		{
			var report:ReportVO = mainPanel.gridReport.selectedItem as ReportVO;
			
			if((report != null) && loginProxy.checkRight("缴费"))
			{
				sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
					,[facade.retrieveMediator(PopupFinancialMediator.NAME).getViewComponent(),report]);				
			}
		}
		
		private function onReportConsult(event:Event):void
		{
			var report:ReportVO = mainPanel.gridReport.selectedItem as ReportVO;
			
			if(report != null)
			{
				sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
					,[facade.retrieveMediator(PopupConsultMediator.NAME).getViewComponent(),report]);				
			}			
		}
		
		private function onReportPrint(event:Event):void
		{
			var report:ReportVO = mainPanel.gridReport.selectedItem as ReportVO;
			
			if(report != null)
			{
				sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
					,[facade.retrieveMediator(PopupPrintMediator.NAME).getViewComponent(),report]);				
			}
		}
		
		private function onReportFirstExamine(event:Event):void
		{
			var report:ReportVO = mainPanel.gridReport.selectedItem as ReportVO;
			
			if(report != null)
			{
				sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
					,[facade.retrieveMediator(PopupFirstExamineMediator.NAME).getViewComponent(),report]);				
			}
		}
		
		private function onReportLastExamine(event:Event):void
		{
			var report:ReportVO = mainPanel.gridReport.selectedItem as ReportVO;
			
			if(report != null)
			{
				sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
					,[facade.retrieveMediator(PopupLastExamineMediator.NAME).getViewComponent(),report]);				
			}
		}
		
		private function onReportRevision(event:Event):void
		{
			var report:ReportVO = mainPanel.gridReport.selectedItem as ReportVO;
			
			if(report != null)
			{
				sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
					,[facade.retrieveMediator(PopupRevisionMediator.NAME).getViewComponent(),report]);				
			}
		}
		
		private function onReportBinding(event:Event):void
		{
			var report:ReportVO = mainPanel.gridReport.selectedItem as ReportVO;
			
			if(report != null)
			{				
				sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
					,[facade.retrieveMediator(PopupBindingMediator.NAME).getViewComponent(),report]);				
			}
		}
		
		private function onReportSign(event:Event):void
		{
			var report:ReportVO = mainPanel.gridReport.selectedItem as ReportVO;
			
			if(report != null)
			{				
				sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
					,[facade.retrieveMediator(PopupSignMediator.NAME).getViewComponent(),report]);				
			}
		}
		
		private function onReportSend(event:Event):void
		{
			var report:ReportVO = mainPanel.gridReport.selectedItem as ReportVO;
			
			if(report != null)
			{
				sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
					,[facade.retrieveMediator(PopupSendMediator.NAME).getViewComponent(),report]);				
			}
		}
		
		private function onReportFile(event:Event):void
		{
			var report:ReportVO = mainPanel.gridReport.selectedItem as ReportVO;
			
			if(report != null)
			{
				sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
					,[facade.retrieveMediator(PopupFileMediator.NAME).getViewComponent(),report]);				
			}
		}
				
		private function onReportFeedback(event:Event):void
		{
			var report:ReportVO = mainPanel.gridReport.selectedItem as ReportVO;
			
			if(report != null)
			{
				sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
					,[facade.retrieveMediator(PopupFeedbackInfoMediator.NAME).getViewComponent(),report]);				
			}			
		}
		
		private function onPrintAccept(event:Event):void
		{
			var dataPro:ArrayCollection = new ArrayCollection;
			for each(var item:ReportVO in mainPanel.gridReport.dataProvider)
			{
				if(item.ReportStatus.label != "重新受理")
				{
					dataPro.addItem(item);
				}
			}
			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
				,[facade.retrieveMediator(PopupPrintSignMediator.NAME).getViewComponent(),dataPro]);	
		}
		
		private function onPrintFinancial(event:Event):void
		{
			var dataPro:ArrayCollection = new ArrayCollection;
			for each(var item:ReportVO in mainPanel.gridReport.dataProvider)
			{
				if(item.ReportStatus.label != "重新受理")
				{
					dataPro.addItem(item);
				}
			}
			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_SHOW
				,[facade.retrieveMediator(PopupPrintFinancialMediator.NAME).getViewComponent(),dataPro]);	
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				ApplicationFacade.NOTIFY_APP_INIT,
				ApplicationFacade.NOTIFY_LOGIN_SUCCESS,
				ApplicationFacade.NOTIFY_REPORT_REFRESH
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{		
				case ApplicationFacade.NOTIFY_APP_INIT:				
					reportYearProxy.refresh();			
					break;
				
				case ApplicationFacade.NOTIFY_REPORT_REFRESH:
					onReportSearch(null);
					break;
				
				case ApplicationFacade.NOTIFY_LOGIN_SUCCESS:					
					if(!loginProxy.checkRight("跟踪反馈"))						
					{
						if(mainPanel.menu.containsElement(mainPanel.btnFeedback))
							mainPanel.menu.removeElement(mainPanel.btnFeedback);
					}
					else
					{
						if(!mainPanel.menu.containsElement(mainPanel.btnFeedback))
							mainPanel.menu.addElementAt(mainPanel.btnFeedback,0);
					}
					
					if(!loginProxy.checkRight("受理"))
					{
						if(mainPanel.menu.containsElement(mainPanel.btnCaseAccept))
							mainPanel.menu.removeElement(mainPanel.btnCaseAccept);
						
						if(mainPanel.panelHead.containsElement(mainPanel.panelAccept))
							mainPanel.panelHead.removeElement(mainPanel.panelAccept);
					}
					else
					{
						if(!mainPanel.menu.containsElement(mainPanel.btnCaseAccept))
							mainPanel.menu.addElementAt(mainPanel.btnCaseAccept,0);
						
						if(!mainPanel.panelHead.containsElement(mainPanel.panelAccept))
							mainPanel.panelHead.addElement(mainPanel.panelAccept);
					}
					
					if(!loginProxy.checkRight("缴费"))
					{
						if(mainPanel.panelHead.containsElement(mainPanel.panelFinancial))
							mainPanel.panelHead.removeElement(mainPanel.panelFinancial);
					}
					else
					{
						if(!mainPanel.panelHead.containsElement(mainPanel.panelFinancial))
							mainPanel.panelHead.addElement(mainPanel.panelFinancial);
					}
					
					mainPanel.checkFilter.selected = true;
																			
					mainPanel.comboYear.dataProvider = reportYearProxy.list;
					mainPanel.comboYear.selectedIndex = 1;
					
					var arr:ArrayCollection = new ArrayCollection;
					for(var i:Number = 1;i < reportYearProxy.list.length;i++)
						arr.addItem(reportYearProxy.list[i]);
					mainPanel.comboMonthYear.dataProvider = arr;
					mainPanel.comboMonthYear.selectedIndex = 0;
					mainPanel.comboMonth.selectedIndex = (new Date).month;
								
					arr = new ArrayCollection;
					for each(var group:GroupDict in GroupDict.list)
					{
						arr.addItem(new GroupDict(group.id,group.label));
					}
					mainPanel.dataGroupGroup.dataProvider = arr;
					
					arr = new ArrayCollection;
					for each(var reportStatus:ReportStatusDict in ReportStatusDict.list)
					{
						arr.addItem(new ReportStatusDict(reportStatus.id,reportStatus.label));
					}
					mainPanel.dataGroupStatus.dataProvider = arr;
					
					reportProxy.refresh(mainPanel.sDateBegin,mainPanel.sDateEnd,filterFunction,handleFunction);
															
					mainPanel.textNo.text = "";
					mainPanel.textUnit.text = "";
					mainPanel.textPeople.text = "";
					break;
			}
			
			function handleFunction():void
			{
				mainPanel.gridReport.dataProvider = reportProxy.list;
			}
		}
	}
}