package app.view
{
	import app.AppEvent;
	import app.ApplicationFacade;
	import app.model.LoginProxy;
	import app.model.UserProxy;
	import app.model.dict.GroupDict;
	import app.model.dict.RightDict;
	import app.model.dict.RoleDict;
	import app.model.vo.UserVO;
	import app.view.components.NaviManageUser;
	import app.view.components.PopupSysManager;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.IVisualElement;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.components.Group;
	
	public class PopupSysManagerMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupSysManagerMediator";
						
		public function PopupSysManagerMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			popupSysMananger.addEventListener(FlexEvent.CREATION_COMPLETE,onCreation);			
		}
		
		protected function get popupSysMananger():PopupSysManager
		{
			return viewComponent as PopupSysManager;
		}
		
		private function onCreation(event:FlexEvent):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_CREATE);
			
			popupSysMananger.view1.removeAllElements();
			
			popupSysMananger.view1.addElement(facade.retrieveMediator(NaviManagePasswordMediator.NAME).getViewComponent() as  IVisualElement);
			
			var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			if(loginProxy.checkRight("用户管理"))
			{
				popupSysMananger.view1.addElement(facade.retrieveMediator(NaviManageUserMediator.NAME).getViewComponent() as  IVisualElement);
				popupSysMananger.view1.addElement(facade.retrieveMediator(NaviManageRoleMediator.NAME).getViewComponent() as  IVisualElement);
				popupSysMananger.view1.addElement(facade.retrieveMediator(NaviManageBackupMediator.NAME).getViewComponent() as  IVisualElement);
				popupSysMananger.view1.addElement(facade.retrieveMediator(NaviManageDataMediator.NAME).getViewComponent() as  IVisualElement);
			}
			
			popupSysMananger.view1.selectedIndex = 0;
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
					if((notification.getBody()[0] == popupSysMananger)
						&& (popupSysMananger.initialized))
					{
						onCreation(null);
					}
					break;
			}
		}
	}
}