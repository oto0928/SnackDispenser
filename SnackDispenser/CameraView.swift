//
//  CameraView.swift
//  SnackDispenser
//
//  Created by 竹内音碧 on 2025/10/28.
//

import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    @Binding var errorMessage: String?
    
    class CameraViewController: UIViewController {
        var captureSession: AVCaptureSession?
        var previewLayer: AVCaptureVideoPreviewLayer?
        var errorCallback: ((String) -> Void)?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupCamera()
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            previewLayer?.frame = view.bounds
        }
        
        func setupCamera() {
            // カメラの使用権限をチェック
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                initializeCamera()
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                    if granted {
                        DispatchQueue.main.async {
                            self?.initializeCamera()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self?.errorCallback?("カメラへのアクセスが拒否されました。設定から許可してください。")
                        }
                    }
                }
            case .denied, .restricted:
                errorCallback?("カメラへのアクセスが拒否されています。設定から許可してください。")
            @unknown default:
                errorCallback?("カメラの状態を確認できません")
            }
        }
        
        func initializeCamera() {
            captureSession = AVCaptureSession()
            guard let captureSession = captureSession else { return }
            
            captureSession.sessionPreset = .medium
            
            // カメラデバイスを取得
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                errorCallback?("カメラデバイスが見つかりません")
                return
            }
            
            do {
                let videoInput = try AVCaptureDeviceInput(device: videoDevice)
                
                if captureSession.canAddInput(videoInput) {
                    captureSession.addInput(videoInput)
                } else {
                    errorCallback?("カメラ入力を追加できません")
                    return
                }
                
                // プレビューレイヤーを設定
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    self.previewLayer?.videoGravity = .resizeAspectFill
                    self.previewLayer?.frame = self.view.bounds
                    
                    if let previewLayer = self.previewLayer {
                        self.view.layer.addSublayer(previewLayer)
                    }
                    
                    // カメラセッションを開始
                    DispatchQueue.global(qos: .userInitiated).async {
                        captureSession.startRunning()
                    }
                }
            } catch {
                errorCallback?("カメラの初期化に失敗しました: \(error.localizedDescription)")
            }
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            captureSession?.stopRunning()
        }
    }
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let viewController = CameraViewController()
        viewController.errorCallback = { message in
            DispatchQueue.main.async {
                self.errorMessage = message
            }
        }
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        // 特に更新は不要
    }
}

