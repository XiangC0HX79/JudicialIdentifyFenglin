package app.view
{
	import app.ApplicationFacade;
	import app.model.ReportYearProxy;
	import app.view.components.NaviStatisPrintCount;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class NaviStatisPrintCountMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "NaviStatisPrintCountMediator";
		
		public function NaviStatisPrintCountMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			naviStatisPrintCount.addEventListener(FlexEvent.CREATION_COMPLETE,onCreation);
			
			naviStatisPrintCount.addEventListener(NaviStatisPrintCount.SUBMIT,onSubmit);
		}
		
		protected function get naviStatisPrintCount():NaviStatisPrintCount
		{
			return viewComponent as NaviStatisPrintCount;
		}
		
		private function onCreation(event:FlexEvent):void
		{							
			var reportYearProxy:ReportYearProxy = facade.retrieveProxy(ReportYearProxy.NAME) as ReportYearProxy;;
			
			naviStatisPrintCount.comboTime.selectedIndex = 0;
			
			naviStatisPrintCount.comboYear.dataProvider = reportYearProxy.list;
			naviStatisPrintCount.comboYear.selectedIndex = 1;
			
			var arr:ArrayCollection = new ArrayCollection;
			for(var i:Number = 1;i < reportYearProxy.list.length;i++)
				arr.addItem(reportYearProxy.list[i]);
			naviStatisPrintCount.comboMonthYear.dataProvider = arr;
			naviStatisPrintCount.comboMonthYear.selectedIndex = 0;
			naviStatisPrintCount.comboMonth.selectedIndex = (new Date).month;
		}
		
		private function onSubmit(event:Event):void
		{
			var sql:String = "SELECT 姓名,COUNT(*) AS 数量";
			sql += " FROM 报告信息,用户信息 WHERE 报告信息.打印人 = 用户信息.ID AND 用户信息.是否使用";
			
			if(naviStatisPrintCount.comboTime.selectedIndex == 0)
			{
				if(naviStatisPrintCount.comboYear.selectedIndex > 0)
				{
					sql += " AND 年度 = '" + naviStatisPrintCount.comboYear.labelDisplay.text + "' ";
				}
			}
			else
			{
				sql += " AND Year(受理日期) = " + naviStatisPrintCount.comboMonthYear.labelDisplay.text 
					+ " AND Month(受理日期) = " + (naviStatisPrintCount.comboMonth.selectedIndex + 1);
			}
			
			sql += " GROUP BY 姓名";
			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["GetTable",onGetResult
					,[sql]
				]);
			
			function onGetResult(result:ArrayCollection):void
			{				
				naviStatisPrintCount.columnChart.dataProvider = result;
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
					if(notification.getBody()[0] == (facade.retrieveMediator(PopupStatisMediator.NAME) as PopupStatisMediator).getViewComponent()
						&& naviStatisPrintCount.initialized)
					{				
						onCreation(null);
					}
					break;
			}
		}
	}
}