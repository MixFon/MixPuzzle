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
//			ScrollView {
//				Text("Головоломка не всегда имеет решение.")
//					.font(.title2)
//					.bold()
//				Text("Не все комбинации пятнашки разрешимы. Это зависит от количества инверсий и положения пустой клетки.")
//					.multilineTextAlignment(.center)
//					.padding()
			//			}
			ScrollView {
				VStack(alignment: .leading, spacing: 8) {
					Text("Алгоритм проверки")
						.font(.title3)
						.bold()
						.padding(.bottom, 8)
						.frame(maxWidth: .infinity)
						.multilineTextAlignment(.center)
					
					Text("Головоломка может не иметь решения, то есть может попасться состояние поля, из которого невозможно перейти к состоянию решения, не нарушая правил игры. Для проверки существования решения головоломки необходимо сравнивать четности инверсий.")
						.font(.callout)
					
					Group {
						Text("Инверсия — количество пар элементов, которые стоят перед элементами, имеющими меньшее значение, чем они сами.")
					}
					.font(.callout)

					Divider()
					
					Group {
						Text("1. Обход матрицы \"змейкой\" (бустрофедоном)")
							.font(.headline)
						Text("Создается массив элементов матрицы, обходимой змейкой:")
						VStack(alignment: .leading, spacing: 4) {
							Text("→ Четные строки: слева направо")
							Text("← Нечетные строки: справа налево")
						}
						Text("Работает для матриц любого размера (четных и нечетных).")
					}
					.font(.callout)

					Group {
						Text("2. Четность инверсий")
							.font(.headline)
						Text("Горизонтальные и вертикальные перемещения пустой клетки (0) не влияют на общую четность инверсий.")
						Text("Это ключевое свойство для проверки существования решения.")
					}
					.font(.callout)

					Group {
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
					.font(.callout)
				}
				.padding()
			}
			Spacer()
		}
		.background(Color.mm_background_secondary)
    }
}

#Preview {
    InversionView()
}
