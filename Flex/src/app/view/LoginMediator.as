package app.view
{
	import app.ApplicationFacade;
	import app.model.ContactPeopleProxy;
	import app.model.EntrustPeopleProxy;
	import app.model.EntrustUnitProxy;
	import app.model.LoginProxy;
	import app.model.ReportProxy;
	import app.model.ReportYearProxy;
	import app.model.UserProxy;
	import app.view.components.Login;
	
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import mx.collections.ArrayCollection;
	import mx.utils.StringUtil;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class LoginMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "LoginMediator";
		
		public function LoginMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			login.addEventListener(Login.SUBMIT,onSubmit);
			login.addEventListener(Login.EXIT,onExit);
			
			var contextMenu:ContextMenu=new ContextMenu();
			contextMenu.hideBuiltInItems(); 
			
			var contextMenuItem:ContextMenuItem=new ContextMenuItem("版本：1.3.8");			
			contextMenu.customItems.push(contextMenuItem);
			
			login.contextMenu=contextMenu;
		}
		
		protected function get login():Login
		{
			return viewComponent as Login;
		}
		
		private function onSubmit(event:Event):void
		{
			var userName:String = StringUtil.trim(login.textUserName.text);
			var passWord:String = login.textUserPassword.text;
			
			if(userName != "")
			{
				var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
				loginProxy.login(userName,passWord);
			}
			else
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,"请输入用户名。");
			}
		}
		
		private function onExit(event:Event):void
		{
			flash.net.navigateToURL(new URLRequest("javascript:window.opener=null;window.open('','_top');window.top.close()"),"_self");
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				ApplicationFacade.NOTIFY_APP_RESIZE,
				
				ApplicationFacade.NOTIFY_LOGIN_SUCCESS,
				
				ApplicationFacade.NOTIFY_MENU_EXIT
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{				
				case ApplicationFacade.NOTIFY_APP_RESIZE:
					login.back.width = notification.getBody()[0];
					login.back.height = notification.getBody()[1];
					
					login.refreshBack();
					break;
				
				case ApplicationFacade.NOTIFY_LOGIN_SUCCESS:
					login.visible = false;
					
					var entrustUnitProxy:EntrustUnitProxy = facade.retrieveProxy(EntrustUnitProxy.NAME) as EntrustUnitProxy;
					entrustUnitProxy.refresh();
					
					var entrustPeopleProxy:EntrustPeopleProxy = facade.retrieveProxy(EntrustPeopleProxy.NAME) as EntrustPeopleProxy;
					entrustPeopleProxy.refresh();
										
					var contactPeopleProxy:ContactPeopleProxy = facade.retrieveProxy(ContactPeopleProxy.NAME) as ContactPeopleProxy;
					contactPeopleProxy.refresh();
					
					var userProxy:UserProxy = facade.retrieveProxy(UserProxy.NAME) as UserProxy;					
					userProxy.refresh();
					break;
				
				case ApplicationFacade.NOTIFY_MENU_EXIT:
					login.visible = true;
					break;
			}
		}
	}
}