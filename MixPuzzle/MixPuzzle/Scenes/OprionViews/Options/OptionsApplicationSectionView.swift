//
//  OptionsApplicationSectionView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 07.11.2026.
//

import SwiftUI

/// Секция приложения: вибрация и переход к статистике
struct OptionsApplicationSectionView: View {
	@Binding var isUseVibration: Bool
	let onStatistics: () -> Void

	private let vibration = String(localized: "Vibration", comment: "Name cell in options")
	private let statistic = String(localized: "Statistic")

	var body: some View {
		VStack(spacing: 0) {
			Toggle(isOn: self.$isUseVibration) {
				Label {
					Text(self.vibration)
						.foregroundStyle(Color.mm_text_primary)
				} icon: {
					Image(systemName: "waveform.path")
						.foregroundStyle(Color.mm_text_secondary)
				}
			}
			.tint(Color.mm_green)
			.frame(minHeight: 56)
			// Статистика использует Swift Charts, поэтому доступна с iOS 16
			if #available(iOS 16.0, *) {
				Divider()
				Button(action: self.onStatistics) {
					HStack(spacing: 12) {
						Label {
							Text(self.statistic)
								.foregroundStyle(Color.mm_text_primary)
						} icon: {
							Image(systemName: "chart.bar.xaxis")
								.foregroundStyle(Color.mm_text_secondary)
						}
						Spacer()
						Image(systemName: "chevron.right")
							.font(.footnote.weight(.semibold))
							.foregroundStyle(Color.mm_tint_icons)
					}
					.frame(minHeight: 56)
					.contentShape(Rectangle())
				}
				.buttonStyle(.plain)
			}
		}
		.padding(.horizontal, 16)
		.background(Color.mm_background_tertiary)
		.clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
	}
}

@available(iOS 17.0, *)
#Preview {
	@Previewable @State var isUseVibration = true
	return OptionsApplicationSectionView(isUseVibration: $isUseVibration, onStatistics: { debugPrint("statistics") })
		.padding()
		.background(Color.mm_background_secondary)
}
