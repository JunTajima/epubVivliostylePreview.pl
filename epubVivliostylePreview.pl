######vivliostyleフォルダ、表示するepubファイルの順でパスを指定するとepubファイルをVivliostyleで起動する。Mac専用。######
use utf8;
#Encodeモジュールをインポート
use Encode qw/encode decode/;

######Vivliostyleで表示する際のCSS追加指定######
my $addVivliostyleCss = "&renderAllPages=true&userStyle=data:,/*%3Cviewer%3E*/%0Aimg,%20svg%20%7B%20max-inline-size:%20100%25%20!important;%20max-block-size:%20100vb%20!important;%20object-fit:%20contain%20!important;%20%7D%0A/*%3C/viewer%3E*/%0A\@page%20:left%20%7B%0Amargin-right:%2010mm;%0A\@bottom-left%20%7B%0Acontent:%20counter(page);%0Amargin-left:%205pt;%0Amargin-bottom:%206mm;%0Awriting-mode:%20horizontal-tb;%0Afont-weight:%20normal;%0Afont-family:%20serif-ja,%20serif;%0A%7D%0A%7D%0A\@page%20:right%20%7B%0Amargin-left:%2010mm;%0A\@bottom-right%20%7B%0Acontent:%20counter(page);%0Amargin-right:%205pt;%0Amargin-bottom:%206mm;%0Awriting-mode:%20horizontal-tb;%0Afont-weight:%20normal;%0Afont-family:%20serif-ja,%20serif;%0A%7D%0A%7D%0A\@page%20:first%20%7B%0A\@bottom-left%20%7B%0Acontent:%20%27%27;%0A%7D%0A\@top-left%20%7B%0Acontent:%20%27%27;%0A%7D%0A%7D&spread=true"; #見開き表示、画像表示最適化、ノンブル表示の指定を追加
#############################################

#vivliostyleパッケージのパスを取得
my $vivliostyleFolderPath = $ARGV[0];
$vivliostyleFolderPath = decode('UTF-8', $vivliostyleFolderPath);
#パッケージの親ディレクトリのパスを取得（そこを起点にローカルWebサーバを起動する）
my $currentFolderPath = $vivliostyleFolderPath;
$currentFolderPath =~ s@^(.+?)/[^/]+$@$1@;
#vivliostyleフォルダ名を取得
my $vivliostyleFolderName = $vivliostyleFolderPath;
$vivliostyleFolderName =~ s@^.+?/([^/]+)$@$1@;

#表示するepubファイルのパスを取得
my $epubFilePath = $ARGV[1];
$epubFilePath = decode('UTF-8', $epubFilePath);

#乱数代わりに日時の数字を取得してepub解凍フォルダ名決定
my $getDateTimeNowCommand = 'date "+%Y%m%d%H%M%S"';
my $datetimenow = `$getDateTimeNowCommand`;
my $epubUnzipFoldername = "vivliostyleepubtmp_" . $datetimenow;
#テンポラリフォルダ無ければ作る
unless (-d $currentFolderPath . "/tmp"){mkdir $currentFolderPath . "/tmp"};
#テンポラリフォルダにEPUBファイルを解凍する
my $epubUnzipCommand = "unzip " . $epubFilePath . " -d " . $currentFolderPath . "/tmp/" . $epubUnzipFoldername;
system $epubUnzipCommand;

#ローカルWebサーバ起動処理
my $serverStartCommand = 'osascript -e \'tell application "Terminal" to do script "cd ' . $currentFolderPath . ';python -m SimpleHTTPServer 8000"\'';
system $serverStartCommand;

#ディレイ処理
my $delayCommand = "osascript -e 'delay 2'";
system $delayCommand;

#Vivliostyle Viewer起動
my $openVivliostyleCmd = 'osascript -e \'tell application "Google Chrome" to open location "http://localhost:8000/' . $vivliostyleFolderName . '/viewer/vivliostyle-viewer.html#b=http://localhost:8000/tmp/' . $epubUnzipFoldername . $addVivliostyleCss . "\"'";
system $openVivliostyleCmd;
