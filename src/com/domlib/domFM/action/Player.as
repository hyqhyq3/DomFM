package com.domlib.domFM.action
{
	import com.domlib.domFM.events.PlayEvent;
	import com.domlib.domFM.utils.StringUtil;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.IDataInput;
	
	[Event(name="playComplete",type="com.domlib.domFM.events.PlayEvent")]
	
	[Event(name="playProgress",type="com.domlib.domFM.events.PlayEvent")]
	/**
	 * 播放器
	 * @author DOM
	 */
	public class Player extends EventDispatcher
	{
		/**
		 * 构造函数
		 */		
		public function Player()
		{
			super();
		}
		
		/**
		 * 退出进程
		 */		
		public function exit():void
		{
			if(playerProcess.running)
				playerProcess.exit(true);
		}
		
		/**
		 * mplayer路径
		 */		
		private var mplayerPath:String = File.applicationDirectory.nativePath+"\\tool\\mplayer\\mplayer.exe";
		/**
		 * 本机进程
		 */		
		private var playerProcess:NativeProcess;
		/**
		 * 本机进程启动信息对象
		 */		
		private var startupInfo:NativeProcessStartupInfo;
		
		private var currentPath:String;
		/**
		 * 播放一首音乐
		 * @param url 音乐路径
		 */		
		public function playSong(url:String):void
		{
			if(!url)
				return;
			currentPath = url;
			if(!playerProcess)
			{
				playerProcess = new NativeProcess();
				playerProcess.addEventListener(NativeProcessExitEvent.EXIT,onPlayComp);
				playerProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA,onStandardOutput);
				playerProcess.addEventListener(Event.STANDARD_OUTPUT_CLOSE,onOutputClose);
			}
			var file:File = new File(mplayerPath);
			startupInfo = new NativeProcessStartupInfo;
			startupInfo.executable = file;
			startupInfo.workingDirectory = File.applicationDirectory;
			startupInfo.arguments = new Vector.<String>();
			startupInfo.arguments.push(url);
			if(playerProcess.running)
			{
				playerProcess.addEventListener(NativeProcessExitEvent.EXIT,startPlayer);
				inExiting = true;
				playerProcess.exit(true);
				
			}
			else
			{
				playerProcess.start(startupInfo);	
			}
		}
		
		private function onOutputClose(event:Event):void
		{
			trace(event.type);
		}
		
		private var inExiting:Boolean = false;
		/**
		 * 播放完成
		 */		
		private function onPlayComp(event:NativeProcessExitEvent):void
		{
			if(inExiting)
				return;
			var e:PlayEvent = new PlayEvent(PlayEvent.PLAY_COMPLETE);
			e.url = currentPath;
			dispatchEvent(e);
		}
		/**
		 * 延迟启动播放器
		 */		
		private function startPlayer(e:Event):void
		{
			playerProcess.removeEventListener(NativeProcessExitEvent.EXIT,startPlayer);
			inExiting = false;
			playerProcess.start(startupInfo);
		}
		
		/**
		 * 命令行输出的信息
		 */		
		private function onStandardOutput(event:ProgressEvent):void
		{
			var data:IDataInput = playerProcess.standardOutput;
			var str:String = data.readMultiByte(data.bytesAvailable,"cn-gb");
			var lines:Array = str.split("\r");
			var lastLine:String;
			while(lines.length>0)
			{
				lastLine = lines.pop();
				if(StringUtil.trim(lastLine)!="")
					break;
			}
			if(lastLine.charAt(0)=="A")
			{
				var e:PlayEvent = new PlayEvent(PlayEvent.PLAY_PROGRESS);
				var index:int = lastLine.indexOf("(");
				var endIndex:int = lastLine.indexOf(")");
				var time:String = lastLine.substring(index+1,endIndex);
				e.palyedTime = StringUtil.getTime(time);
				index = lastLine.lastIndexOf("(");
				endIndex = lastLine.lastIndexOf(")");
				e.totalTime = StringUtil.getTime(lastLine.substring(index+1,endIndex));
				e.url = currentPath;
				dispatchEvent(e);
			}
		}		
		
	}
}