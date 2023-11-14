#configファイル から読み込む
$conf_file = "config.ini"
# ファイルを改行コード入りの文字列として読み込む & バックスラッシュエスケープ
$conf_content = [System.IO.File]::ReadAllText($conf_file) -replace "\\", "\\\\"
# ハッシュテーブルに変換する
$conf = $conf_content | ConvertFrom-StringData



#=====設定項目===== start

# 監視するフォルダ
$folder = $conf.folder
# webhookのURL
$URL = $conf.URL
# ファイルの拡張子を指定
$filter = $conf.filter
# Discordにファイルを送信してから次のファイルを送信するまでの待機時間
$cooldown = [double] $conf.cooldown
# Discordにファイルの送信が失敗した場合、何回までファイルを送信することを試みるか
$maxRetry = [int] $conf.maxRetry

#=====設定項目===== end



Write-Host "フィルター: $filter"
Write-Host "クールダウン: $cooldown"
Write-Host "最大再試行回数: $maxRetry"



# Discordにファイルをアップロードするための関数
function  upload($URL, $filePath, $try_count = 0) {
    try {
        # Discord の Webhook にファイルを送信する
        # curl.exeを実行し、レスポンスヘッダとボディを変数に格納
        $response = curl.exe -i -F "file=@$filePath" $URL
        # レスポンスヘッダからステータスコードを取得
        $status_code = [int] $response[0].Split(" ")[1]

        # Discordにファイルの送信が成功したら
        if ($status_code -lt 300 ) {
            Write-Host "Discordにファイルを送信できました"
            Start-Sleep $cooldown # クールダウン
        }
        else {
            Write-Host "Discordにファイルを送信できませんでした"
            Start-Sleep $cooldown # クールダウン
            if ( $try_count -lt $maxRetry) {
                $try_count++
                upload $URL $filePath $try_count
            }
        }
    }
    catch {
        Write-Host "Discordにファイルを送信できませんでした"
    }
}


$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $folder # 監視するフォルダを指定
$watcher.Filter = $filter # フィルターを設定
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true

# ファイル作成で実行
Register-ObjectEvent $watcher "Created" -Action {

    # ファイルの名前を取得
    $fileName = $Event.SourceEventArgs.Name
    # コンソールに表示する
    Write-Host "$(Get-Date), $fileName"
    # ファイルのパスを取得
    $filePath = $Event.SourceEventArgs.FullPath
    # Discordにアップロードする
    upload $URL $filePath

}

while ($true) { Start-Sleep 0.5 }# 無限ループ
