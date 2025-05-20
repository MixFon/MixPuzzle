//
//  InversionView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 19.05.2025.
//

import SwiftUI

struct InversionView: View {
	var body: some View {
		VStack {
			NavigationBar(title: "Inversions".localized, tralingView: nil)
				.padding(.horizontal)
				.padding(.top)
			Text("Алгоритм проверки")
				.font(.title3)
				.bold()
				.padding(.bottom, 8)
				.frame(maxWidth: .infinity)
				.multilineTextAlignment(.center)
			
			TabView {
				self.pageOne
				self.pageTwo
				self.pageThree
				self.pageFour
			}
			.font(.callout)
			.foregroundStyle(Color.mm_text_primary)
			.tabViewStyle(.page(indexDisplayMode: .always))
			.indexViewStyle(.page(backgroundDisplayMode: .interactive))
			.frame(maxHeight: 300)
			Spacer()
		}
		.background(Color.mm_background_secondary)
    }
	
	private var pageOne: some View {
		VStack {
			VStack(alignment: .leading, spacing: 4) {
				Text("Головоломка может не иметь решения, то есть может попасться состояние поля, из которого невозможно перейти к состоянию решения, не нарушая правил игры. Для проверки существования решения головоломки необходимо сравнивать четности инверсий.")
				Text("Инверсия — количество пар элементов, которые стоят перед элементами, имеющими меньшее значение, чем они сами.")
			}
			.padding()
			.background(
				RoundedRectangle(cornerRadius: 16)
					.fill(Color.mm_background_primary)
					.overlay(
						RoundedRectangle(cornerRadius: 16)
							.stroke(Color.mm_divider_opaque, lineWidth: 2)
					)
			)
			Spacer()
		}
	}
	
	private var pageTwo: some View {
		VStack {
			VStack(alignment: .leading, spacing: 8) {
				Text("1. Обход матрицы \"змейкой\" (бустрофедоном)")
					.font(.headline)
				VStack(alignment: .leading, spacing: 4) {
					Text("Создается массив элементов матрицы, обходимой змейкой:")
					Text("→ Четные строки: слева направо")
					Text("← Нечетные строки: справа налево")
					Text("Работает для матриц любого размера (четных и нечетных).")
				}
			}
			.padding()
			.background(
				RoundedRectangle(cornerRadius: 16)
					.fill(Color.mm_background_primary)
					.overlay(
						RoundedRectangle(cornerRadius: 16)
							.stroke(Color.mm_divider_opaque, lineWidth: 2)
					)
			)
			Spacer()
		}
	}
	
	private var pageThree: some View {
		VStack {
			VStack(alignment: .leading, spacing: 8) {
				Text("2. Четность инверсий")
					.font(.headline)
				VStack(alignment: .leading, spacing: 4) {
					Text("Горизонтальные и вертикальные перемещения пустой клетки (0) не влияют на общую четность инверсий.")
					Text("Это ключевое свойство для проверки существования решения.")
				}
			}
			.padding()
			.background(
				RoundedRectangle(cornerRadius: 16)
					.fill(Color.mm_background_primary)
					.overlay(
						RoundedRectangle(cornerRadius: 16)
							.stroke(Color.mm_divider_opaque, lineWidth: 2)
					)
			)
			Spacer()
		}
		
	}
	
	private var pageFour: some View {
		VStack {
			VStack(alignment: .leading, spacing: 8) {
				Text("3. Проверка решения")
					.font(.headline)
				VStack(alignment: .leading, spacing: 4) {
					Text("• Вычислить четность инверсий текущего состояния")
					Text("• Вычислить четность инверсий целевого состояния")
					Text("• Сравнить:")
					Text("  - ✅ Четности совпадают → решение существует")
					Text("  - ❌ Четности разные → решение невозможно")
				}
			}
			.padding()
			.background(
				RoundedRectangle(cornerRadius: 16)
					.fill(Color.mm_background_primary)
					.overlay(
						RoundedRectangle(cornerRadius: 16)
							.stroke(Color.mm_divider_opaque, lineWidth: 2)
					)
			)
			Spacer()
		}
	}
}
	

#Preview {
	InversionView()
}
