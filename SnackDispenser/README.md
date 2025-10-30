# 🐾 ペットおやつディスペンサーアプリ

<div align="center">

iOS × ESP32 × Firebase で実現する、スマートペットフィーダー

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)](https://developer.apple.com/ios/)
[![Firebase](https://img.shields.io/badge/Firebase-Realtime_Database-yellow.svg)](https://firebase.google.com/)
[![License](https://img.shields.io/badge/License-Private-red.svg)]()

</div>

---

## 📖 概要

このアプリは、iPhoneからWi-Fi経由でペット用おやつディスペンサー（ESP32搭載）を操作し、カメラ映像をリアルタイムで確認できるスマートペットフィーダーシステムです。外出先からでも愛するペットにおやつをあげられます。

### ✨ 主な機能

- 🎯 **ワンタップでおやつ配給**: ボタンを押すだけで遠隔操作
- 📹 **リアルタイムカメラ映像**: ペットの様子を常に確認
- ☁️ **Firebase連携**: クラウド経由で確実に通信
- 🔔 **ステータス表示**: ディスペンサーの動作状況をリアルタイム表示
- ⚠️ **エラーハンドリング**: 接続エラーや動作エラーを適切に通知

---

## 🎬 デモ

### アプリ画面構成

```
┌─────────────────────────────┐
│  ペットおやつディスペンサー      │ ← ヘッダー
│       待機中 / 動作中          │ ← ステータス表示
├─────────────────────────────┤
│                             │
│     📹 カメラ映像             │
│    （画面の60%）              │
│                             │
├─────────────────────────────┤
│  ⚠️ エラーメッセージ（必要時）  │
├─────────────────────────────┤
│  ┌─────────────────────┐    │
│  │  🐾 おやつを出す     │    │ ← CTAボタン
│  └─────────────────────┘    │
└─────────────────────────────┘
```

---

## 🏗️ システム構成

```
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│              │         │              │         │              │
│   iPhone     │ ◄─────► │   Firebase   │ ◄─────► │    ESP32     │
│   (iOS App)  │  WiFi   │   Realtime   │  WiFi   │  + Servo     │
│              │         │   Database   │         │   Motor      │
└──────────────┘         └──────────────┘         └──────────────┘
       │                                                  │
       │                                                  │
       ▼                                                  ▼
  カメラ映像表示                                    おやつを配給
  ボタン操作                                        ステータス送信
```

---

## 📁 プロジェクト構成

```
SnackDispenser/
├── SnackDispenserApp.swift      # アプリのエントリーポイント
│                                 # Firebase初期化を実行
│
├── ContentView.swift             # メイン画面UI
│                                 # カメラ表示 + ボタン + ステータス
│
├── FirebaseManager.swift         # Firebase Realtime Database管理
│                                 # - おやつ配給指示の送信
│                                 # - ステータス監視
│                                 # - エラーハンドリング
│
├── CameraView.swift              # カメラ映像表示
│                                 # AVCaptureSessionを使用
│                                 # カメラアクセス権限管理
│
└── GoogleService-Info.plist      # Firebase設定ファイル
```

---

## 🚀 セットアップ手順

### 必要な環境

- **macOS**: Ventura (13.0) 以降
- **Xcode**: 15.0 以降
- **iOS**: 15.0 以降（実機推奨）
- **Firebase**: アカウントとプロジェクト
- **ESP32**: Wi-Fi対応マイコン + サーボモーター

### 1️⃣ リポジトリのクローン

```bash
cd ~/Documents/xcode
# プロジェクトは既に存在している前提
```

### 2️⃣ Xcodeでプロジェクトを開く

```bash
open SnackDispenser/SnackDispenser.xcodeproj
```

### 3️⃣ Firebase SDKの追加

1. Xcode上部メニュー → **File** → **Add Package Dependencies...**
2. 検索欄に以下のURLを入力:
   ```
   https://github.com/firebase/firebase-ios-sdk
   ```
3. **Dependency Rule**: "Up to Next Major Version" `10.0.0` を選択
4. **Add to Project**: `SnackDispenser` を選択
5. 以下のプロダクトにチェックを入れて **Add Package**:
   - ✅ **FirebaseCore**
   - ✅ **FirebaseDatabase**

### 4️⃣ カメラアクセス権限の設定確認

1. プロジェクトナビゲーターで **SnackDispenser**（青いアイコン）をクリック
2. **TARGETS** → **SnackDispenser** を選択
3. **Info** タブをクリック
4. **Information Property List** セクションで以下を確認:
   ```
   Key:   Privacy - Camera Usage Description
   Type:  String
   Value: ペットの様子を確認するためにカメラを使用します。
   ```

すでに設定済みなので、確認のみでOKです！

### 5️⃣ Firebase Realtime Databaseの設定

#### A. Firebaseコンソールでの設定

1. [Firebase Console](https://console.firebase.google.com/) にアクセス
2. プロジェクト **snackdispenser-abe3f** を選択
3. 左メニュー → **Realtime Database** をクリック
4. **ルール** タブを選択
5. 以下のルールを設定（テスト用）:

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

⚠️ **注意**: 本番環境では認証を追加し、セキュリティルールを厳格化してください。

#### B. データベース構造

Firebaseには以下の構造でデータが保存されます:

```json
{
  "pet": {
    "snackdispenser": {
      "command": "dispense",      // アプリから送信
      "status": "waiting"         // ESP32から送信
    }
  }
}
```

**ステータスの種類**:
- `"waiting"` - 待機中
- `"dispensing"` - おやつを出している最中
- `"done"` - 完了
- `"error"` - エラー発生

---

## 🔧 ESP32側の実装

### 必要なライブラリ

- [Firebase ESP32](https://github.com/mobizt/Firebase-ESP32)
- [ESP32Servo](https://github.com/madhephaestus/ESP32Servo)

### サンプルコード

完全な実装は `SnackDispenser.ino` を参照してください。主要な処理は以下の通りです:

```cpp
#include <WiFi.h>
#include <FirebaseESP32.h>
#include <Servo.h>

// Wi-Fi設定
const char* ssid = "your_SSID";
const char* password = "your_PASSWORD";

// Firebase設定
#define FIREBASE_HOST "snackdispenser-abe3f-default-rtdb.firebaseio.com"
#define FIREBASE_AUTH ""  // テストモードの場合は空文字列

void checkFirebaseData() {
  if (Firebase.getString(firebaseData, "/pet/snackdispenser/command")) {
    String action = firebaseData.stringData();
    
    if (action == "dispense") {
      // ステータス更新: 動作中
      Firebase.setString(firebaseData, "/pet/snackdispenser/status", "dispensing");
      
      // サーボモーターでおやつを配給
      controlServo(90);
      delay(2000);
      controlServo(0);
      
      // ステータス更新: 完了
      Firebase.setString(firebaseData, "/pet/snackdispenser/status", "done");
      
      // コマンドをクリア
      Firebase.setString(firebaseData, "/pet/snackdispenser/command", "");
      
      // 待機状態に戻る
      delay(2000);
      Firebase.setString(firebaseData, "/pet/snackdispenser/status", "waiting");
    }
  }
}
```

---

## 📱 使い方

### 初回起動

1. **アプリを起動**
2. カメラへのアクセス許可ダイアログが表示される
3. **「許可」** をタップ
4. カメラ映像が表示される

### おやつを出す

1. 画面下部の **「🐾 おやつを出す」** ボタンをタップ
2. ステータスが **「おやつを準備中...」** に変化
3. ESP32がFirebaseの変更を検知
4. サーボモーターが動作しておやつを配給
5. ステータスが **「完了しました！」** に変化
6. 数秒後に **「待機中」** に戻る

### ステータス表示

ヘッダー部分に現在の状態が表示されます:

- 🟢 **待機中** - 次の指示を待っている状態
- 🟡 **おやつを準備中...** - アプリから指示を送信した直後
- 🔵 **おやつを出しています...** - ESP32が動作中
- ✅ **完了しました！** - おやつの配給が完了
- 🔴 **エラーが発生しました** - 何らかの問題が発生

---

## 🐛 トラブルシューティング

### ❌ カメラが表示されない

**原因**: カメラのアクセス権限が拒否されている

**解決方法**:
1. iPhoneの **設定** アプリを開く
2. **プライバシーとセキュリティ** → **カメラ** をタップ
3. **SnackDispenser** を探してオンにする
4. アプリを再起動

---

### ❌ Firebaseに接続できない

**原因**: ネットワークの問題、またはFirebaseの設定ミス

**解決方法**:
1. **Wi-Fi接続を確認**:
   - iPhoneがWi-Fiに接続されているか確認
   - インターネットに接続できるか確認

2. **Firebase設定を確認**:
   - `GoogleService-Info.plist` がプロジェクトに含まれているか
   - Firebase Consoleでプロジェクトが有効になっているか

3. **Xcodeコンソールでログを確認**:
   ```
   Firebase configured successfully
   ```
   というメッセージが出ていればOK

---

### ❌ ディスペンサーが動作しない

**原因**: ESP32がFirebaseに接続していない、またはコードの問題

**解決方法**:
1. **ESP32のシリアルモニタを確認**:
   ```
   WiFi Connected
   Initial status set to 'waiting'
   Received 'dispense' command
   ```

2. **Firebase Consoleでデータを確認**:
   - `/pet/snackdispenser/command` に `"dispense"` が書き込まれているか
   - `/pet/snackdispenser/status` が更新されているか

3. **Wi-Fi設定を確認**:
   - ESP32のSSID/パスワードが正しいか
   - ESP32がWi-Fiに接続できているか

4. **サーボモーターの配線を確認**:
   - サーボモーターがGPIO 13に接続されているか
   - 電源が供給されているか

---

### ❌ ビルドエラー

**`Type 'CameraView' does not conform to protocol 'UIViewRepresentable'`**

→ 修正済み（`UIViewControllerRepresentable` に変更済み）

**`The default Firebase app has not yet been configured`**

→ 修正済み（`AppDelegate` で初期化済み）

---

## 🔐 セキュリティについて

### ⚠️ 現在の設定（テスト用）

```json
{
  "rules": {
    "pet": {
      "snackdispenser": {
        ".read": true,   // 誰でも読み取り可能
        ".write": true   // 誰でも書き込み可能
      }
    }
  }
}
```

### ✅ 本番環境での推奨設定

Firebase Authenticationを導入し、認証済みユーザーのみアクセス可能にしてください:

```json
{
  "rules": {
    "pet": {
      "snackdispenser": {
        ".read": "auth != null",
        ".write": "auth != null"
      }
    }
  }
}
```

---

## 🎯 今後の改善案

- [ ] **ユーザー認証**: Firebase Authenticationでセキュリティ強化
- [ ] **おやつ履歴**: 配給履歴を記録して表示
- [ ] **スケジュール機能**: 定期的に自動でおやつを配給
- [ ] **プッシュ通知**: 配給完了時に通知
- [ ] **複数デバイス対応**: 複数のディスペンサーを管理
- [ ] **おやつ残量表示**: センサーで残量を検知
- [ ] **動画録画**: 配給時の様子を録画
- [ ] **統計表示**: 1日/週/月の配給回数をグラフ化

---

## 📄 ライセンス

このプロジェクトは個人利用を目的としています。

---

## 👤 作成者

**竹内音碧**

---

## 🙏 謝辞

- [Firebase](https://firebase.google.com/) - クラウドデータベース
- [ESP32](https://www.espressif.com/en/products/socs/esp32) - Wi-Fiマイコン
- [Apple](https://developer.apple.com/) - iOS開発環境

---

<div align="center">

Made with ❤️ for Pets

</div>

