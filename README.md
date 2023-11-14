# AutoFileUploadDiscord

指定したフォルダを監視して新しくファイルが作成されたら Discord の Webhook でアップロードする。

config.ini で 監視するフォルダ、フィルター、Discord の Webhook の URL などを設定してください。

start.bat を実行すると起動します。

ダウンロードして使う場合、upload.ps1 と start.bat のファイルのブロックを解除する必要があります。

## config.ini について

初期設定の config.ini では png ファイルのみ 監視しています。

filter の項目で どのファイルを監視するかを正規表現で設定できます。

### config.ini の初期値
```ini
# 監視するフォルダ
folder = フォルダのパス

# webhookのURL
URL = DiscordのWebhookのURL

# ファイルの拡張子を指定
filter = *.png

# Discordにファイルを送信してから次のファイルを送信するまでの待機時間
cooldown = 3

# 何回までDiscordにファイルを送信することを試みるか
maxAttempts = 5
```
