package app.view
{
	import app.ApplicationFacade;
	import app.model.LoginProxy;
	import app.model.dict.GroupDict;
	import app.model.dict.ReportStatusDict;
	import app.view.components.PopupStatis;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.formatters.DateTimeFormatter;
	
	public class PopupStatisMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupStatisMediator";
				
		public function PopupStatisMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			popupStatis.addEventListener(FlexEvent.CREATION_COMPLETE,onCreation);	
		}
		
		protected function get popupStatis():PopupStatis
		{
			return viewComponent as PopupStatis;
		}
		
		private function onCreation(event:FlexEvent):void
		{						
			sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGSHOW,"正在查询数据...")
			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_CREATE);
			
			popupStatis.view1.removeAllElements();
			
			popupStatis.view1.addElement(facade.retrieveMediator(NaviStatisCountMediator.NAME).getViewComponent() as IVisualElement);
			popupStatis.view1.addElement(facade.retrieveMediator(NaviStatisTimeMediator.NAME).getViewComponent() as  IVisualElement);
			popupStatis.view1.addElement(facade.retrieveMediator(NaviStatisPrintMediator.NAME).getViewComponent() as  IVisualElement);
			popupStatis.view1.addElement(facade.retrieveMediator(NaviStatisPrintCountMediator.NAME).getViewComponent() as  IVisualElement);
			
			var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			if(loginProxy.checkRight("缴费"))
			{
				popupStatis.view1.addElement(facade.retrieveMediator(NaviStatisCashMediator.NAME).getViewComponent() as  IVisualElement);
			}
			
			popupStatis.view1.addElement(facade.retrieveMediator(NaviStatisRankMediator.NAME).getViewComponent() as  IVisualElement);
			
			popupStatis.view1.selectedIndex = 0;
			
			sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGHIDE)
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
					if(notification.getBody()[0] == popupStatis)
					{
						onCreation(null);
					}
					break;
			}
		}
	}
}