<?php
// Reads 81Dojo's 81SU-web database and converts kifu to CSV
// Format ===> native_id, black_name, white_name, black_rate, white_rate, date, result_code, result_type, CSA_moves, num_moves
$url = "localhost";
$user = "";
$pass = "";
$db = "";
$csvpath = ".csv";
$link = mysql_connect($url,$user,$pass);
$sdb = mysql_select_db($db,$link);

$file = fopen($csvpath, "w");

$query = "SELECT kifus.*,blacks.name AS blackname,whites.name AS whitename FROM kifus JOIN players as blacks ON kifus.blackid=blacks.id JOIN players AS whites ON kifus.whiteid=whites.id WHERE kifus.id<1000000 AND blackrate>=1800 AND whiterate>=1800 AND (endtype='#RESIGN' OR endtype='#SENNICHITE') AND gametype='r'";
// Changed the range of kifus.id

$result = mysql_query($query, $link);
$count = 0;
while ($row = mysql_fetch_array($result, MYSQL_ASSOC)){
  $count = $count + 1;
  $lines = explode("\n", $row["contents"]);
  $moves = "";
  $num = 0;
  foreach ($lines as $line) {
    if (preg_match("/^[\+\-]\d{4}[A-Z]{2}$/", $line)) {
      $moves = $moves . rtrim($line,"\n");
      $num = $num + 1;
    } elseif (preg_match("/^%TORYO/", $line)) $moves = $moves . rtrim($line,"\n");
  }
  $array=explode(" ",$row["created_at"]);
  $date=$array[0];
  $data = $row["id"] . "," . $row["blackname"] . "," . $row["whitename"] . "," . $row["blackrate"] . "," . $row["whiterate"] . "," . $date . "," . $row["result"] . "," . $row["endtype"] . "," . $moves . "," . $num . "\n";
  echo $data;
  fputs($file, $data);
}

mysql_free_result($result);
fclose($file);
echo "Total number: " . $count;
