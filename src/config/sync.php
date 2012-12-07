<?php 
if($_GET['password']!='domlib')
	die();
$type = $_GET['type'];
$db_name = $_GET['dbname'];
$version_path = $db_name.'_version.txt';
$db_path = $db_name.'.zip';

if($type=='upload')
{	
	if(move_uploaded_file($_FILES['Filedata']['tmp_name'],$db_path))
	{
		file_put_contents($version_path, $_GET['version']);
	}
	else
	{
		echo $db_path;
	}
}
else if($type=='getversion')
{
	if(file_exists($version_path))
	{
		echo file_get_contents($version_path);
	}
	else
	{
		echo '0';
	}
}
else if($type=='download')
{
	Header("Content-type: application/octet-stream");
	Header("Content-Length: ".filesize($db_path));
	echo file_get_contents($db_path);
}

?>