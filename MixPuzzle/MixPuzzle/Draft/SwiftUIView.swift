import SwiftUI

struct AlertView: View {
	@State private var showActionSheet = false
	
	var body: some View {
		VStack {
			Button("Показать алерт") {
				showActionSheet = true
			}
			.actionSheet(isPresented: $showActionSheet) {
				ActionSheet(
					title: Text("Выберите действие"),
					message: Text("Что вы хотите сделать?"),
					buttons: [
						.default(Text("Построить"), action: {
							// Действие для кнопки "Построить"
							debugPrint("Построить выбрано")
						}),
						.default(Text("Повысить уровень"), action: {
							// Действие для кнопки "Повысить уровень"
							debugPrint("Повысить уровень выбрано")
						}),
						.default(Text("Выбрать другой тип"), action: {
							// Действие для кнопки "Выбрать другой тип"
							debugPrint("Выбрать другой тип выбрано")
						}),
						.cancel()
					]
				)
			}
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		AlertView()
	}
}
