package app.view
{
	import app.ApplicationFacade;
	import app.view.components.PopupBackReson;
	import app.view.components.PopupBinding;
	import app.view.components.PopupCaseAcceptance;
	import app.view.components.PopupFile;
	import app.view.components.PopupFirstExamine;
	import app.view.components.PopupLastExamine;
	import app.view.components.PopupManager;
	import app.view.components.PopupPrint;
	import app.view.components.PopupRevision;
	import app.view.components.PopupSend;
	import app.view.components.PopupSign;
	import app.view.components.PopupStatis;
	import app.view.components.PopupSysManager;
	import app.view.components.subComponents.BasePopupPanel;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class PopupManagerMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupManagerMediator";
		
		public function PopupManagerMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
		}
		
		protected function get popupManager():PopupManager
		{
			return viewComponent as PopupManager;
		}
		
		public function contain(popupPanel:BasePopupPanel):Boolean
		{
			return popupManager.content.containsElement(popupPanel);
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				ApplicationFacade.NOTIFY_POPUP_SHOW,
				ApplicationFacade.NOTIFY_POPUP_HIDE,
				ApplicationFacade.NOTIFY_POPUP_CREATE
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{
				case ApplicationFacade.NOTIFY_POPUP_SHOW:
					var params:Array = notification.getBody() as Array;
					
					if((params.length > 2) && params[2])
						popupManager.content.removeAllElements();
					
					var panel:BasePopupPanel = params[0] as BasePopupPanel;
					if(!panel.initialized)
						popupManager.content.percentHeight = Number.NaN;
					
					popupManager.content.addElement(panel);
					
					popupManager.visible = true;
					
					break;
				
				case ApplicationFacade.NOTIFY_POPUP_HIDE:				
					if(notification.getBody() == null)
					{
						popupManager.content.removeAllElements();
					}
					else
					{
						popupManager.content.removeElement(notification.getBody() as BasePopupPanel);
					}
					
					if(popupManager.content.numElements == 0)
						popupManager.visible = false;
					break;
				
				case ApplicationFacade.NOTIFY_POPUP_CREATE:
					popupManager.content.percentHeight = 100;
					break;
			}
		}
	}
}