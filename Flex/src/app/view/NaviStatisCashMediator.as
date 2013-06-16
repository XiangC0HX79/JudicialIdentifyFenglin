package app.view
{
	import app.ApplicationFacade;
	import app.model.ContactPeopleProxy;
	import app.model.EntrustUnitProxy;
	import app.model.ReportYearProxy;
	import app.model.dict.AcceptAddressDict;
	import app.model.dict.GroupDict;
	import app.model.dict.ReportStatusDict;
	import app.model.vo.ReportVO;
	import app.view.components.NaviStatisCash;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class NaviStatisCashMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "NaviStatisCashMediator";
		
		public function NaviStatisCashMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			naviStatisCash.addEventListener(FlexEvent.CREATION_COMPLETE,onCreation);
			
			naviStatisCash.addEventListener(NaviStatisCash.SUBMIT,onSubmit);
			
			naviStatisCash.addEventListener(NaviStatisCash.GROUPCHANGE,onGroupChange);
		}
		
		protected function get naviStatisCash():NaviStatisCash
		{
			return viewComponent as NaviStatisCash;
		}
		
		private function onCreation(event:FlexEvent):void
		{									
			naviStatisCash.comboType.dataProvider = GroupDict.listAll;
			naviStatisCash.comboType.selectedIndex = 0;
			
			naviStatisCash.comboTime.selectedIndex = 1;
			
			var reportYearProxy:ReportYearProxy = facade.retrieveProxy(ReportYearProxy.NAME) as ReportYearProxy;						
			naviStatisCash.comboYear.dataProvider = reportYearProxy.list;
			naviStatisCash.comboYear.selectedIndex = 1;
			
			var arr:ArrayCollection = new ArrayCollection;
			for(var i:Number = 1;i < reportYearProxy.list.length;i++)
				arr.addItem(reportYearProxy.list[i]);
			naviStatisCash.comboMonthYear.dataProvider = arr;
			naviStatisCash.comboMonthYear.selectedIndex = 0;
			naviStatisCash.comboMonth.selectedIndex = (new Date).month;
			
			naviStatisCash.comboAcceptAddress.dataProvider = AcceptAddressDict.listAll;
			naviStatisCash.comboAcceptAddress.selectedIndex = 0;
						
			var contactPeopleProxy:ContactPeopleProxy = facade.retrieveProxy(ContactPeopleProxy.NAME) as ContactPeopleProxy;
			naviStatisCash.comboContactCount.dataProvider = contactPeopleProxy.list;
			naviStatisCash.comboContactCount.selectedIndex = 0;
		}
		
		private function onGroupChange(event:Event):void
		{						
			var entrustUnitProxy:EntrustUnitProxy = facade.retrieveProxy(EntrustUnitProxy.NAME) as EntrustUnitProxy;
			naviStatisCash.listEntrustUnit = entrustUnitProxy.getListByType(naviStatisCash.comboType.selectedIndex - 1);
		}
		
		private function onSubmit(event:Event):void
		{
			var sql:String = "SELECT 年度,类别,编号,次级编号,受检人,应缴金额,已缴金额"
			 	+ " FROM 报告信息 WHERE 案件状态 <> " + ReportStatusDict.getItem("重新受理").id 
				+ " AND 案件状态 <> " + ReportStatusDict.getItem("案件取消").id;
						
			if(naviStatisCash.comboType.selectedIndex != 0)
			{
				sql += " AND 类别  = " + naviStatisCash.comboType.selectedItem.id;
			}
			
			if(naviStatisCash.comboTime.selectedIndex == 0)
			{
				if(naviStatisCash.comboYear.selectedIndex > 0)
				{
					sql += " AND 年度 = '" + naviStatisCash.comboYear.labelDisplay.text + "'";
				}
			}
			else
			{
				sql += " AND Year(受理日期) = " + naviStatisCash.comboMonthYear.labelDisplay.text + " AND Month(受理日期) = " 
					+ (naviStatisCash.comboMonth.selectedIndex + 1);
			}
			
			if(naviStatisCash.comboTypeCount.selectedIndex == 0)
			{
				if(naviStatisCash.comboAcceptAddress.selectedIndex != 0)
				{
					sql += " AND 受理地点  = " + naviStatisCash.comboAcceptAddress.selectedIndex;
				}				
			}
			else if(naviStatisCash.comboTypeCount.selectedIndex == 1)
			{
				if(naviStatisCash.comboUnitCount.selectedIndex != 0)
				{
					sql += " AND 委托单位 = '" + naviStatisCash.comboUnitCount.textInput.text + "'";
				}
			}
			else
			{
				if(naviStatisCash.comboContactCount.selectedIndex == 2)
				{
					sql += " AND 委托单位联系人 = '" + naviStatisCash.comboContactCount.textInput.text + "'";
				}
			}
			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["GetTable",onGetResult
					,[sql]
				]);
			
			function onGetResult(result:ArrayCollection):void
			{				
				var gridDatapro:ArrayCollection = new ArrayCollection;
				
				var cash:Object = {类别:"总数",费用:0};
				var cashPay:Object = {类别:"已缴费",费用:0};
				var cashNoPay:Object = {类别:"欠费",费用:0};
				for each(var item:Object in result)
				{
					cash.费用 += Number(item.应缴金额);
					cashPay.费用 += Number(item.已缴金额);
					cashNoPay.费用 += Number(item.应缴金额) - Number(item.已缴金额);
					
					gridDatapro.addItem(new ReportVO(item));
				}
				
				var chartDatapro:ArrayCollection = new ArrayCollection([cash,cashPay,cashNoPay]);
				
				naviStatisCash.columnChart.dataProvider = chartDatapro;				
				naviStatisCash.gridReport.dataProvider = gridDatapro;
				
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
						&& naviStatisCash.initialized)
					{				
						onCreation(null);
					}
					break;
			}
		}
	}
}