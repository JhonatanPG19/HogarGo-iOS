import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Barra superior con botón de cerrar/volver
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(HogarGoColors.primaryText)
                        .frame(width: 44, height: 44, alignment: .leading)
                }
                .buttonStyle(.plain)

                Spacer()

                Text(L10n.tr("Acerca de HogarGo", "About HogarGo"))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(HogarGoColors.primaryText)

                Spacer()

                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 6)
            .background(HogarGoColors.background)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Logo y versión
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(HogarGoColors.brandOrangeContainer.opacity(0.5))
                                .frame(width: 100, height: 100)
                            Text("🦊")
                                .font(.system(size: 52))
                        }

                        Text("HogarGo")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(HogarGoColors.primaryText)

                        Text(L10n.tr("Versión 1.0", "Version 1.0"))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(HogarGoColors.secondaryText)
                    }
                    .padding(.top, 10)

                    // Descripción
                    Text(L10n.tr("HogarGo convierte las tareas del hogar y las finanzas familiares en un juego en equipo. Cada familia tiene su propio hogar: sus integrantes reparten y completan tareas, cuidan a Zori (el zorro mascota) y juntos alcanzan sus metas de ahorro.", "HogarGo turns household chores and family finances into a team game. Each family has its own home: members share and complete tasks, take care of Zori (the fox pet) and reach their savings goals together."))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color(red: 45/255, green: 35/255, blue: 30/255))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)

                    // Sección: ¿Qué puedes hacer?
                    VStack(alignment: .leading, spacing: 12) {
                        Text(L10n.tr("¿QUÉ PUEDES HACER?", "WHAT CAN YOU DO?"))
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                            .foregroundStyle(HogarGoColors.primaryText)
                            .tracking(0.5)

                        FeatureItemRow(icon: "house.fill", title: L10n.tr("Tu hogar", "Your home"), description: L10n.tr("Crea un hogar o únete con un código; el administrador acepta a los nuevos integrantes.", "Create a home or join with a code; the admin accepts new members."))
                        FeatureItemRow(icon: "checklist", title: L10n.tr("Tareas y racha", "Tasks and streak"), description: L10n.tr("Reparte tareas, complétalas para ganar monedas y mantén tu racha diaria.", "Share tasks, complete them to earn coins and keep your daily streak."))
                        FeatureItemRow(icon: "banknote.fill", title: L10n.tr("Finanzas familiares", "Family finances"), description: L10n.tr("Registra gastos por categoría y crea varias metas de ahorro para la familia.", "Log expenses by category and create several savings goals for the family."))
                        FeatureItemRow(icon: "pawprint.fill", title: L10n.tr("Mascota Zori", "Pet Zori"), description: L10n.tr("Aliméntalo, juega con él y compra decoraciones en el armario con tus monedas.", "Feed it, play with it and buy decorations in the wardrobe with your coins."))
                        FeatureItemRow(icon: "calendar", title: L10n.tr("Calendario", "Calendar"), description: L10n.tr("Organiza eventos y mantén al día las fechas de pago de tus facturas.", "Organize events and keep your bill due dates up to date."))
                    }
                    .padding(16)
                    .background(HogarGoColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(HogarGoColors.borderSubtle, lineWidth: 1)
                    )

                    // Sección: Créditos del Equipo
                    VStack(alignment: .leading, spacing: 14) {
                        Text(L10n.tr("CRÉDITOS DEL EQUIPO", "TEAM CREDITS"))
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                            .foregroundStyle(HogarGoColors.primaryText)
                            .tracking(0.5)

                        Text(L10n.tr("Proyecto desarrollado para el curso de Desarrollo de Aplicaciones Móviles:", "Project built for the Mobile Application Development course:"))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(HogarGoColors.secondaryText)

                        VStack(spacing: 12) {
                            StudentCreditRow(
                                initial: "J",
                                name: "Jhonatan Palacios Gomez",
                                role: L10n.tr("Tareas, Inicio, notificaciones y consejos en línea (API)", "Tasks, Home, notifications and online tips (API)")
                            )

                            StudentCreditRow(
                                initial: "N",
                                name: "Nelson Rodrigo López Vidales",
                                role: L10n.tr("Finanzas, Mascota y Calendario", "Finance, Pet and Calendar")
                            )

                            StudentCreditRow(
                                initial: "I",
                                name: "Dana Isabella Romero Núñez",
                                role: L10n.tr("Inicio de sesión y creación del hogar", "Sign-in and home creation")
                            )
                        }
                    }
                    .padding(16)
                    .background(HogarGoColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(HogarGoColors.borderSubtle, lineWidth: 1)
                    )

                    // Pie de página
                    Text(L10n.tr("Hecho con ❤️ para el curso de Aplicaciones Móviles.", "Made with ❤️ for the Mobile Applications course."))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(HogarGoColors.secondaryText)
                        .padding(.top, 4)
                        .padding(.bottom, 24)
                }
                .padding(.horizontal, 20)
            }
        }
        .background(HogarGoColors.background)
    }
}

// MARK: - Subvistas de Acerca de
private struct FeatureItemRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(HogarGoColors.brandOrangeContainer)
                    .frame(width: 38, height: 38)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(HogarGoColors.primaryText)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 34/255, green: 26/255, blue: 21/255))
                Text(description)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(HogarGoColors.secondaryText)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct StudentCreditRow: View {
    let initial: String
    let name: String
    let role: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(HogarGoColors.brandOrange)
                    .frame(width: 40, height: 40)
                Text(initial)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 34/255, green: 26/255, blue: 21/255))
                Text(role)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(HogarGoColors.secondaryText)
            }
            Spacer()
        }
    }
}

