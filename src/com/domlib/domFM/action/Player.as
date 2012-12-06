package com.domlib.domFM.action
{
	import com.domlib.domFM.events.PlayEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
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
		
		private function onTimer(event:TimerEvent):void
		{
			if(!sc||sc.position==0)
			{
				timer.stop();
				var evt:PlayEvent = new PlayEvent(PlayEvent.PLAY_ERROR);
				evt.url = currentPath;
				dispatchEvent(evt);
				return;
			}
			var e:PlayEvent = new PlayEvent(PlayEvent.PLAY_PROGRESS);
			e.playedTime = sc.position;
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
				sc.stop();
				sc = null;
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
		private function onPlayComp(event:Event):void
		{
			if(timer.running)
				timer.stop();
			var e:PlayEvent = new PlayEvent(PlayEvent.PLAY_COMPLETE);
			e.url = currentPath;
			e.playedTime = sc.position;
			dispatchEvent(e);
		}
	}
}