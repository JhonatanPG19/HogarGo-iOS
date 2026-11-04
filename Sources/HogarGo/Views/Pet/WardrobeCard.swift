import SwiftUI

/// Tarjeta de un objeto del armario. Estados por prioridad:
/// bloqueado → puesto → sin comprar → comprado sin poner.
struct WardrobeCard: View {
    let entry: WardrobeEntry
    let level: Int
    let coins: Int
    let owned: Bool
    let equipped: Bool
    let onBuy: () -> Void
    let onToggle: () -> Void

    private var locked: Bool { level < entry.unlockLevel }

    var body: some View {
        VStack(spacing: 8) {
            Text(entry.emoji)
                .font(.system(size: 40))
                .opacity(locked ? 0.35 : 1)

            Text(entry.name)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(HogarGoColors.primaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(minHeight: 34)

            footer
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(equipped && !locked ? HogarGoColors.brandOrangeContainer : HogarGoColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    equipped && !locked ? HogarGoColors.brandOrangeDeep : HogarGoColors.borderSubtle,
                    lineWidth: equipped && !locked ? 2 : 1
                )
        )
    }

    @ViewBuilder
    private var footer: some View {
        if locked {
            HStack(spacing: 4) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 11, weight: .bold))
                Text(L10n.petLevelRequired(entry.unlockLevel))
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundStyle(HogarGoColors.secondaryText)
            .padding(.vertical, 8)
        } else if equipped {
            VStack(spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12, weight: .bold))
                    Text(L10n.petEquippedBadge)
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundStyle(HogarGoColors.brandOrangeDeep)
                pillButton(L10n.petRemove, filled: false, enabled: true, action: onToggle)
            }
        } else if !owned {
            pillButton(L10n.petBuy(entry.price), filled: true, enabled: coins >= entry.price, action: onBuy)
        } else {
            pillButton(L10n.petWear, filled: true, enabled: true, action: onToggle)
        }
    }

    private func pillButton(_ title: String, filled: Bool, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(filled ? Color.white : HogarGoColors.brandOrangeDeep)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(filled ? HogarGoColors.brandOrangeDeep : Color.clear)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(HogarGoColors.brandOrangeDeep, lineWidth: filled ? 0 : 1.5))
                .opacity(enabled ? 1 : 0.45)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}
