package com.domlib.domFM.events
{
	import flash.events.Event;
	
	
	/**
	 * 播放事件
	 * @author DOM
	 */
	public class PlayEvent extends Event
	{
		/**
		 * 播放完成
		 */		
		public static const PLAY_COMPLETE:String = "playComplete";
		/**
		 * 播放进度
		 */		
		public static const PLAY_PROGRESS:String = "playProgress";
		/**
		 * 构造函数
		 */		
		public function PlayEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		/**
		 * 已经播放的时间
		 */		
		public var palyedTime:Number;
		/**
		 * 总时间
		 */		
		public var totalTime:Number;
		/**
		 * 正在播放的音乐路径
		 */		
		public var url:String;
	}
}