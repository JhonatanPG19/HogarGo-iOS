import SwiftUI
import UIKit

/// Zorro Zori con los objetos puestos. Los objetos se colocan con fracciones del tamaño del avatar.
struct ZoriAvatarView: View {
    /// Ids de los objetos puestos.
    let equippedIds: Set<String>
    var size: CGFloat = 200

    private var equipped: [WardrobeEntry] {
        WardrobeCatalog.items.filter { equippedIds.contains($0.id) }
    }

    var body: some View {
        ZStack {
            // 1) Objetos detrás del zorro
            ForEach(equipped.filter(\.behind)) { item in
                itemView(item)
            }

            // 2) Zorro
            foxImage
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)

            // 3) Objetos delante
            ForEach(equipped.filter { !$0.behind }) { item in
                itemView(item)
            }
        }
        .frame(width: size, height: size)
    }

    /// El PNG vive en Resources (no en un catálogo de assets), así que `Image(_:bundle:)` no lo encuentra:
    /// se carga con `UIImage(named:in:)` desde el bundle del paquete.
    private var foxImage: Image {
        if let ui = UIImage(named: "img_zori_fox", in: Bundle.module, with: nil) {
            return Image(uiImage: ui)
        }
        return Image(systemName: "pawprint.fill")
    }

    private func itemView(_ item: WardrobeEntry) -> some View {
        let side = item.size * size
        return Text(item.emoji)
            .font(.system(size: side * 0.85))
            .frame(width: side, height: side)
            .position(x: item.centerX * size, y: item.centerY * size)
            .frame(width: size, height: size)
    }
}
