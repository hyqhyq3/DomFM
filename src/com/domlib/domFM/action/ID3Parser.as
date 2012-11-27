package com.domlib.domFM.action
{
	import com.domlib.domFM.data.ID3Tag;
	import com.domlib.domFM.events.ID3Event;
	import com.domlib.domFM.utils.StringUtil;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.IDataInput;
	
	
	[Event(name="getOneInfo",type="com.domlib.domFM.events.ID3Event")]
	
	[Event(name="allComplete",type="com.domlib.domFM.events.ID3Event")]
	/**
	 * ID3信息解析类
	 * @author DOM
	 */
	public class ID3Parser extends EventDispatcher
	{
		/**
		 * 构造函数
		 */		
		public function ID3Parser()
		{
			super();
		}
		
		private var needParseList:Array = [];
		
		public function parse(urlList:Array):void
		{
			needParseList = needParseList.concat(urlList);
			if(needParseList.length>0&&!nativeProcess.running)
			{
				start();
			}
			else if(needParseList.length==0&&nativeProcess.running)
			{
				nativeProcess.exit(true);
			}
		}
		
		/**
		 * 解析一个文件
		 */		
		private function parseOne():void
		{
			if(needParseList.length==0)
			{
				exit();
				dispatchEvent(new ID3Event(ID3Event.ALL_COMPLETE));
				return;
			}
			var url:String = needParseList.shift();
			nativeProcess.standardInput.writeMultiByte(url+"\n","cn-gb");
		}
		
		private static const id3Path:String = File.applicationDirectory.nativePath+"\\tool\\win\\ID3.exe";
		/**
		 * 本机进程
		 */		
		private var nativeProcess:NativeProcess = new NativeProcess;
		
		/**
		 * 启动进程
		 */		
		private function start():void
		{
			var file:File = new File(id3Path);
			var startupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo;
			startupInfo.executable = file;
			startupInfo.workingDirectory = File.applicationDirectory;
			nativeProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA,onStandardOutput);
			nativeProcess.start(startupInfo);	
			parseOne();
		}
		/**
		 * 退出进程
		 */		
		public function exit():void
		{
			if(nativeProcess.running)
				nativeProcess.exit(true);
		}
		
		private var cmdOutStr:String  = "";
		/**
		 * 记录命令行输出的信息
		 */		
		private function onStandardOutput(event:ProgressEvent):void
		{
			var data:IDataInput = nativeProcess.standardOutput;
			var str:String = data.readMultiByte(data.bytesAvailable,"cn-gb");
			cmdOutStr += str;
			trace(str);
			if(str.indexOf("[EOF]")!=-1)
			{
				oneComplete(str);
				cmdOutStr = "";
				parseOne();
			}
			else if(str.indexOf("输入音频的路径或格式无效!")!=-1)
			{
				cmdOutStr = "";
				parseOne();
			}
		}	
		/**
		 * 一首歌解析完成
		 */		
		private function oneComplete(str:String):void
		{
			var tags:Array = cmdOutStr.split("\n");
			var e:ID3Event = new ID3Event(ID3Event.GET_ONE_INFO);
			var info:ID3Tag = new ID3Tag;
			e.tagInfo = info;
			for each(var tag:String in tags)
			{
				var index:int = tag.lastIndexOf("[EOF]");
				if(index!=-1)
				{
					e.url = tag.substring(5,index);
					break;
				}
				var strs:Array = tag.split(" = ");
				switch(strs[0])
				{
					case "Title":
						info.title = strs[1];
						break;
					case "Artist":
						info.artist = strs[1];
						break;
					case "Album":
						info.album = strs[1];
						break;
				}
			}
			dispatchEvent(e);
		}
	}
}