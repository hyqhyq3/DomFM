package com.domlib.domFM.utils
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.filesystem.File;
	
	/**
	 * 数据库操作类
	 * @author DOM
	 */
	public class SQL
	{
		/**
		 * 构造函数
		 */		
		public function SQL(dbPath:String)
		{
			var db:File = File.applicationDirectory.resolvePath(dbPath);
			sqlc.open(db);
			sqls.sqlConnection = sqlc;
			sqls.text = "CREATE TABLE IF NOT EXISTS song( id INTEGER PRIMARY KEY AUTOINCREMENT, title, artist, album,url, type, favor, count,skip);";
			sqls.execute();
			sqls.text = "CREATE TABLE IF NOT EXISTS version(id INTEGER PRIMARY KEY AUTOINCREMENT,ver);";
			sqls.execute();
		
			var result:Array = execute("select * from version");
			if(!result||result.length==0)
			{
				sqls.text = "insert into version (id,ver) values(1,1);";
				sqls.execute();
			}
		}
		
		private var _isChanged:Boolean = false;
		/**
		 * 数据库是否发生改变
		 */
		public function get isChanged():Boolean
		{
			return _isChanged;
		}

		/**
		 * 数据库连接
		 */		
		private var sqlc:SQLConnection = new SQLConnection();
		
		private var sqls:SQLStatement = new SQLStatement();
		/**
		 * 执行查询
		 * @param query 查询语句
		 */		
		public function execute(query:String):Array
		{
			if(!_isChanged&&query.substring(0,6).toLowerCase()!="select")
				_isChanged = true;
			try
			{
				sqls.text = query;
				sqls.execute();
				return sqls.getResult().data;
			}
			catch(e:Error)
			{
				trace(e.message);
			}
			return [{}];
		}
		/**
		 * 关闭数据库
		 */		
		public function close():void
		{
			try
			{
				sqlc.close();
			}
			catch(e:Error){}
		}
		
		public static function escape(str:String):String
		{
			if(!str)
				return "";
			return str.split("'").join("''");
		}
	}
}