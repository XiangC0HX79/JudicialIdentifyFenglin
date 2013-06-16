package app.view
{
	import app.ApplicationFacade;
	import app.model.LoginProxy;
	import app.model.ReportYearProxy;
	import app.model.dict.GroupDict;
	import app.view.components.NaviManageBackup;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class NaviManageBackupMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "NaviManageBackupMediator";
		
		public function NaviManageBackupMediator(viewComponent:Object = null)
		{
			super(NAME, viewComponent);
			
			naviManageBackup.addEventListener(FlexEvent.CREATION_COMPLETE,onCreation);
			
			naviManageBackup.addEventListener(NaviManageBackup.BACKUP,onBackUp);
			
			naviManageBackup.addEventListener(NaviManageBackup.CLOSE,onClose);
		}
		
		protected function get naviManageBackup():NaviManageBackup
		{
			return viewComponent as NaviManageBackup;
		}
		
		private function onClose(event:Event):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
		}
				
		private function onCreation(event:FlexEvent):void
		{								
			init();
		}			
		
		private function init():void
		{
			naviManageBackup.comboType.dataProvider = GroupDict.list;
			naviManageBackup.comboType.selectedIndex = 0;
						
			var reportYearProxy:ReportYearProxy = facade.retrieveProxy(ReportYearProxy.NAME) as ReportYearProxy;
			var arr:ArrayCollection = new ArrayCollection;
			for(var i:Number = 1;i < reportYearProxy.list.length;i++)
				arr.addItem(reportYearProxy.list[i]);
			naviManageBackup.comboYear.dataProvider = arr;
			naviManageBackup.comboYear.selectedIndex = 0;
		}
		
		private function onBackUp(event:Event):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["BackReport",onResult,
					[
						naviManageBackup.comboYear.selectedItem,
						naviManageBackup.comboMonth.selectedIndex + 1,
						naviManageBackup.comboType.selectedIndex,
						""
					]
				]);
						
			function onResult(result:String):void
			{
				if(result == "000")
				{
					sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"报告导出成功，请到服务器'D:\\司法鉴定\\WebService\\Backup'目录下拷贝！");
				}
				else
				{
					sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
						["BackReport",onResult,
							[naviManageBackup.comboYear.selectedItem,naviManageBackup.comboType.selectedIndex]
						]);
				}
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
					if((notification.getBody()[0] == facade.retrieveMediator(PopupSysManagerMediator.NAME).getViewComponent())
						&& naviManageBackup.initialized)
					{												
						init();		
					}
					break;
			}
		}
	}
}