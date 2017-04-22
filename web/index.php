<?php
	if(isset($_FILES['UploadFileField'])){
		// Creates the Variables needed to upload the file
		$UploadName = $_FILES['UploadFileField']['name'];
		$UploadName = mt_rand(100000, 999999).$UploadName;
		$UploadTmp = $_FILES['UploadFileField']['tmp_name'];
		$UploadType = $_FILES['UploadFileField']['type'];
		$FileSize = $_FILES['UploadFileField']['size'];
		
		// Removes Unwanted Spaces and characters from the files names of the files being uploaded
		$UploadName = preg_replace("#[^a-z0-9.]#i", "", $UploadName);
		// Upload File Size Limit 
		if(($FileSize > 125000)){
			
			die("Error - File too Big");
			
		}
		// Checks a File has been Selected and Uploads them into a Directory on your Server
		if(!$UploadTmp){
			die("No File Selected, Please Upload Again");
		}else{
			move_uploaded_file($UploadTmp, "Upload/$UploadName");
		}
	}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<style>
body { margin:0; padding:0; background-color:#CCC; }
.fileuploadholder {
	width:400px;
	height:200px;
	margin: 60px auto 0px auto;
	background-color:#FFF;
	border:1px solid #CCC;
	padding:6px;
}
</style>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>File Upload</title>
</head>

<body>

<div class="fileuploadholder">
  <form action="index.php" method="post" enctype="multipart/form-data" name="FileUploadForm" id="FileUploadForm">
    <label for="UploadFileField"></label>
    <input type="file" name="UploadFileField" id="UploadFileField" />
    <input type="submit" name="UploadButton" id="UploadButton" value="Upload" />
  </form>
</div>
</body>
</html>