# ペットおやつディスペンサーアプリ

このアプリは、Wi-Fi経由でペット用おやつディスペンサーを操作し、カメラ映像をリアルタイムで表示するiOSアプリです。

## 機能

- **おやつディスペンサーの制御**: ボタンをタップするだけでおやつを出せます
- **リアルタイムカメラ映像**: ペットの様子を確認できます
- **Firebase Realtime Database連携**: ESP32などのデバイスと通信します

## プロジェクト構成

```
SnackDispenser/
├── SnackDispenserApp.swift     # アプリのエントリーポイント
├── ContentView.swift            # メイン画面UI
├── FirebaseManager.swift        # Firebase操作を管理
├── CameraView.swift             # カメラ映像表示
├── Info.plist                   # カメラアクセス権限設定
└── GoogleService-Info.plist     # Firebase設定
```

## セットアップ手順

### 1. Xcodeでプロジェクトを開く

```bash
open SnackDispenser.xcodeproj
```

### 2. Firebase SDKの追加

プロジェクトにはすでにFirebaseの設定が含まれていますが、Swift Package Managerで以下のパッケージを追加してください：

1. Xcode → File → Add Package Dependencies
2. 以下のURLを入力: `https://github.com/firebase/firebase-ios-sdk`
3. 以下のプロダクトを選択:
   - FirebaseCore
   - FirebaseDatabase

### 3. Info.plistの設定確認

Xcodeのプロジェクトナビゲーターで `Info.plist` を選択し、以下のキーが含まれていることを確認してください：

- `NSCameraUsageDescription`: カメラアクセスの説明

### 4. Firebase Realtime Databaseのルール設定

Firebaseコンソールで以下のセキュリティルールを設定してください（テスト用）：

```json
{
  "rules": {
    "pet": {
      "snackdispenser": {
        ".read": true,
        ".write": true
      }
    }
  }
}
```

**注意**: 本番環境では適切な認証とセキュリティルールを設定してください。

## Firebase Realtime Databaseの構造

```
pet/
  └── snackdispenser/
      ├── command: "dispense" または null
      └── status: "waiting" | "dispensing" | "done" | "error"
```

### データフロー

1. アプリが `/pet/snackdispenser/command` に `"dispense"` を書き込む
2. ESP32が変更を検知してディスペンサーを動作させる
3. ESP32が `/pet/snackdispenser/status` を更新:
   - `"dispensing"`: 動作中
   - `"done"`: 完了
   - `"error"`: エラー発生
4. アプリが status の変更を検知してUIを更新

## ESP32側の実装例

ESP32側では以下のような実装が必要です：

```cpp
// Firebaseから command を監視
Firebase.getString(firebaseData, "/pet/snackdispenser/command");
if (firebaseData.stringData() == "dispense") {
  // ステータスを更新
  Firebase.setString(firebaseData, "/pet/snackdispenser/status", "dispensing");
  
  // ディスペンサーを動作
  dispenseSnack();
  
  // 完了を通知
  Firebase.setString(firebaseData, "/pet/snackdispenser/status", "done");
  
  // commandをクリア
  Firebase.setString(firebaseData, "/pet/snackdispenser/command", "");
}
```

## 使い方

1. アプリを起動すると、カメラへのアクセス許可を求められます（初回のみ）
2. 許可すると、カメラ映像が表示されます
3. 「おやつを出す」ボタンをタップすると、ディスペンサーに指示が送信されます
4. ステータスバーに現在の状態が表示されます

## トラブルシューティング

### カメラが表示されない

- 設定アプリ → プライバシーとセキュリティ → カメラ → SnackDispenser を確認
- アクセス許可がオンになっているか確認してください

### Firebaseに接続できない

- インターネット接続を確認してください
- Firebase コンソールでプロジェクトが正しく設定されているか確認してください
- `GoogleService-Info.plist` が正しくプロジェクトに追加されているか確認してください

### ディスペンサーが動作しない

- ESP32がFirebaseに接続されているか確認してください
- Firebase Realtime Database のルールが読み書き可能になっているか確認してください
- Firebase コンソールでデータが正しく更新されているか確認してください

## 今後の改善案

- [ ] ユーザー認証の追加
- [ ] おやつの履歴表示
- [ ] スケジュール機能（定期的におやつを出す）
- [ ] プッシュ通知
- [ ] 複数のディスペンサー対応
- [ ] おやつの残量表示

## ライセンス

このプロジェクトは個人利用を目的としています。

## 作成者

竹内音碧

