package com.domlib.domFM.action
{
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.InvokeEvent;
	import flash.events.KeyboardEvent;
	import flash.filesystem.File;
	import flash.ui.Keyboard;
	
	import spark.components.Label;
	
	[Event(name="keyDown", type="flash.events.KeyboardEvent")]
	/**
	 * 
	 * @author DOM
	 */
	public class HotKey extends EventDispatcher
	{
		/**
		 * 构造函数
		 */		
		public function HotKey()
		{
			super();
			init();
		}
		
		private var hotKeyProcess:NativeProcess;
		
		private function init():void
		{
			hotKeyProcess = new NativeProcess();
			var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			info.executable = File.applicationDirectory.resolvePath("HotKey.exe");
			info.workingDirectory = File.applicationDirectory;
			hotKeyProcess.start(info);
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE,onInvoke);
		}
		
		private function onInvoke(event:InvokeEvent):void
		{
			if(event.arguments.length>1&&event.arguments[0]=="-hk")
			{
				var e:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN);
				e.altKey = true;
				e.ctrlKey = true;
				switch(event.arguments[1])
				{
					case "Right":
						e.keyCode = Keyboard.RIGHT;
						break;
					case "Left":
						e.keyCode = Keyboard.LEFT;
						break;
					case "F11":
						e.keyCode = Keyboard.F11;
						break;
					case "F12":
						e.keyCode = Keyboard.F12;
						break;
					case "F5":
						e.keyCode = Keyboard.F5;
						break;
				}
				dispatchEvent(e);
				event.preventDefault();
			}
		}
		/**
		 * 退出进程
		 */		
		public function exit():void
		{
			if(hotKeyProcess.running)
				hotKeyProcess.exit(true);
		}
	}
}