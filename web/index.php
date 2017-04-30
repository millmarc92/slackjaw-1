<?php
		/*
		print_r($_POST);
		print_r($_FILES);
		if(isset($_FILES['UploadFileField'])){
		$FileName = $_FILES['UploadFileField']['name'];
		$CustomerID = $_POST['CustomerId'];
		$Return = $_POST['return'];
		echo "<pre>./preproc_runner.sh $FileName $CustomerID $Return</pre>";
		}
		*/
        if(isset($_FILES['UploadFileField'])){
                // Creates the Variables needed to upload the file
                $UploadName = $_FILES['UploadFileField']['name'];
                // $UploadName = mt_rand(100000, 999999).$UploadName;
                $UploadTmp = $_FILES['UploadFileField']['tmp_name'];
                $UploadType = $_FILES['UploadFileField']['type'];
                $FileSize = $_FILES['UploadFileField']['size'];

				//Optional Parameters
				$CustomerID = $_POST['CustomerId'];
				$Return = $_POST['return'];

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
                        move_uploaded_file($UploadTmp, "$UploadName");
                        # echo shell_exec('bash cd /var/www/html/test/javascript/upload/Upload/');
                        # Sleep(5);
                        # echo shell_exec('bash /var/www/html/test/javascript/preproc_runner.sh $UploadName test');
                        #$command = "mkdir /var/www/html/test/javascript/Upload/";
                        # $output = shell_exec($command);
                        # echo "<pre>$output</pre>";
                        #echo "<pre>mkdir /var/www/html/test/javascript/Upload/$UploadName</pre>"; # testing passing of commands to shell
						#echo "<pre>./preproc_runner.sh $UploadName $CustomerID $Return</pre>";
						$execute = "<pre>./preproc_runner.sh $UploadName $CustomerID $Return</pre>";
						#echo $execute;
						echo shell_exec("./preproc_runner.sh $UploadName $CustomerID $Return");
						# echo shell_exec('bash mkdir /var/www/html/test/javascript/Upload/test/');
/*
$row = 1;
if (($handle = fopen("grepresult.csv", "r")) !== FALSE) {

    echo '<table border="1">';

    while (($data = fgetcsv($handle, 1000, ";")) !== FALSE) {
        $num = count($data);
        if ($row == 1) {
            echo '<thead><tr>';
        }else{
            echo '<tr>';
        }

        for ($c=0; $c < $num; $c++) {
            //echo $data[$c] . "<br />\n";
            if(empty($data[$c])) {
               $value = "&nbsp;";
            }else{
               $value = $data[$c];
            }
            if ($row == 1) {
                echo '<th>'.$value.'</th>';
            }else{
                echo '<td>'.$value.'</td>';
            }
        }

        if ($row == 1) {
            echo '</tr></thead><tbody>';
        }else{
            echo '</tr>';
        }
        $row++;
    }

    echo '</tbody></table>';
    fclose($handle);
} */
                }
        }

				if(isset($_GET["search"])){
			      $search = $_GET["search"];
						if(isset($_GET["dateFrom"]))
		        {
		          $dateFrom = $_GET["dateFrom"];
		        }
		        if(isset($_GET["dateTo"]))
		        {
		          $dateTo = $_GET["dateTo"];
		        }

						$scriptLocation = "/var/www/html/search_archive.sh";
		        $customerID = "cust-1234";
		        $dateRange = $dateFrom . ":". $dateTo;

		        $script = "sh $scriptLocation $customerID $dateRange $search";
		        $return = shell_exec($script);


		        $customerID = "cust-1234"; //later will get from login info
		        $root = "/var/www/html/";
		        $path = trim("$root/$customerID/$return");
		        $file = "$path";
						$queryResults = "";
		        clearstatcache();
		        $results = file($path);
		        if($results === false)
		        {
		            echo "<p>An Error Has Occured</p>";
		        }
		        else
		        {
		            foreach($results as $match)
		            {
		                $queryResults .= "<tr>\n";
		                $match = str_getcsv($match);
		                $stamp = explode(':', $match[0]);
		                $stamp = end($stamp);
		                $stamp = explode('.', $stamp);
		                $stamp = date('Y-m-d',$stamp[0]);
		                $queryResults .= "<td>$stamp</td>\n";
		                $channel = $match[2];
		                $channel =  explode(':',$channel);
		                $channel = $channel[1];
		                $queryResults .= "<td>$channel</td>\n";
		                $user = $match[1];
		                $queryResults .= "<td>$user</td>\n";
		                $content = $match[3];
		                $queryResults .= "<td>$content</td>\n";
		            }
		        }
				}
