package com.domlib.domFM.events
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	
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
		 * 播放失败
		 */		
		public static const PLAY_ERROR:String = "playError";
		/**
		 * 加载完成事件
		 */		
		public static const LOAD_COMPLETE:String = "loadComplete";
		/**
		 * 构造函数
		 */		
		public function PlayEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		/**
		 * 已经播放的时间,以毫秒为单位
		 */		
		public var playedTime:Number;
		/**
		 * 总时间，以毫秒为单位
		 */		
		public var totalTime:Number;
		/**
		 * 正在播放的音乐路径
		 */		
		public var url:String;
		/**
		 * 通过网络下载的音乐二进制数据
		 */		
		public var bytes:ByteArray;
	}
}