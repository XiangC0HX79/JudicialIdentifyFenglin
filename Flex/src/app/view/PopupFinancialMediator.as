package app.view
{
	import app.ApplicationFacade;
	import app.model.ReportProxy;
	import app.view.components.PopupFinancial;
	
	import flash.events.Event;
	
	import mx.events.FlexEvent;
	import mx.utils.StringUtil;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class PopupFinancialMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupFinancialMediator";
		
		public function PopupFinancialMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			popupFinancial.addEventListener(FlexEvent.CREATION_COMPLETE,onCreation);
			
			popupFinancial.addEventListener(PopupFinancial.CLOSE,onClose);
			popupFinancial.addEventListener(PopupFinancial.SUBMIT,onSubmit);
		}
		
		protected function get popupFinancial():PopupFinancial
		{
			return viewComponent as PopupFinancial;
		}
				
		private function onCreation(event:FlexEvent):void
		{								
			popupFinancial.maxHeight = popupFinancial.height;
						
			initCombo();
			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_CREATE);
		}
		
		private function initCombo():void
		{
			if(popupFinancial.report.payType == "现金")
				popupFinancial.comboPayType.selectedIndex = 1;
			else if(popupFinancial.report.payType == "POS机")
				popupFinancial.comboPayType.selectedIndex = 2;
			else if(popupFinancial.report.payType == "转账")
				popupFinancial.comboPayType.selectedIndex = 3;
			else 
				popupFinancial.comboPayType.selectedIndex = 0;
			
			if(popupFinancial.comboPayType.selectedIndex == 0)
			{
				popupFinancial.numPaidAmount.value = 0;
				popupFinancial.numRefund.value = 0;
				popupFinancial.radioCommision.selectedValue = false;
				popupFinancial.dateFirst.selectedDate = null;
				popupFinancial.dateLast.selectedDate = null;
			}
			else
			{
				popupFinancial.numPaidAmount.value = popupFinancial.report.paidAmount;
				popupFinancial.numRefund.value = popupFinancial.report.refund;
				popupFinancial.radioCommision.selectedValue = popupFinancial.report.commision;
				popupFinancial.dateFirst.selectedDate = popupFinancial.report.payFirstDate;
				popupFinancial.dateLast.selectedDate = popupFinancial.report.payLastDate;
			}
			
			if(popupFinancial.report.billStatus == "发票")
				popupFinancial.comboBillStatus.selectedIndex = 1;
			else if(popupFinancial.report.billStatus == "收据")
				popupFinancial.comboBillStatus.selectedIndex = 2;
			else
				popupFinancial.comboBillStatus.selectedIndex = 0;
			
			if(popupFinancial.comboBillStatus.selectedIndex == 0)
			{
				popupFinancial.dateBilling.selectedDate = null;
				popupFinancial.numBillAmount.value = 0;
				popupFinancial.textBillNo.text = "";
			}
			else 
			{
				popupFinancial.dateBilling.selectedDate = popupFinancial.report.billDate;
				popupFinancial.numBillAmount.value = popupFinancial.report.billAmount;
				popupFinancial.textBillNo.text = popupFinancial.report.billNo;
			}
		}
		
		private function onClose(event:Event):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
		}
				
		private function onSubmit(event:Event):void
		{			
			if(popupFinancial.comboPayType.selectedIndex == 0)
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"请选择缴费方式。");
				return;
			}
			
			if(popupFinancial.numPayAmount.value == 0)
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"请输入应缴金额。");
				return;
			}
			
			var sql:String = "UPDATE 报告信息 SET "  
				+ "缴费方式 = '" + popupFinancial.comboPayType.selectedItem + "'"
				+ ",应缴金额 = " + popupFinancial.numPayAmount.value		
				+ ",已缴金额 = " + popupFinancial.numPaidAmount.value			
				+ ",退费金额 = " + popupFinancial.numRefund.value				
				+ ",是否返佣 = " + popupFinancial.radioCommision.selectedValue				
				+ ",返佣金额 = " + popupFinancial.numCommisionAmount.value			
				+ ",开票情况 = '" + popupFinancial.comboBillStatus.selectedItem + "'"	
				+ ",票号 = '" + StringUtil.trim(popupFinancial.textBillNo.text) + "'"
				+ ",开票金额 = " + popupFinancial.numBillAmount.value;
			
			if(popupFinancial.dateBilling.selectedDate != null)
				sql += ",开票日期 = #" + popupFinancial.dateBilling.text + "#";
			else 
				sql += ",开票日期 = NULL";
			
			if(popupFinancial.dateFirst.selectedDate != null)
				sql += ",预收款日期 = #" + popupFinancial.dateFirst.text + "#";
			else 
				sql += ",预收款日期 = NULL";
			
			if(popupFinancial.dateLast.selectedDate != null)
				sql += ",尾款日期 = #" + popupFinancial.dateLast.text + "#";
			else 
				sql += ",尾款日期 = NULL";
			
			sql += "  WHERE ID = " + popupFinancial.report.id;
			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["SetTable",onSetResult
					,[sql]
				]);	
			
			function onSetResult(result:Number):void
			{			
				var reportProxy:ReportProxy = facade.retrieveProxy(ReportProxy.NAME) as ReportProxy;
				reportProxy.refreshReport(popupFinancial.report,resultHandle);
			}
			
			function resultHandle():void
			{										
				sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
				
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"案件《" + popupFinancial.report.FullNO + "》缴费信息修改成功。");	
			}
		}
		
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
					if(notification.getBody()[0] == popupFinancial)
					{						
						popupFinancial.report = notification.getBody()[1];
						
						if(popupFinancial.initialized)
							initCombo();
					}
					break;
			}
		}
	}
}