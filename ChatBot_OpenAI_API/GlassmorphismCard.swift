//SwiftUIを使用してグラスモーフィズムスタイルのカードを作成するためのカスタムビューを定義
import SwiftUI

struct GlassmorphismCard: View {
    var color: Color
    
    var body: some View {
        color
            .background(BlurEffectView(style: .systemMaterial))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 10)
    }
}

#Preview {
    GlassmorphismCard(color: .blue)
}
