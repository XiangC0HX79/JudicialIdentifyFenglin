package app.view
{
	import app.ApplicationFacade;
	import app.controller.WebServiceCommand;
	import app.model.dict.AcceptAddressDict;
	import app.model.vo.ReportVO;
	import app.view.components.PopupPrintFinancial;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ISort;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.collections.Sort;
	
	public class PopupPrintFinancialMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupPrintFinancialMediator";
		
		public function PopupPrintFinancialMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			popupPrintFinancial.addEventListener(PopupPrintFinancial.DOWNLOADPAYAMOUNT,onDownloadPayAmount);
			popupPrintFinancial.addEventListener(PopupPrintFinancial.DOWNLOADPAYREFUND,onDownloadPayRefund);
			popupPrintFinancial.addEventListener(PopupPrintFinancial.DOWNLOADCOMMISSION,onDownloadCommission);
			popupPrintFinancial.addEventListener(PopupPrintFinancial.DOWNLOADPAYTYPE,onDownloadPayType);
			popupPrintFinancial.addEventListener(PopupPrintFinancial.DOWNLOADBILL,onDownloadBill);
			
			popupPrintFinancial.addEventListener(PopupPrintFinancial.CLOSE,onClose);
		}
		
		protected function get popupPrintFinancial():PopupPrintFinancial
		{
			return viewComponent as PopupPrintFinancial;
		}
		
		private function onIOError(event:IOErrorEvent):void
		{
			sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGHIDE);		
			
			sendNotification(ApplicationFacade.NOTIFY_APP_ALERTERROR,"文件传输失败。");	
		}	
		
		private function onDownloadPayAmount(event:Event):void
		{				
			download("缴费_金额统计表");
		}
		
		private function onDownloadCommission(event:Event):void
		{				
			download("缴费_返佣统计表");
		}
		
		private function onDownloadPayRefund(event:Event):void
		{					
			download("缴费_欠费统计表");
		}
		
		private function onDownloadPayType(event:Event):void
		{					
			download("缴费_缴费方式统计表");
		}
		
		private function onDownloadBill(event:Event):void
		{					
			download("缴费_开票收款明细表");
		}		
		
		private function download(name:String):void
		{
			var index:Number = 0;
			
			var sort:ISort = new Sort;
			
			var url:String =  WebServiceCommand.WSDL + "PrintTable.aspx";
			url += "?file=" + name;	
			
			var data:String = "";
			if(name == "缴费_金额统计表")
			{
				sort.compareFunction = sortUnitFunction;
				popupPrintFinancial.dataPro.sort = sort;
				if(popupPrintFinancial.dataPro.refresh())
				{					
					index = 0;
					
					for each(var item:ReportVO in popupPrintFinancial.dataPro)
					{
						if(item.selected)
						{
							data += (++index) + "/C/";
							data += item.ShortNO + "/C/";
							data += ((item.acceptDate == null)?"":popupPrintFinancial.dateF.format(item.acceptDate)) + "/C/";
							data += item.unitEntrust + "/C/";
							data += item.checkedPeople + "/C/";
							data += item.payAmount + "/C/";
							data += item.paidAmount + "/C/";
							data += ((item.payLastDate == null)?"":popupPrintFinancial.dateF.format(item.payLastDate)) + "/C/";
							data += "/C/";
							data += item.unitPeople + "/C/";
							data += item.unitContact + "/R/";
						}
					}
				}
			}
			else if(name == "缴费_欠费统计表")
			{
				for each(var acceptAddress:AcceptAddressDict in AcceptAddressDict.list)
				{
					index = 1;
					
					for each(item in popupPrintFinancial.dataPro)
					{
						if((item.selected) && (item.Paydebt > 0)  && (item.ReportStatus.label != "案件取消") && (item.AccepterAddress.id == acceptAddress.id))
						{
							index++;
							
							data += item.ShortNO + "/C/";
							data += ((item.acceptDate == null)?"":popupPrintFinancial.dateF.format(item.acceptDate)) + "/C/";
							data += item.checkedPeople + "/C/";
							data += item.payAmount + "/C/";
							data += item.paidAmount + "/C/";
							data += item.Paydebt + "/C/";
							data += item.Group.label + "/C/";
							data += item.billNo + "/C/";
							data += item.unitEntrust + "/C/";
							data += item.unitPeople + "/C/";
							data += item.unitContact + "/R/";
						}
					}
					
					data += "总计/C/";
					data += "/C/";
					data += "/C/";
					data += (index > 1)?"=SUM(D2:D" + index + ")/C/":"/C/";
					data += (index > 1)?"=SUM(E2:E" + index + ")/C/":"/C/";
					data += (index > 1)?"=SUM(F2:F" + index + ")/C/":"/C/";
					data += "/R/";
					
					data += "/P/";
				}
			}
			else if(name == "缴费_返佣统计表")
			{
				sort.compareFunction = sortUnitFunction;
				popupPrintFinancial.dataPro.sort = sort;
				if(popupPrintFinancial.dataPro.refresh())
				{			
					for each(acceptAddress in AcceptAddressDict.list)
					{
						index = 0;
						
						for each(item in popupPrintFinancial.dataPro)
						{
							if((item.selected) && (item.AccepterAddress.id == acceptAddress.id) && item.commision)
							{
								data += (++index) + "/C/";
								data += item.ShortNO + "/C/";
								data += ((item.acceptDate == null)?"":popupPrintFinancial.dateF.format(item.acceptDate)) + "/C/";
								data += item.unitEntrust + "/C/";
								data += item.checkedPeople + "/C/";
								data += item.payAmount + "/C/";
								data += item.paidAmount + "/C/";
								data += ((item.payLastDate == null)?"":popupPrintFinancial.dateF.format(item.payLastDate)) + "/C/";
								data += ((item.payLastDate == null)?"":(item.payAmount - item.paidAmount)) + "/C/";
								data += (item.commision?"是":"否") + "/C/";
								data += item.commisionAmount + "/C/";
								data += item.unitPeople + "/C/";
								data += item.unitContact + "/R/";
							}
						}
						
						if(index == 0)
							data += "/C/" + "/R/" + "/P/";
						else
							data += "/P/";
						
						index = 0;
						
						for each(item in popupPrintFinancial.dataPro)
						{
							if((item.selected) && (item.AccepterAddress.id == acceptAddress.id) && (!item.commision))
							{
								data += (++index) + "/C/";
								data += item.ShortNO + "/C/";
								data += ((item.acceptDate == null)?"":popupPrintFinancial.dateF.format(item.acceptDate)) + "/C/";
								data += item.unitEntrust + "/C/";
								data += item.checkedPeople + "/C/";
								data += item.payAmount + "/C/";
								data += item.paidAmount + "/C/";
								data += ((item.payLastDate == null)?"":popupPrintFinancial.dateF.format(item.payLastDate)) + "/C/";
								data += ((item.payLastDate == null)?"":(item.payAmount - item.paidAmount)) + "/C/";
								data += (item.commision?"是":"否") + "/C/";
								data += item.commisionAmount + "/C/";
								data += item.unitPeople + "/C/";
								data += item.unitContact + "/R/";
							}
						}
						
						if(index == 0)
							data += "/C/" + "/R/" + "/P/";
						else
							data += "/P/";
					}
				}
			}
			else if(name == "缴费_缴费方式统计表")
			{	
				for each(item in popupPrintFinancial.dataPro)
				{
					if((item.selected) && (item.payType == "现金"))
					{
						data += item.ShortNO + "/C/";
						data += item.Group.label + "/C/";
						data += item.checkedPeople + "/C/";
						data += ((item.payFirstDate == null)?"":popupPrintFinancial.dateF.format(item.payFirstDate)) + "/C/";
						data += ((item.payLastDate == null)?"":popupPrintFinancial.dateF.format(item.payLastDate)) + "/C/";
						data += item.billAmount + "/C/";
						data += item.paidAmount + "/R/";
					}
				}	
				
				data += "/P/";
				
				for each(item in popupPrintFinancial.dataPro)
				{
					if((item.selected) && (item.payType == "POS机"))
					{
						data += item.ShortNO + "/C/";
						data += item.Group.label + "/C/";
						data += item.checkedPeople + "/C/";
						data += ((item.payFirstDate == null)?"":popupPrintFinancial.dateF.format(item.payFirstDate)) + "/C/";
						data += ((item.payLastDate == null)?"":popupPrintFinancial.dateF.format(item.payLastDate)) + "/C/";
						data += item.billAmount + "/C/";
						data += item.paidAmount + "/R/";
					}
				}	
				
				data += "/P/";
				
				for each(item in popupPrintFinancial.dataPro)
				{
					if((item.selected) && (item.payType == "转账"))
					{
						data += item.ShortNO + "/C/";
						data += item.Group.label + "/C/";
						data += item.checkedPeople + "/C/";
						data += ((item.payFirstDate == null)?"":popupPrintFinancial.dateF.format(item.payFirstDate)) + "/C/";
						data += ((item.payLastDate == null)?"":popupPrintFinancial.dateF.format(item.payLastDate)) + "/C/";
						data += item.billAmount + "/C/";
						data += item.paidAmount + "/R/";
					}
				}
			}
			else if(name == "缴费_开票收款明细表")
			{				
				sort.compareFunction = sortBillNoFunction;
				popupPrintFinancial.dataPro.sort = sort;
				if(popupPrintFinancial.dataPro.refresh())
				{					
					index = 1;
					
					for each(item in popupPrintFinancial.dataPro)
					{
						if((item.selected) && ((item.billStatus == "发票") || (item.billStatus == "收据")))
						{
							index++;
							
							data += item.AccepterAddress.label + "/C/";
							data += item.ShortNO + "/C/";
							data += item.unitEntrust + "/C/";
							data += item.checkedPeople + "/C/";
							data += item.billNo + "/C/";
							data += item.Group.label + "/C/";
							data += ((item.acceptDate == null)?"":popupPrintFinancial.dateF.format(item.acceptDate)) + "/C/";
							data += item.checkedPeople + "/C/";
							data += ((item.billDate == null)?"":popupPrintFinancial.dateF.format(item.billDate)) + "/C/";
							data += item.billAmount + "/C/";
							data += item.payType + "/C/";
							data += ((item.payFirstDate == null)?"":popupPrintFinancial.dateF.format(item.payFirstDate)) + "/C/";
							data += ((item.payLastDate == null)?"":popupPrintFinancial.dateF.format(item.payLastDate)) + "/C/";
							data += item.paidAmount + "/C/";
							data += "=J" + index + "-N" + index + "/R/";
						}
					}	
				}
			}
			
			if(data != "")
			{
				var downloadURL:URLRequest = new URLRequest(encodeURI(url));				
				downloadURL.method = URLRequestMethod.POST;
				downloadURL.contentType = "text/plain";	
				downloadURL.data = encodeURIComponent(data);
				
				var fileRef:FileReference = new FileReference;
				fileRef.addEventListener(Event.SELECT,onFileSelect);	
				fileRef.addEventListener(Event.CANCEL,onFileCancel);				
				fileRef.addEventListener(Event.COMPLETE,onDownloadFile);
				fileRef.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
				
				fileRef.download(downloadURL,name + ".xls");	
			}
			else
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,"请选择案件。");
			}
			
			function onFileCancel(event:Event):void
			{						
				popupPrintFinancial.dataPro.sort = null;
				popupPrintFinancial.dataPro.refresh();			
			}
			
			function onFileSelect(event:Event):void
			{						
				sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGSHOW,"正在下载《" + name + "》...");				
			}
			
			function onDownloadFile(event:Event):void 
			{							
				popupPrintFinancial.dataPro.sort = null;
				popupPrintFinancial.dataPro.refresh();
				
				sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGHIDE);	
				
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"《" + name + "》下载成功。");	
			}		
		}
		
		private function onClose(event:Event):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
		}
		
		private function sortString(a:String,b:String):int
		{
			if(a == b)
				return 0;
						
			for(var i:Number = 0;i < a.length;i++)
			{
				if(i >= b.length)
				{
					return 1;
				}
				
				var bytesA:ByteArray = new ByteArray;
				bytesA.writeMultiByte(a.toUpperCase().charAt(i), "cn-gb");
				var a1:Number = (bytesA.length == 1)?Number(bytesA[0]):Number(bytesA[0] << 8) +  bytesA[1];
				
				var bytesB:ByteArray = new ByteArray;
				bytesB.writeMultiByte(b.toUpperCase().charAt(i), "cn-gb");
				var b1:Number = (bytesB.length == 1)?Number(bytesB[0]):Number(bytesB[0] << 8) +  bytesB[1];
				
				if(a1 < b1)
				{
					return -1;
				}
				else if(a1 > b1)
				{
					return 1;
				}
			}
			
			if(a.length < b.length)
			{
				return -1;
			}
			else 
			{
				return 1;
			}
		}
		
		private function sortUnitFunction(a:ReportVO, b:ReportVO, fields:Array = null):int
		{				
			var sortUnit:Number = sortString(a.unitEntrust,b.unitEntrust);
			if(sortUnit != 0)
			{
				return sortUnit;
			}
			else
			{
				return sortString(a.unitPeople,b.unitPeople);
			}
		}
		
		private function sortBillNoFunction(a:ReportVO, b:ReportVO, fields:Array = null):int
		{				
			return sortString(a.billNo,b.billNo);
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
					if(notification.getBody()[0] == popupPrintFinancial)
					{
						var dataPro:ArrayCollection = notification.getBody()[1];
						for each(var report:ReportVO in dataPro)
							report.selected = true;
							
						popupPrintFinancial.dataPro =  dataPro;
					}
					break;
			}
		}
	}
}