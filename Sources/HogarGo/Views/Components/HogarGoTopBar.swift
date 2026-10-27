import SwiftUI

struct HogarGoTopBar: View {
    var onAvatarTap: () -> Void = {}
    var onGiftTap: () -> Void = {}

    var body: some View {
        HStack {
            // Avatar de usuario
            Button(action: onAvatarTap) {
                ZStack {
                    Circle()
                        .fill(HogarGoColors.surfaceContainer)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 34, height: 34)
                        .foregroundStyle(HogarGoColors.primaryText.opacity(0.8))
                }
                .overlay(
                    Circle()
                        .stroke(HogarGoColors.brandOrangeContainer, lineWidth: 2)
                )
            }
            .buttonStyle(.plain)

            Spacer()

            // Logotipo central
            Text("HogarGo")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(HogarGoColors.primaryText)

            Spacer()

            // Botón de recompensas / regalo
            Button(action: onGiftTap) {
                Image(systemName: "gift")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(HogarGoColors.primaryText)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(HogarGoColors.background)
    }
}

