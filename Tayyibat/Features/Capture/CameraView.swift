import SwiftUI
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

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            CameraPreview(session: camera.session).ignoresSafeArea()

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
                    Button(action: shutter) {
                        Circle()
                            .fill(.white)
                            .frame(width: 72, height: 72)
                            .overlay(Circle().stroke(.white.opacity(0.5), lineWidth: 4).frame(width: 84, height: 84))
                    }
                    Spacer()
                    Color.clear.frame(width: 50, height: 50)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
        .onAppear { camera.configureAndStart() }
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

    private func shutter() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        camera.capture { data in
            if let data { onCapture(data) }
        }
    }
}
