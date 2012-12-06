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
			sqls.text = "CREATE TABLE IF NOT EXISTS song( id INTEGER PRIMARY KEY AUTOINCREMENT, title, artist, url, type, favor, count,skip);";
			sqls.execute();
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
		
		public static function escape(str:String):String
		{
			if(!str)
				return "";
			return str.split("'").join("''");
		}
	}
}