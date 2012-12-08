package com.domlib.domFM.action
{
	import com.domlib.domFM.events.PlayEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Timer;

	/**
	 * 播放完成
	 */	
	[Event(name="playComplete",type="com.domlib.domFM.events.PlayEvent")]
	/**
	 * 播放进度
	 */	
	[Event(name="playProgress",type="com.domlib.domFM.events.PlayEvent")]
	/**
	 * 播放失败
	 */	
	[Event(name="playError",type="com.domlib.domFM.events.PlayEvent")]
	/**
	 * 当通过网络播放时，加载完成字节流后抛出此事件
	 */	
	[Event(name="loadComplete",type="com.domlib.domFM.events.PlayEvent")]
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
			timer.addEventListener(TimerEvent.TIMER,onTimer);
		}
		
		private var count:int = 0;
		
		private function onTimer(event:TimerEvent):void
		{
			if(!sc||sc.position==0)
			{
				count++;
				if((!curLoader&&count>10)||count>30)
				{
					count = 0;
					timer.stop();
					var evt:PlayEvent = new PlayEvent(PlayEvent.PLAY_ERROR);
					evt.url = currentPath;
					dispatchEvent(evt);
				}
				return;
			}
			count = 0;
			var e:PlayEvent = new PlayEvent(PlayEvent.PLAY_PROGRESS);
			e.playedTime = sc.position;
			e.totalTime = sound.length;
			e.url = currentPath;
			dispatchEvent(e);
		}
		
		private var timer:Timer = new Timer(500);
		
		/**
		 * 退出进程
		 */		
		public function exit():void
		{
			if(sound)
			{
				try
				{
					sound.close();
				}
				catch(e:Error){}
				sound = null;
			}
			if(sc)
			{
				sc.removeEventListener(Event.SOUND_COMPLETE,onPlayComp);
				sc.removeEventListener(Event.SOUND_COMPLETE,reloadBytes);
				sc.stop();
				sc = null;
			}
			if(curLoader)
			{
				curLoader.removeEventListener(ProgressEvent.PROGRESS,reloadBytes);
				curLoader.removeEventListener(Event.COMPLETE,onBytesComp);
				curLoader = null;
			}
			if(timer.running)
				timer.stop();
		}
		
		private var currentPath:String;
		private var sound:Sound;
		private var sc:SoundChannel;
		/**
		 * 播放一首音乐
		 * @param url 音乐路径
		 */		
		public function playSong(url:String):void
		{
			currentPath = url;
			exit();
			if(!url)
				return;
			if(url.substr(0,7)=="http://")
			{
				playHttp(url);
			}
			else
			{
				playLocal(url);
			}
		}
		
		private var curLoader:CurlLoader;
		
		private function playHttp(url:String):void
		{
			pos = 0;
			curLoader = new CurlLoader();
			curLoader.addEventListener(ProgressEvent.PROGRESS,reloadBytes);
			curLoader.addEventListener(Event.COMPLETE,onBytesComp);
			curLoader.load(url);
		}
		/**
		 * 字节流全部加载完成
		 */		
		private function onBytesComp(event:Event):void
		{
			if(!curLoader)
				return;
			var e:PlayEvent = new PlayEvent(PlayEvent.LOAD_COMPLETE);
			e.url = currentPath;
			e.bytes = curLoader.loadedBytes;
			dispatchEvent(e);
		}
		
		private var pos:int = 0;
		/**
		 * 重新加载字节流
		 */		
		private function reloadBytes(event:Event=null):void
		{
			if(event.type == ProgressEvent.PROGRESS)
				curLoader.removeEventListener(ProgressEvent.PROGRESS,reloadBytes);
			if(!curLoader)
				return;
			if(pos==0)
				sound = new Sound();
			var bytes:ByteArray = curLoader.loadedBytes;
			bytes.position = pos;
			if(bytes.bytesAvailable==0)
			{
				if(curLoader.complete)
				{
					onPlayComp();
				}
				else
				{
					curLoader.addEventListener(ProgressEvent.PROGRESS,reloadBytes);
					if(timer.running)
						timer.stop();
				}
				return;
			}
			sound.loadCompressedDataFromByteArray(bytes,bytes.length-pos);
			pos = bytes.length;
			sc = sound.play(sc?sc.position:0);
			if(sc)
				sc.addEventListener(Event.SOUND_COMPLETE,reloadBytes);
			if(!timer.running)
				timer.start();
		}
		
		private function playLocal(url:String):void
		{
			sound = new Sound(new URLRequest(url));
			sc = sound.play();
			if(sc)
			{
				sc.soundTransform.volume = 1;
				sc.addEventListener(Event.SOUND_COMPLETE,onPlayComp);
			}
			if(!timer.running)
				timer.start();
		}
		
		private var pausePos:Number = 0;
		/**
		 * 暂停播放
		 */		
		public function pause():void
		{
			if(!sc)
				return;
			pausePos = sc.position;
			sc.removeEventListener(Event.SOUND_COMPLETE,onPlayComp);
			sc.stop();
			if(timer.running)
				timer.stop();
		}
		/**
		 * 继续播放
		 */		
		public function resume():void
		{
			if(!sc)
				return;
			sc = sound.play(pausePos);
			sc.addEventListener(Event.SOUND_COMPLETE,onPlayComp);
			if(!timer.running)
				timer.start();
		}
		/**
		 * 播放完成
		 */		
		private function onPlayComp(event:Event=null):void
		{
			if(timer.running)
				timer.stop();
			var e:PlayEvent = new PlayEvent(PlayEvent.PLAY_COMPLETE);
			e.url = currentPath;
			e.playedTime = sc.position;
			e.totalTime = sound.length;
			dispatchEvent(e);
		}
	}
}