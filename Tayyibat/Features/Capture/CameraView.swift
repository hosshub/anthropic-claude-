import SwiftUI
import UIKit
import AVFoundation
import PhotosUI

/// طبقة معاينة الكاميرا.
private struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {}

    final class PreviewView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var videoPreviewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }
}

/// شاشة الكاميرا كاملة الشاشة مع إطار توجيهي وزر التقاط، مع خيار اختيار من الصور.
struct CameraView: View {
    let onCapture: (Data) -> Void
    let onCancel: () -> Void

    @State private var camera = CameraModel()
    @State private var pickerItem: PhotosPickerItem?
    @State private var permissionDenied = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            CameraPreview(session: camera.session).ignoresSafeArea()

            if permissionDenied {
                deniedOverlay
            } else {
                // إطار توجيهي
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(.white.opacity(0.8), style: StrokeStyle(lineWidth: 2, dash: [10, 8]))
                        .frame(width: 280, height: 280)
                        .overlay(
                            Text("ضع الطبق في المنتصف")
                                .font(.caption)
                                .foregroundStyle(.white)
                                .padding(8)
                                .background(.black.opacity(0.4), in: Capsule())
                                .offset(y: 160)
                        )
                    Spacer()
                }
            }

            VStack {
                HStack {
                    Button(action: onCancel) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .padding(12)
                            .background(.black.opacity(0.4), in: Circle())
                    }
                    Spacer()
                }
                .padding()

                Spacer()

                HStack {
                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .padding(14)
                            .background(.black.opacity(0.4), in: Circle())
                    }
                    Spacer()
                    if permissionDenied {
                        Color.clear.frame(width: 72, height: 72)
                    } else {
                        Button(action: shutter) {
                            Circle()
                                .fill(.white)
                                .frame(width: 72, height: 72)
                                .overlay(Circle().stroke(.white.opacity(0.5), lineWidth: 4).frame(width: 84, height: 84))
                        }
                    }
                    Spacer()
                    Color.clear.frame(width: 50, height: 50)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
        .onAppear { checkPermission() }
        .onDisappear { camera.stop() }
        .onChange(of: pickerItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    await MainActor.run { onCapture(data) }
                }
            }
        }
    }

    private var deniedOverlay: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.fill")
                .font(.system(size: 50))
                .foregroundStyle(.white.opacity(0.85))
            Text("الكاميرا غير مُتاحة")
                .font(.sectionTitle)
                .foregroundStyle(.white)
            Text("فعّل صلاحية الكاميرا من الإعدادات، أو اختر صورة من مكتبتك بالأسفل.")
                .font(.bodyText)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.85))
                .padding(.horizontal, 32)
            Button("افتح الإعدادات") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .font(.cardTitle)
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(.white.opacity(0.2), in: Capsule())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.92))
    }

    private func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            camera.configureAndStart()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted { camera.configureAndStart() } else { permissionDenied = true }
                }
            }
        default:
            permissionDenied = true
        }
    }

    private func shutter() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        camera.capture { data in
            if let data { onCapture(data) }
        }
    }
}
