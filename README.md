# AutoFileUploadDiscord

指定したフォルダを監視して新しくファイルが作成されたら Discord の Webhook でアップロードする

config.ini で 監視するフォルダ、フィルター、Discord の Webhook の URL を設定してください

## config.ini について

初期設定の config.ini では png ファイルのみ 監視しています。

filter の項目で どのファイルを監視するかを正規表現で設定できます。
