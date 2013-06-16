package app
{
	import app.controller.StartupCommand;
	import app.controller.TimeSynCommand;
	import app.controller.WebServiceCommand;
	
	import org.puremvc.as3.interfaces.IFacade;
	import org.puremvc.as3.patterns.facade.Facade;
	
	import spark.components.Application;
	
	public class ApplicationFacade extends Facade implements IFacade
	{
		public static const STARTUP:String 					= "startup";
		
		/**
		 *服务器时间同步
		 */		
		public static const NOTIFY_TIME_SYN:String					= "TimeSyn";
		
		/**
		 *访问网络服务
		 */		
		public static const NOTIFY_WEBSERVICE_SEND:String			= "WebServiceSend";
		
		/**
		 *弹出提示框 -提示
		 */		
		public static const NOTIFY_APP_ALERTINFO:String				= "AppAlertInfo";
		
		/**
		 *弹出提示框 -警告
		 */		
		public static const NOTIFY_APP_ALERTALARM:String			= "AppAlertAlarm";
		
		/**
		 *弹出提示框 -错误
		 */		
		public static const NOTIFY_APP_ALERTERROR:String			= "AppAlertError";
		
							
		/**
		 *程序控制-显示Loading
		 */		
		public static const NOTIFY_APP_LOADINGSHOW:String			= "AppLoadingShow";
		
		/**
		 *程序控制-隐藏Loading
		 */		
		public static const NOTIFY_APP_LOADINGHIDE:String			= "AppLoadingHide";
		
		/**
		 *程序初始化完成
		 */		
		public static const NOTIFY_APP_INIT:String					= "AppInit";
		
		/**
		 *窗口大小变化
		 */		
		public static const NOTIFY_APP_RESIZE:String				= "AppResize";
		
		/**
		 *弹出窗口初始化完毕
		 */		
		public static const NOTIFY_POPUP_CREATE:String				= "Popup_Create";
		
		/**
		 *打开弹出面板
		 */		
		public static const NOTIFY_POPUP_SHOW:String				= "Popup_Show";
		
		/**
		 *关闭弹出面板
		 */		
		public static const NOTIFY_POPUP_HIDE:String				= "Popup_Hide";
		
		/**
		 *登录-登录成功
		 */		
		public static const NOTIFY_LOGIN_SUCCESS:String				= "LoginSuccess";
		
		/**
		 *菜单-退出系统
		 */		
		public static const NOTIFY_MENU_EXIT:String					= "MenuExit";
		
		/**
		 *案件-刷新
		 */		
		public static const NOTIFY_REPORT_REFRESH:String			= "ReportRefresh";
				
		/**
		 * Singleton ApplicationFacade Factory Method
		 */
		public static function getInstance() : ApplicationFacade 
		{
			if ( instance == null ) instance = new ApplicationFacade( );
			return instance as ApplicationFacade;
		}
		
		/**
		* Start the application
		*/
		public function startup(app:Object):void 
		{
			sendNotification( STARTUP, app );	
		}
		
		/**
		 * Register Commands with the Controller 
		 */
		override protected function initializeController( ) : void
		{
			super.initializeController();
			
			registerCommand( STARTUP, StartupCommand );	
			
			registerCommand( NOTIFY_TIME_SYN, TimeSynCommand );	
			
			registerCommand( NOTIFY_WEBSERVICE_SEND, WebServiceCommand );	
		}
		
		public static var NOW:String;
		public static function getNow():Date
		{
			var nowString:String = ApplicationFacade.NOW.replace(/-/g,'/');
			return (NOW != null)?(new Date(Date.parse(nowString))):(new Date);
		}
	}
}