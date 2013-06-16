package app.view
{
	import app.ApplicationFacade;
	import app.model.ReportProxy;
	import app.model.ReportYearProxy;
	import app.model.dict.GroupDict;
	import app.model.dict.ReportStatusDict;
	import app.view.components.NaviStatisTime;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class NaviStatisTimeMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "NaviStatisTimeMediator";
		
		public function NaviStatisTimeMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			naviStatisTime.addEventListener(FlexEvent.CREATION_COMPLETE,onCreation);
			
			naviStatisTime.addEventListener(NaviStatisTime.STATIS,onStatis);
		}
		
		protected function get naviStatisTime():NaviStatisTime
		{
			return viewComponent as NaviStatisTime;
		}
				
		private function onCreation(event:FlexEvent):void
		{						
			naviStatisTime.comboPeriodTime.selectedIndex = 0;
			
			var reportYearProxy:ReportYearProxy = facade.retrieveProxy(ReportYearProxy.NAME) as ReportYearProxy;						
			naviStatisTime.comboPeriodYear.dataProvider = reportYearProxy.list;
			naviStatisTime.comboPeriodYear.selectedIndex = 1;
			
			var arr:ArrayCollection = new ArrayCollection;
			for(var i:Number = 1;i < reportYearProxy.list.length;i++)
				arr.addItem(reportYearProxy.list[i]);
			naviStatisTime.comboPeriodMonthYear.dataProvider = arr;
			naviStatisTime.comboPeriodMonthYear.selectedIndex = 0;
			naviStatisTime.comboPeriodMonth.selectedIndex = (new Date).month;
			
			naviStatisTime.comboPeriodType.dataProvider = GroupDict.list;
			naviStatisTime.comboPeriodType.selectedIndex = 0;
			
			naviStatisTime.comboPeriodProcess.selectedIndex = 0;
		}
		
		private function onStatis(event:Event):void
		{
			var sql:String = "SELECT 类别,";
			switch(naviStatisTime.comboPeriodProcess.selectedIndex)
			{
				case 0:
					sql += "CInt(Sum(DateDiff('d', 受理日期, 签字日期))/COUNT(*)) AS 天数 "
					break;
			}
			//sql += "FROM 报告信息 WHERE 案件状态 = " + ReportStatusDict.getItem("完成").id;
			sql += "FROM 报告信息 WHERE 签字日期 <> NULL ";
			
			if(naviStatisTime.comboPeriodTime.selectedIndex == 0)
			{
				if(naviStatisTime.comboPeriodYear.selectedIndex > 0)
				{
					sql += " AND 年度 = '" + naviStatisTime.comboPeriodYear.labelDisplay.text + "' ";
				}
			}
			else
			{
				sql += " AND Year(受理日期) = " + naviStatisTime.comboPeriodMonthYear.labelDisplay.text + " AND Month(受理日期) = " + (naviStatisTime.comboPeriodMonth.selectedIndex + 1);
			}
			
			sql += " GROUP BY 类别";
			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["GetTable",onGetResult
					,[sql]
				]);
			
			function onGetResult(result:ArrayCollection):void
			{				
				naviStatisTime.columnPeriod.dataProvider = result;
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
					if(notification.getBody()[0] == facade.retrieveMediator(PopupStatisMediator.NAME).getViewComponent()
						&& naviStatisTime.initialized)
					{				
						onCreation(null);
					}
					break;
			}
		}
	}
}