?>
<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>Site Maintenance: Slackjaw.me</title>
		<link rel="icon" type="image/gif" href="hashbrush.png" />
		<link rel="stylesheet" type="text/css" href="style.css" />
<!--

JAVASCRIPT TESTER



<!-- -->
		<script>
		function sayHello(who) {	//Function declaration.
			document.write("Hello, " + who);
		}
		</script>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

</head>

<body>
	<div id="container">

		<div id="header">
		<div id="headcontainer">
			<div id="logo">
				<img src="slackjaw_me.png" alt="Logo" style="width:auto; height:100%;">
			</div>
		</div>
			<div class="text">
				
			</div>
			<div class="menu">
				
			</div>			
			<!-- <article><h1>SlackJAW.me | Coming Soon!</h1></article> -->
		</div>

		<div id="content">
			<div id="title">
				<p1><A HREF="../..">Home  </A></p1>
				<p1><A HREF="https://bb.uis.edu/" target="_blank">Blackboard  </A></p1>
				<p1><A HREF="https://github.com/hardwarehuman/slackjaw" target="_blank">GitHub  </A></p1>
				<p1><A HREF="../phpmyadmin" target="_blank">MySQL</A></p1>
				<p1><A HREF="https://slackjaw.me:4200" target="_blank">SSH</A></p1>
				<p1>Testing:  <A HREF="slacktest/upload/simpleUpload" target="_blank">Simple Uploader</A></p1>
				<p1><A HREF="test/sqltest/test1/sqltest.php" target="_blank">MySQL Connection</A></p1>
				<p1><A HREF="slacktest/upload/SQLUpload" target="_blank">MySQL Uploader</A> [Needs Work]</p1>
			</div>

<!--[Search Box]
    <div id="formWrapper">
            </center>
			<form method="get" action="search.php">
				<div class="details">
					<label for="search">Search String:</label>
					<input type="text" class="tftextinput" name="search" size="21" maxlength="200">
				</div>
				<div class="details">

					<label for="dateFrom">Date From:</br></label>
					<input type="date" name="dateFrom">
				</div>
				<div class="details">
					<label for="dateTo">Date To:</br></label>
					<input type="date" name="dateTo">
				</div>
				<p>
				<fieldset>
					<input class="btn" name="submit" type="Submit" value="Search"/>
					<input class="btn" name="reset" type="reset" value="Clear Form">
				</fieldset>
			</form>
    </div>
			<div class="tfclear"></div>
-->

