package com.domlib.domFM.action
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	/**
	 * 加载完成
	 */	
	[Event(name="complete", type="flash.events.Event")]
	/**
	 * 加载进度
	 */	
	[Event(name="progress", type="flash.events.ProgressEvent")]
	/**
	 * curl下载器
	 * @author DOM
	 */
	public class CurlLoader extends EventDispatcher
	{
		/**
		 * 构造函数
		 */		
		public function CurlLoader()
		{
			super();
		}
		
		private var nativeProcess:NativeProcess;
		
		private var startInfo:NativeProcessStartupInfo;
		/**
		 * 附加参数
		 */		
		public var arg:Object;
		

		/**
		 * 开始下载
		 */		
		public function load(url:String):void
		{
			_url = url;
			_complete = false;
			_loadedBytes = new ByteArray();
			if(!nativeProcess)
			{
				nativeProcess = new NativeProcess();
				nativeProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA,onStandardOutput);
				nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA,onStandardOutput);
			}
			
			startInfo = new NativeProcessStartupInfo();
			startInfo.workingDirectory = File.applicationDirectory;
			startInfo.executable = File.applicationDirectory.resolvePath("curl.exe");
			startInfo.arguments = new Vector.<String>();
			startInfo.arguments.push("-e");
			startInfo.arguments.push("http://y.qq.com/");
			startInfo.arguments.push("-b");
			startInfo.arguments.push("qqmusic_uin=12345678;qqmusic_key=12345678;qqmusic_fromtag=30");
			startInfo.arguments.push(_url);
			if(nativeProcess.running)
			{
				nativeProcess.addEventListener(NativeProcessExitEvent.EXIT,delayStart);
				nativeProcess.exit(true);
				return;
			}
			nativeProcess.addEventListener(NativeProcessExitEvent.EXIT,onComp);
			nativeProcess.start(startInfo);
		}
		/**
		 * 延迟启动
		 */		
		private function delayStart(event:NativeProcessExitEvent):void
		{
			nativeProcess.removeEventListener(NativeProcessExitEvent.EXIT,delayStart);
			nativeProcess.addEventListener(NativeProcessExitEvent.EXIT,onComp);
			nativeProcess.start(startInfo);
		}
		
		private var _url:String;
		/**
		 * 当前下载的地址
		 */
		public function get url():String
		{
			return _url;
		}

		private var _complete:Boolean = false;
		/**
		 * 已经加载完成的标志
		 */
		public function get complete():Boolean
		{
			return _complete;
		}

		/**
		 * 下载完成
		 */		
		private function onComp(event:NativeProcessExitEvent):void
		{
			_complete = true;
			nativeProcess.removeEventListener(NativeProcessExitEvent.EXIT,onComp);
			var evt:Event = new Event(Event.COMPLETE);
			dispatchEvent(evt);
		}
		
		private var _loadedBytes:ByteArray;
		/**
		 * 已经下载的字节流数据
		 */
		public function get loadedBytes():ByteArray
		{
			return _loadedBytes;
		}

		
		private var cmdErrorStr:String = "";
		/**
		 * 进程输出
		 */		
		private function onStandardOutput(event:ProgressEvent):void
		{
			if(event.type==ProgressEvent.STANDARD_OUTPUT_DATA)
			{
				var data:IDataInput = nativeProcess.standardOutput;
				data.readBytes(_loadedBytes,_loadedBytes.length);
				var evt:ProgressEvent = new ProgressEvent(ProgressEvent.PROGRESS,false,false,_loadedBytes.length);
				dispatchEvent(evt);
			}
			else
			{
				var error:IDataInput = nativeProcess.standardError;
				cmdErrorStr += error.readMultiByte(error.bytesAvailable,"cn-gb");
			}
		}
		
	}
}