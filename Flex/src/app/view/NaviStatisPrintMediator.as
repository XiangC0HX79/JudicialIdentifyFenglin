package app.view
{
	import app.ApplicationFacade;
	import app.model.ReportYearProxy;
	import app.view.components.NaviStatisPrint;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class NaviStatisPrintMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "NaviStatisPrintMediator";
		
		public function NaviStatisPrintMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			naviStatisPrint.addEventListener(FlexEvent.CREATION_COMPLETE,onCreation);
			
			naviStatisPrint.addEventListener(NaviStatisPrint.SUBMIT,onSubmit);
		}
		
		protected function get naviStatisPrint():NaviStatisPrint
		{
			return viewComponent as NaviStatisPrint;
		}
		
		private function onCreation(event:FlexEvent):void
		{							
			var reportYearProxy:ReportYearProxy = facade.retrieveProxy(ReportYearProxy.NAME) as ReportYearProxy;;
			
			naviStatisPrint.comboTime.selectedIndex = 0;
			
			naviStatisPrint.comboYear.dataProvider = reportYearProxy.list;
			naviStatisPrint.comboYear.selectedIndex = 1;
			
			var arr:ArrayCollection = new ArrayCollection;
			for(var i:Number = 1;i < reportYearProxy.list.length;i++)
				arr.addItem(reportYearProxy.list[i]);
			naviStatisPrint.comboMonthYear.dataProvider = arr;
			naviStatisPrint.comboMonthYear.selectedIndex = 0;
			naviStatisPrint.comboMonth.selectedIndex = (new Date).month;
		}
		
		private function onSubmit(event:Event):void
		{
			var sql:String = "SELECT 类别,Format(Sum(DateDiff('d', 打印接受日期, 打印日期))/COUNT(*),'#.###') + 1 AS 天数";
			sql += " FROM 报告信息 WHERE 打印接受日期 <> NULL AND 打印日期 <> NULL";
			
			if(naviStatisPrint.comboTime.selectedIndex == 0)
			{
				if(naviStatisPrint.comboYear.selectedIndex > 0)
				{
					sql += " AND 年度 = '" + naviStatisPrint.comboYear.labelDisplay.text + "' ";
				}
			}
			else
			{
				sql += " AND Year(受理日期) = " + naviStatisPrint.comboMonthYear.labelDisplay.text 
					+ " AND Month(受理日期) = " + (naviStatisPrint.comboMonth.selectedIndex + 1);
			}
			
			sql += " GROUP BY 类别";
			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["GetTable",onGetResult
					,[sql]
				]);
			
			function onGetResult(result:ArrayCollection):void
			{				
				naviStatisPrint.columnChart.dataProvider = result;
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
						&& naviStatisPrint.initialized)
					{				
						onCreation(null);
					}
					break;
			}
		}
	}
}