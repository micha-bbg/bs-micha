<?PHP

if ($argc < 2) {
	echo "\nZu wenig Parameter, exit...\n";
	exit;
}

$orgPath = getcwd();
$Path = $argv[1];
chdir($Path);
$Log = '/tmp/tmp.log';
exec("git log -100 > $Log");
$logContent = file($Log);
unlink($Log);
chdir($orgPath);

for ($i = 0; $i < count($logContent); $i++) {
	$Zeile = $logContent[$i];
	if (($Zeile[0] == 'D') && ($Zeile[1] == 'a') && ($Zeile[2] == 't') && ($Zeile[3] == 'e') && ($Zeile[4] == ':')) {
		$Date = trim(str_replace("Date:", "", $Zeile));
	} else {
		if (strstr($Zeile, "git-svn-id:") != false) {
			$SVN = strstr($Zeile, "@");
			$p = strpos($SVN, " ");
			$SVN = substr($SVN, 1, $p-1);
			echo "$SVN\n";
			break;
		}
	}
}

?>
