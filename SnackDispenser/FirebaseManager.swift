//
//  FirebaseManager.swift
//  SnackDispenser
//
//  Created by 竹内音碧 on 2025/10/28.
//

import Foundation
import FirebaseDatabase
import Combine

class FirebaseManager: ObservableObject {
    @Published var dispenserStatus: String = "待機中"
    @Published var isDispensing: Bool = false
    @Published var errorMessage: String?
    
    private var databaseRef: DatabaseReference
    private var statusObserver: DatabaseHandle?
    
    init() {
        databaseRef = Database.database().reference()
        observeDispenserStatus()
    }
    
    deinit {
        if let observer = statusObserver {
            databaseRef.child("pet/snackdispenser/status").removeObserver(withHandle: observer)
        }
    }
    
    // おやつを出す指示を送信
    func dispenseSnack() {
        guard !isDispensing else {
            errorMessage = "処理中です。しばらくお待ちください。"
            return
        }
        
        isDispensing = true
        dispenserStatus = "おやつを準備中..."
        errorMessage = nil
        
        let dispensePath = databaseRef.child("pet/snackdispenser/command")
        dispensePath.setValue("dispense") { [weak self] error, _ in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "送信エラー: \(error.localizedDescription)"
                    self.dispenserStatus = "エラー発生"
                    self.isDispensing = false
                }
            } else {
                DispatchQueue.main.async {
                    self.dispenserStatus = "指示を送信しました"
                }
                // 3秒後に自動的にリセット
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.isDispensing = false
                }
            }
        }
    }
    
    // ディスペンサーのステータスを監視
    private func observeDispenserStatus() {
        let statusPath = databaseRef.child("pet/snackdispenser/status")
        
        statusObserver = statusPath.observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            
            if let status = snapshot.value as? String {
                DispatchQueue.main.async {
                    switch status {
                    case "done":
                        self.dispenserStatus = "完了しました！"
                        self.isDispensing = false
                    case "dispensing":
                        self.dispenserStatus = "おやつを出しています..."
                    case "error":
                        self.dispenserStatus = "エラーが発生しました"
                        self.errorMessage = "ディスペンサーでエラーが発生しました"
                        self.isDispensing = false
                    default:
                        self.dispenserStatus = "待機中"
                    }
                }
            }
        }
    }
    
    // Firebaseの接続状態を確認
    func checkConnection() {
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            
            if let connected = snapshot.value as? Bool, connected {
                DispatchQueue.main.async {
                    self.errorMessage = nil
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Firebaseに接続できません"
                }
            }
        }
    }
}

