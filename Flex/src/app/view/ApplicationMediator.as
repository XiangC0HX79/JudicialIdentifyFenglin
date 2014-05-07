package app.view
{		
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Timer;
	
	import mx.controls.ToolTip;
	import mx.events.ResizeEvent;
	
	import app.ApplicationFacade;
	import app.view.components.NaviManageBackup;
	import app.view.components.NaviManageData;
	import app.view.components.NaviManagePassword;
	import app.view.components.NaviManageRole;
	import app.view.components.NaviManageUser;
	import app.view.components.NaviStatisCash;
	import app.view.components.NaviStatisCount;
	import app.view.components.NaviStatisPrint;
	import app.view.components.NaviStatisPrintCount;
	import app.view.components.NaviStatisRank;
	import app.view.components.NaviStatisTime;
	import app.view.components.PopupBackReson;
	import app.view.components.PopupBinding;
	import app.view.components.PopupCancelReson;
	import app.view.components.PopupCaseAcceptance;
	import app.view.components.PopupConsult;
	import app.view.components.PopupFeedback;
	import app.view.components.PopupFeedbackInfo;
	import app.view.components.PopupFile;
	import app.view.components.PopupFinancial;
	import app.view.components.PopupFirstExamine;
	import app.view.components.PopupLastExamine;
	import app.view.components.PopupMessage;
	import app.view.components.PopupNaviImage;
	import app.view.components.PopupPrint;
	import app.view.components.PopupPrintFinancial;
	import app.view.components.PopupPrintSign;
	import app.view.components.PopupRevision;
	import app.view.components.PopupSend;
	import app.view.components.PopupSign;
	import app.view.components.PopupStatis;
	import app.view.components.PopupSysManager;
	import app.view.components.subComponents.BasePopupPanel;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
		
	public class ApplicationMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "ApplicationMediator";
		
		public function ApplicationMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			//application.styleManager.getStyleDeclaration("mx.controls.Alert").setStyle("fontFamily",fontFamily);
			//application.styleManager.getStyleDeclaration("mx.controls.Alert").setStyle("fontSize",14);
						
			facade.registerMediator(new AppAlertMediator);
			
			facade.registerMediator(new AppLoadingBarMediator(application.appLoadingBar));
			
			facade.registerMediator(new LoginMediator(application.login));
			
			facade.registerMediator(new MainPanelMediator(application.mainPanel));
			
			facade.registerMediator(new PopupManagerMediator(application.popupManager));
			
			facade.registerMediator(new PopupCaseAcceptanceMediator(new PopupCaseAcceptance));	
			
			facade.registerMediator(new PopupFeedbackMediator(new PopupFeedback));	
			facade.registerMediator(new PopupFeedbackInfoMediator(new PopupFeedbackInfo));	
						
			facade.registerMediator(new PopupStatisMediator(new PopupStatis));
			facade.registerMediator(new NaviStatisCountMediator(new NaviStatisCount));
			facade.registerMediator(new NaviStatisTimeMediator(new NaviStatisTime));
			facade.registerMediator(new NaviStatisPrintMediator(new NaviStatisPrint));
			facade.registerMediator(new NaviStatisPrintCountMediator(new NaviStatisPrintCount));
			facade.registerMediator(new NaviStatisCashMediator(new NaviStatisCash));
			facade.registerMediator(new NaviStatisRankMediator(new NaviStatisRank));
						
			facade.registerMediator(new PopupSysManagerMediator(new PopupSysManager));			
			facade.registerMediator(new NaviManagePasswordMediator(new NaviManagePassword));			
			facade.registerMediator(new NaviManageUserMediator(new NaviManageUser));			
			facade.registerMediator(new NaviManageRoleMediator(new NaviManageRole));
			facade.registerMediator(new NaviManageBackupMediator(new NaviManageBackup));	
			facade.registerMediator(new NaviManageDataMediator(new NaviManageData));
			
			facade.registerMediator(new PopupFinancialMediator(new PopupFinancial));	
			
			facade.registerMediator(new PopupConsultMediator(new PopupConsult));	
			
			facade.registerMediator(new PopupPrintMediator(new PopupPrint));
			
			facade.registerMediator(new PopupFirstExamineMediator(new PopupFirstExamine));
			
			facade.registerMediator(new PopupLastExamineMediator(new PopupLastExamine));
			
			facade.registerMediator(new PopupRevisionMediator(new PopupRevision));
			
			facade.registerMediator(new PopupBindingMediator(new PopupBinding));
			
			facade.registerMediator(new PopupSignMediator(new PopupSign));
			
			facade.registerMediator(new PopupFileMediator(new PopupFile));
			
			facade.registerMediator(new PopupSendMediator(new PopupSend));			
			
			facade.registerMediator(new PopupBackResonMediator(new PopupBackReson));
			
			facade.registerMediator(new PopupNaviImageMediator(new PopupNaviImage));	
			
			facade.registerMediator(new PopupPrintSignMediator(new PopupPrintSign));
			
			facade.registerMediator(new PopupPrintFinancialMediator(new PopupPrintFinancial));
			
			facade.registerMediator(new PopupCancelResonMediator(new PopupCancelReson));		
			
			facade.registerMediator(new PopupMessageMediator(new PopupMessage));	
			
			application.addEventListener(BasePopupPanel.SUBPANEL_CLOSED,onPopupClosed);			
			application.addEventListener(ResizeEvent.RESIZE,onApplicationResize);
		}
		
		protected function get application():Main
		{
			return viewComponent as Main;
		}		
		
		private function onPopupClosed(event:Event):void
		{
			sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE,event.target);
		}
		
		private function onApplicationResize(event:Event):void
		{
			sendNotification(ApplicationFacade.NOTIFY_APP_RESIZE,[application.width,application.height]);
		}
	}
}