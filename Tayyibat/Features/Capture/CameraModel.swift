import AVFoundation
import UIKit

/// يدير جلسة الكاميرا والتقاط الصور عبر AVFoundation.
final class CameraModel: NSObject, AVCapturePhotoCaptureDelegate {
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private let queue = DispatchQueue(label: "com.tayyibat.camera")
    private var captureHandler: ((Data?) -> Void)?
    private(set) var isConfigured = false

    /// يطلب الإذن ثم يهيئ الجلسة.
    func configureAndStart() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupIfNeededAndStart()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted { self?.setupIfNeededAndStart() }
            }
        default:
            break
        }
    }

    func stop() {
        queue.async { [weak self] in
            guard let self, self.session.isRunning else { return }
            self.session.stopRunning()
        }
    }

    func capture(completion: @escaping (Data?) -> Void) {
        captureHandler = completion
        let settings = AVCapturePhotoSettings()
        queue.async { [weak self] in
            guard let self, self.session.isRunning else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            self.output.capturePhoto(with: settings, delegate: self)
        }
    }

    private func setupIfNeededAndStart() {
        queue.async { [weak self] in
            guard let self else { return }
            if !self.isConfigured {
                self.session.beginConfiguration()
                self.session.sessionPreset = .photo
                if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                   let input = try? AVCaptureDeviceInput(device: device),
                   self.session.canAddInput(input) {
                    self.session.addInput(input)
                }
                if self.session.canAddOutput(self.output) {
                    self.session.addOutput(self.output)
                }
                self.session.commitConfiguration()
                self.isConfigured = true
            }
            if !self.session.isRunning { self.session.startRunning() }
        }
    }

    // MARK: - AVCapturePhotoCaptureDelegate

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let data = photo.fileDataRepresentation()
        DispatchQueue.main.async { [weak self] in
            self?.captureHandler?(data)
            self?.captureHandler = nil
        }
    }
}
