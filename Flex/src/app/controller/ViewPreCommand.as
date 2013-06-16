package app.controller
{	
	import app.view.ApplicationMediator;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	import spark.components.Application;
	
	public class ViewPreCommand extends SimpleCommand
	{
		override public function execute(note:INotification):void
		{
			var application:Application = note.getBody() as Application;
						
			facade.registerMediator(new ApplicationMediator(application));			
		}
	}
}