package app.view
{
	import app.ApplicationFacade;
	import app.controller.WebServiceCommand;
	import app.model.ContactPeopleProxy;
	import app.model.EntrustUnitProxy;
	import app.model.ReportYearProxy;
	import app.model.dict.AcceptAddressDict;
	import app.model.dict.GroupDict;
	import app.model.dict.ReportStatusDict;
	import app.model.vo.EntrustUnitVO;
	import app.view.components.NaviStatisCount;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.formatters.DateTimeFormatter;
	
	public class NaviStatisCountMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "NaviStatisCountMediator";
		
		public function NaviStatisCountMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
						
			naviStatisCount.addEventListener(FlexEvent.CREATION_COMPLETE,onCreation);
			
			naviStatisCount.addEventListener(NaviStatisCount.STATIS,onStatis);
			
			naviStatisCount.addEventListener(NaviStatisCount.GROUPCHANGE,onGroupChange);
			naviStatisCount.addEventListener(NaviStatisCount.OFFICECHANGE,onOfficeChange);
		}
		
		protected function get naviStatisCount():NaviStatisCount
		{
			return viewComponent as NaviStatisCount;
		}
				
		private function onCreation(event:FlexEvent):void
		{			
			naviStatisCount.comboType.dataProvider = GroupDict.listAll;
			naviStatisCount.comboType.selectedIndex = 0;
			
			naviStatisCount.comboTime.selectedIndex = 1;
			
			var reportYearProxy:ReportYearProxy = facade.retrieveProxy(ReportYearProxy.NAME) as ReportYearProxy;						
			naviStatisCount.comboYear.dataProvider = reportYearProxy.list;
			naviStatisCount.comboYear.selectedIndex = 1;
			
			var arr:ArrayCollection = new ArrayCollection;
			for(var i:Number = 1;i < reportYearProxy.list.length;i++)
				arr.addItem(reportYearProxy.list[i]);
			naviStatisCount.comboMonthYear.dataProvider = arr;
			naviStatisCount.comboMonthYear.selectedIndex = 0;
			naviStatisCount.comboMonth.selectedIndex = (new Date).month;
			
			naviStatisCount.comboAcceptAddress.dataProvider = AcceptAddressDict.listAll;
			naviStatisCount.comboAcceptAddress.selectedIndex = 0;
			
			var contactPeopleProxy:ContactPeopleProxy = facade.retrieveProxy(ContactPeopleProxy.NAME) as ContactPeopleProxy;
			naviStatisCount.comboContactCount.dataProvider = contactPeopleProxy.list;
			naviStatisCount.comboContactCount.selectedIndex = 0;
			
			onGroupChange(null);
		}
		
		private function onGroupChange(event:Event):void
		{						
			var entrustUnitProxy:EntrustUnitProxy = facade.retrieveProxy(EntrustUnitProxy.NAME) as EntrustUnitProxy;
			if(naviStatisCount.comboType.selectedIndex != 3)
			{
				naviStatisCount.listEntrustUnit = entrustUnitProxy.getListByType(naviStatisCount.comboType.selectedIndex - 1);
				naviStatisCount.listEntrustUnit.addItemAt("所有委托单位",0);
				naviStatisCount.viewUnit.selectedIndex = 0;
			}			
			else
			{
				var listOffice:ArrayCollection = new ArrayCollection;
				var listUnit:ArrayCollection = entrustUnitProxy.getListByType(naviStatisCount.comboType.selectedIndex - 1);
				for each(var entrustUnit:EntrustUnitVO in listUnit)
				{
					var indexEnd:Number = entrustUnit.label.indexOf("分局");
					if(indexEnd >=0 )
					{
						var office:String = entrustUnit.label.substr(0,indexEnd + 2);
						if(!listOffice.contains(office))
							listOffice.addItem(office);
					}
				}
				listOffice.addItemAt("所有公安分局",0);
				
				naviStatisCount.comboUnitOffice.dataProvider = listOffice;
								
				naviStatisCount.viewUnit.selectedIndex = 1;
				
				naviStatisCount.comboUnitOffice.selectedIndex = 0;
				
				onOfficeChange(null);
			}
			
		}
				
		private function onOfficeChange(event:Event):void
		{
			var office:String = String(naviStatisCount.comboUnitOffice.selectedItem);
			
			var entrustUnitProxy:EntrustUnitProxy = facade.retrieveProxy(EntrustUnitProxy.NAME) as EntrustUnitProxy;			
			var listUnit:ArrayCollection = entrustUnitProxy.getListByType(naviStatisCount.comboType.selectedIndex - 1);
			
			var listStation:ArrayCollection = new ArrayCollection;
			listStation.addItem("所有派出所");
			
			for each(var entrustUnit:EntrustUnitVO in listUnit)
			{
				var index:Number = entrustUnit.label.indexOf(office);
				if(index >=0 )
				{
					var station:String = entrustUnit.label.substr(office.length);
					listStation.addItem(station);
				}
			}
			
			naviStatisCount.comboUnitStation.dataProvider = listStation;
			naviStatisCount.comboUnitStation.selectedIndex = 0;
		}
		
		private function onStatis(event:Event):void
		{						
			var dateF:DateTimeFormatter = new DateTimeFormatter;
			dateF.dateTimePattern = "yyyy-MM-dd";
			
			if(naviStatisCount.comboTypeCount.selectedIndex == 0)
			{
				var sql:String = "SELECT COUNT(*) AS 案件数量, IIF(IsNull( 受理地点名称 ), '受理地点为空', 受理地点名称 ) AS 单位  FROM " + WebServiceCommand.VIEW_REPORT + " WHERE ";
				if(naviStatisCount.comboAcceptAddress.selectedIndex != 0)
				{
					sql += " 受理地点名称  = '" + naviStatisCount.comboAcceptAddress.labelDisplay.text + "' AND ";
				}
			}
			else if(naviStatisCount.comboTypeCount.selectedIndex == 1)
			{
				if(naviStatisCount.comboType.selectedIndex != 3)
				{
					sql = "SELECT COUNT(*) AS 案件数量, IIF(IsNull( 委托单位 ), '单位为空', 委托单位 ) AS 单位  FROM " + WebServiceCommand.VIEW_REPORT + " WHERE ";
					
					if(naviStatisCount.comboUnitCount.textInput.text != "所有委托单位")
					{
						sql += " 委托单位 = '" + naviStatisCount.comboUnitCount.textInput.text + "' AND ";
					}
				}
				else
				{
					var office:String = String(naviStatisCount.comboUnitOffice.selectedItem);
					var station:String = String(naviStatisCount.comboUnitStation.selectedItem);
					if(office == "所有公安分局")
					{
						sql = "SELECT COUNT(*) AS 案件数量, LEFT(委托单位,Instr(委托单位,'公安分局') + 3) AS 单位  FROM " + WebServiceCommand.VIEW_REPORT + " WHERE ";
						
						sql += " Instr(委托单位,'公安分局') > 0 AND ";
					}
					else
					{
						sql = "SELECT COUNT(*) AS 案件数量, IIF(IsNull( 委托单位 ), '单位为空', 委托单位 ) AS 单位  FROM " + WebServiceCommand.VIEW_REPORT + " WHERE ";
						
						if(station == "所有派出所")
						{
							sql += " Instr(委托单位,'" + office + "') > 0 AND ";
						}
						else
						{
							sql += " 委托单位 = '" + office + station + "' AND ";							
						}
					}
				}
			}
			else
			{
				sql = "SELECT COUNT(*) AS 案件数量, IIF(IsNull( 委托单位联系人 ), '联系人为空', 委托单位联系人 ) AS 单位  FROM " + WebServiceCommand.VIEW_REPORT + " WHERE ";
				if(naviStatisCount.comboContactCount.selectedIndex != 0)
				{
					sql += " 委托单位联系人 = '" + naviStatisCount.comboContactCount.textInput.text + "' AND";
				}
			}
			
			if(naviStatisCount.comboTime.selectedIndex == 0)
			{
				if(naviStatisCount.comboYear.selectedIndex > 0)
				{
					sql += " 年度 = '" + naviStatisCount.comboYear.labelDisplay.text + "' AND ";
				}
			}
			else
			{
				sql += " Year(受理日期) = " + naviStatisCount.comboMonthYear.labelDisplay.text + " AND Month(受理日期) = " 
					+ (naviStatisCount.comboMonth.selectedIndex + 1) + " AND ";
			}
			
			if(naviStatisCount.comboType.selectedIndex != 0)
			{
				sql += " 类别  = " + naviStatisCount.comboType.selectedItem.id + " AND ";
			}
			
			if(naviStatisCount.comboAccepterType.selectedIndex != 0)
			{
				sql += " 案件类型  = '" + naviStatisCount.comboAccepterType.selectedItem + "' AND ";
			}
			
			sql += " 案件状态 <> " + ReportStatusDict.getItem("重新受理").id + " AND 案件状态 <> " + ReportStatusDict.getItem("案件取消").id;
			
			if(naviStatisCount.comboTypeCount.selectedIndex == 0)
			{
				sql += " GROUP BY 受理地点名称";
			}
			else if(naviStatisCount.comboTypeCount.selectedIndex == 1)
			{
				if((naviStatisCount.comboType.selectedIndex == 3)
					&& (office == "所有公安分局"))
				{
					sql += " GROUP BY LEFT(委托单位,Instr(委托单位,'公安分局') + 3)";
				}
				else
				{
					sql += " GROUP BY 委托单位";					
				}
			}
			else
			{
				sql += " GROUP BY 委托单位联系人";
			}
			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["GetTable",onGetResult
					,[sql]
				]);
			
			function onGetResult(result:ArrayCollection):void
			{				
				naviStatisCount.totalCount = 0;
				
				for each(var row:Object in result)
				{
					naviStatisCount.totalCount += Number(row.案件数量);
				}
				naviStatisCount.listDataProvider = result;
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
						&& naviStatisCount.initialized)
					{		
						onCreation(null);
					}
					break;
			}
		}
	}
}