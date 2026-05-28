import SwiftUI

/// تعديل عنصر طعام: تصحيح الاسم والحكم والحصة قبل الحفظ.
struct EditItemView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft: EditableItem
    let onSave: (EditableItem) -> Void

    init(item: EditableItem, onSave: @escaping (EditableItem) -> Void) {
        _draft = State(initialValue: item)
        self.onSave = onSave
    }

    private let portions = ["حصة صغيرة", "متوسطة", "حصة كبيرة"]

    var body: some View {
        NavigationStack {
            Form {
                Section("الاسم") {
                    TextField("اسم الطعام", text: $draft.nameAr)
                }
                Section("الحكم") {
                    Picker("الحكم", selection: $draft.verdict) {
                        ForEach(Verdict.allCases) { v in
                            Text(v.labelAr).tag(v)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section("الحصة") {
                    Picker("الحصة", selection: $draft.estimatedPortion) {
                        ForEach(portions, id: \.self) { Text($0).tag($0) }
                    }
                }
                Section("الفئة") {
                    TextField("الفئة", text: $draft.category)
                }
            }
            .navigationTitle("تعديل العنصر")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("إلغاء") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("حفظ") {
                        draft.wasEdited = true
                        onSave(draft)
                        dismiss()
                    }
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}
