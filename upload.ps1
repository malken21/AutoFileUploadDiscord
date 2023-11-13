#configファイル から読み込む
$conf_file = "config.ini"
$conf_content = (Get-Content $conf_file) -replace "\\", "\\\\"
$conf = $conf_content | ConvertFrom-StringData



#=====設定項目===== start

# 監視するフォルダ
$folder = $conf.folder
# webhookのURL
$URL = $conf.URL
# ファイルの拡張子を指定
$filter = $conf.filter
# Discordにファイルを送信してから次のファイルを送信するまでの待機時間
$cooldown = $conf.cooldown

#=====設定項目===== end



Write-Host "監視するフォルダ: $folder"
Write-Host "フィルター: $filter"
Write-Host "クールダウン: $cooldown"



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

    try {
        # Discord の Webhook にファイルを送信する
        # curl.exeを実行し、レスポンスヘッダとボディを変数に格納
        $response = curl.exe -i -F "file=@$filePath" $URL

        # レスポンスヘッダからステータスコードを取得
        $status_code = $response[0].Split(" ")[1]

        # Discordにファイルを送信が成功したら 3秒間停止 (クールダウン)
        if ($status_code -eq 200) {
            Write-Host "Discordにファイルを送信できました"
            Write-Host "$cooldown 秒間待機します"
            Start-Sleep $cooldown
        }
    }
    catch {
        Write-Host "Discordにファイルを送信できませんでした"
    }
}

while ($true) { Start-Sleep 0.5 }# 無限ループ
