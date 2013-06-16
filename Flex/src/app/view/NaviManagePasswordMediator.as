package app.view
{
	import app.ApplicationFacade;
	import app.model.LoginProxy;
	import app.view.components.NaviManagePassword;
	
	import flash.events.Event;
		
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class NaviManagePasswordMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "NaviManagePasswordMediator";
		
		public function NaviManagePasswordMediator(viewComponent:Object = null)
		{
			super(NAME, viewComponent);
			
			naviManagePassword.addEventListener(NaviManagePassword.CLOSE,onClose);
			naviManagePassword.addEventListener(NaviManagePassword.EDITPASSWORD,onEditPassword);
		}
		
		protected function get naviManagePassword():NaviManagePassword
		{
			return viewComponent as NaviManagePassword;
		}
		
		private function onClose(event:Event):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
		}
		
		private function onEditPassword(event:Event):void
		{			
			if(naviManagePassword.textNewPassword.text != naviManagePassword.textConPassword.text)
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,"新密码和确认密码不一致。");
			}
			else
			{
				var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
				loginProxy.editPassword(naviManagePassword.textOldPassword.text,naviManagePassword.textNewPassword.text);
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
					if(notification.getBody()[0] == facade.retrieveMediator(PopupSysManagerMediator.NAME).getViewComponent()
						&& naviManagePassword.initialized)
					{												
						naviManagePassword.textOldPassword.text = "";
						naviManagePassword.textNewPassword.text = "";
						naviManagePassword.textConPassword.text = "";
					}
					break;
			}
		}
	}
}