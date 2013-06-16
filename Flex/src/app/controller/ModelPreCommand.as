package app.controller
{	
	import app.model.AttachProxy;
	import app.model.ContactPeopleProxy;
	import app.model.EntrustPeopleProxy;
	import app.model.EntrustUnitProxy;
	import app.model.FeedbackProxy;
	import app.model.LoginProxy;
	import app.model.MessageProxy;
	import app.model.ReportProxy;
	import app.model.ReportYearProxy;
	import app.model.UserProxy;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	import spark.components.Application;
	
	public class ModelPreCommand extends SimpleCommand
	{
		override public function execute(note:INotification):void
		{
			facade.registerProxy(new LoginProxy);
			facade.registerProxy(new UserProxy);
			facade.registerProxy(new ReportProxy);
			facade.registerProxy(new ContactPeopleProxy);
			facade.registerProxy(new ReportYearProxy);
			facade.registerProxy(new EntrustUnitProxy);
			facade.registerProxy(new EntrustPeopleProxy);
			facade.registerProxy(new AttachProxy);			
			facade.registerProxy(new FeedbackProxy);		
			facade.registerProxy(new MessageProxy);			
		}
	}
}