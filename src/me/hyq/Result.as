package me.hyq
{
	public class Result
	{
		public static const TYPE_STRING:int = 1;
		public static const TYPE_OBJECT:int = 2;
		public static const TYPE_ARRAY:int = 3;
		public static const TYPE_END:int = 4;
		public static const TYPE_UNDEFINED:int = 5;
		public static const TYPE_NUMBER:int = 6;
		public var type:int;
		public var value:Object;
		
		public function Result(type:int, value:Object)
		{
			this.type = type;
			this.value = value;
		}
	}
}