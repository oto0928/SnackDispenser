//
//  ContentView.swift
//  SnackDispenser
//
//  Created by 竹内音碧 on 2025/10/28.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var firebaseManager = FirebaseManager()
    @State private var cameraError: String?
    
    var body: some View {
        ZStack {
            // 背景カラー
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ヘッダー
                VStack(spacing: 8) {
                    Text("ペットおやつディスペンサー")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(firebaseManager.dispenserStatus)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.blue)
                
                // カメラビュー
                ZStack {
                    CameraView(errorMessage: $cameraError)
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.height * 0.6)
                    
                    // カメラエラーメッセージ
                    if let error = cameraError {
                        VStack {
                            Image(systemName: "video.slash")
                                .font(.system(size: 48))
                                .foregroundColor(.white)
                            Text(error)
                                .font(.body)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.7))
                    }
                }
                
                Spacer()
                
                // エラーメッセージ表示
                if let errorMessage = firebaseManager.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.yellow)
                        Text(errorMessage)
                            .font(.body)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.8))
                }
                
                // おやつを出すボタン
                Button(action: {
                    firebaseManager.dispenseSnack()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "pawprint.fill")
                            .font(.title2)
                        Text("おやつを出す")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(
                        firebaseManager.isDispensing 
                            ? Color.gray 
                            : Color.green
                    )
                    .cornerRadius(12)
                }
                .disabled(firebaseManager.isDispensing)
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            firebaseManager.checkConnection()
        }
    }
}

