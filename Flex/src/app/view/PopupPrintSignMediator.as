package app.view
{
	import app.ApplicationFacade;
	import app.controller.WebServiceCommand;
	import app.model.vo.ReportVO;
	import app.view.components.PopupPrintSign;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class PopupPrintSignMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupPrintSignMediator";
		
		public function PopupPrintSignMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			popupPrintSign.addEventListener(PopupPrintSign.DOWNLOADSIGN,onDownloadSign);
			popupPrintSign.addEventListener(PopupPrintSign.DOWNLOADREPORT,onDownloadReport);
			popupPrintSign.addEventListener(PopupPrintSign.CLOSE,onClose);
		}
		
		protected function get popupPrintSign():PopupPrintSign
		{
			return viewComponent as PopupPrintSign;
		}
		
		private function onIOError(event:IOErrorEvent):void
		{
			sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGHIDE);		
			
			sendNotification(ApplicationFacade.NOTIFY_APP_ALERTERROR,"文件传输失败。");	
		}	
		
		private function onDownloadSign(event:Event):void
		{				
			download("案件受理_签收单");
		}
		
		private function onDownloadReport(event:Event):void
		{				
			download("案件受理_带报告");			
		}
		
		private function download(name:String):void
		{
			var url:String =  WebServiceCommand.WSDL + "PrintTable.aspx";
			url += "?file=" + name;	
			
			var data:String = "";
			if(name == "案件受理_签收单")
			{
				for each(var item:ReportVO in popupPrintSign.dataPro)
				{
					if(item.selected)
					{
						data += item.ShortNO + "/C/";
						data += popupPrintSign.dateF.format(item.acceptDate) + "/C/";
						data += item.unitEntrust + "/C/";
						data += item.checkedPeople + "/C/";
						data += item.PayStatus + "/C/";
						data += item.unitPeople + "/C/";
						data += item.unitContact + "/R/";
					}
				}
			}
			else if(name == "案件受理_带报告")
			{
				for each(item in popupPrintSign.dataPro)
				{
					if(item.selected)
					{
						data += item.ShortNO + "/C/";
						data += popupPrintSign.dateF.format(item.acceptDate) + "/C/";
						data += item.unitEntrust + "/C/";
						data += item.checkedPeople + "/C/";
						data += item.PayStatus + "/R/";
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
				popupPrintSign.dataPro.sort = null;
				popupPrintSign.dataPro.refresh();			
			}
			
			function onFileSelect(event:Event):void
			{						
				sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGSHOW,"正在下载《" + name + "》...");				
			}
			
			function onDownloadFile(event:Event):void 
			{							
				sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGHIDE);	
				
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"《" + name + "》下载成功。");	
			}	
		}
		
		private function onClose(event:Event):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
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
					if(notification.getBody()[0] == popupPrintSign)
					{
						var dataPro:ArrayCollection = notification.getBody()[1];
						for each(var report:ReportVO in dataPro)
							report.selected = true;
							
						popupPrintSign.dataPro =  dataPro;
					}
					break;
			}
		}
	}
}