<!--[Upload Box]-->
	<div class="tfclear"></div>
			<div id="upload">
				<div class="title">
					<h3>Upload Archive</br></br></h3>					
				</div>
			<div class="fileuploadholder">
				<form action="index.php" method="post" enctype="multipart/form-data" name="FileUploadForm" id="FileUploadForm">
					<label for="UploadFileField"></label>
						<label for="CustomerId">Customer ID: </label>
						<input type="text" class="tftextinput" name="CustomerId" size="15" maxlength="150">
						</br>
						<input type="radio" name="return" value="debug" checked> Debug<br>
						<input type="radio" name="return" value="silent"> Silent<br>					`
						<label for="UploadFileField">.zip, .tar</label>
						<input type="file" name="UploadFileField" id="UploadFileField" />
						<input type="submit" name="UploadButton" id="UploadButton" value="Upload" />
				</form>
			</div>
			</div>
<!--[End of Upload Box]-->

<!--
				<ul>
					<li>Site: <A class ="selected" HREF="">Home - Slackjaw</A></li> -->
<!--				<li><A HREF="../..">Home</A></li>
					<li>Class: <A HREF="https://bb.uis.edu/" target="_blank">Blackboard - UIS </A></li>
					<li>GitHub: <A HREF="https://github.com/hardwarehuman/slackjaw" target="_blank">hardwarehuman/slackjaw</A></li>
					<li>MySQL Database: <A HREF="../phpmyadmin" target="_blank">PHPMyAdmin</A></li>
				</ul>
				<h3>Tools:</h3>
				<ul>
					<li>WEB SSH Tool: <A HREF="https://slackjaw.me:4200" target="_blank">Shell in a Box</A></li>
				</ul>
				<h3>Testing:</h3>
				<ul>
					<li>Simple Test Uploader:  <A HREF="slacktest/upload/simpleUpload" target="_blank">Simple Uploader</A></li>
					<li>MySQL Connection Tester: <A HREF="test/sqltest/test1/sqltest.php" target="_blank">Test Connection</A></li>
					<li>SQL Test Uploader:  <A HREF="slacktest/upload/SQLUpload" target="_blank">SQL Uploader</A> [Needs Work]</li>
				</ul> -->


			<div id="main">
				<article>
					<h2 align="center">Slackjaw</h2>
						<p>Processes exported Slack transcripts for search</p>
					<hr width="95%" size="2" align="center">
					<div>

						<h3>Expected to encompass three basic functions:</h3>
						<p>* Ingest slack transcripts</br>* Perform search across all chat streams</br>* Present results in a webpage</br></p>
					</div>
				</article>
<!--[Upload Box]
	<div class="tfclear"></div>
				<div class="fileuploadholder">
					<form action="index.php" method="post" enctype="multipart/form-data" name="FileUploadForm" id="FileUploadForm">
						<h3>Upload Archive</br></br></h3>
						<div id="uploadargs">
							<form id="uploadargs" method="get" action="">
								<label for="CustomerId">Customer ID: </label>
								<input type="text" class="tftextinput" name="CustomerId" size="15" maxlength="150">
							</form>
						</div>
						<label for="UploadFileField">.zip, .tar</label>
						<input type="file" name="UploadFileField" id="UploadFileField" align="center" />
						</br>
						<input type="radio" name="return" value="male" checked> Debug<br>
						<input type="radio" name="return" value="female"> Silent<br>
						<input type="submit" name="UploadButton" id="UploadButton" value="Upload" />

					</form>

				</div>
[End of Upload Box]-->

<!--[Search Box]-->
			<div id="nav">
				<div class="title">
					<h3>Search</br></br></h3>					
				</div>
				<div class="formWrapper">
					</center>
					<form id="searchbar" method="get" action="index.php">
					<table>
					<tr>
					<td>
						<div class="details">
							<label for="dateFrom">Date From:</label>
							<input type="date" name="dateFrom">
						</div>
					</td>
					<td>
						<div class="details">
							<label for="dateTo">Date To:</label>
							<input type="date" name="dateTo">
						</div>
					</td>
					</tr>
					</table>
						<div class="details">
							<label for="search">Search String:</label>
							<input type="text" class="tftextinput" name="search" size="50" maxlength="200">
						</div>
						<p>
						<fieldset>
							<input class="btn" name="submit" type="submit" value="search"/>
							<input class="btn" name="reset" type="reset" value="clear form">
						</fieldset>
					</form>
					<br clear="left">
					<div id="results">
					<?php
							if(isset($queryResults) && $queryResults != "")
							{
								echo "<table border='1'>";
								echo 		"<tr>";
								echo        "<th>Date</th><th>Channel</th><th>User</th><th>Content</th>";
								echo    "</tr>";
								echo $queryResults;
								echo "</table>";
							} elseif(isset($queryResults))
							{
								echo "<p>No Results Found</p>";
							}
					?>
					</div>
				</div>

			</div>
<!--[End of Search Box]-->
		</div>
		<div id="footer">
			Not associated with Slack Technologies
		</div>

</body>
</html>
