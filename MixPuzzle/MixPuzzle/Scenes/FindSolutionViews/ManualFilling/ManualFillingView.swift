//
//  ManualFillingView.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 25.05.2024.
//

import SwiftUI
import MFPuzzle

final class ManualFillingRouter: ObservableObject {
	@Published var toLoading = false
	@Published var toInversion = false
	@Published var toVisualizationSolution = false
}

/// Ручной ввод матрицы. Устроен как экраны настроек с превью:
/// сверху поле со строкой состояния, снизу панель «Расстановка» с параметрами и клавиатурой.
struct ManualFillingView: View {
	private let dependency: _Dependency

	@StateObject private var model: ManualFillingModel
	@StateObject private var router = ManualFillingRouter()
	@StateObject private var startSceneModel = StartSceneModel()

	@State private var fillingMatrix: Matrix = [[]]
	@State private var matrixSolution: Matrix = [[]]

	init(dependency: _Dependency) {
		self.dependency = dependency
		self._model = StateObject(wrappedValue: ManualFillingModel(
			checker: dependency.checker,
			matrixWorker: dependency.workers.matrixWorker
		))
	}

	var body: some View {
		// Сцены здесь нет, поэтому высоту панели не меняем
		SettingsPreviewLayout(title: "Manual filling".localized, panelTitle: "mix.manual.panel".localized, isPanelResizable: false) {
			SolveButton(isEnabled: self.model.isSolvable) {
				self.solve()
			}
		} preview: {
			ManualFillingBoardArea(model: self.model) {
				self.router.toInversion = true
			}
		} panel: {
			ScrollView {
				VStack(spacing: 14) {
					ManualFillingParametersView(
						sizes: self.model.sizes,
						size: self.model.size,
						onSize: { self.model.setSize($0) },
						solution: self.$model.solution
					)
					ManualFillingKeypadView(
						size: self.model.size,
						isUsed: { self.model.isUsed($0) },
						onPut: { self.model.put($0) },
						onErase: { self.model.erase() }
					)
				}
				.padding(.bottom, 24)
			}
		}
		.fullScreenCover(isPresented: $router.toLoading, onDismiss: { self.router.toVisualizationSolution = !self.startSceneModel.compasses.isEmpty }) {
			LoadingView(matrix: fillingMatrix, puzzle: self.dependency.createPuzzle(), matrixTarger: matrixSolution) { compasses in
				self.startSceneModel.compasses = compasses ?? []
				self.router.toLoading = false
			}
		}
		.fullScreenCover(isPresented: $router.toVisualizationSolution) {
			VisualizationSolutionView(matrix: fillingMatrix, dependency: dependency, startSceneModel: self.startSceneModel)
		}
		.fullScreenCover(isPresented: $router.toInversion) {
			InversionView(checker: self.dependency.checker, matrixWorker: self.dependency.workers.matrixWorker)
		}
	}

	/// Запускает поиск решения. Кнопка активна, только когда расстановка решаема.
	private func solve() {
		guard self.model.isSolvable else { return }
		self.fillingMatrix = self.model.matrix
		self.matrixSolution = self.model.targetMatrix
		self.router.toLoading = true
	}
}

/// Область над панелью: строка состояния и поле. Отступает сверху на высоту стеклянной шапки.
private struct ManualFillingBoardArea: View {
	@ObservedObject var model: ManualFillingModel
	let onInfo: () -> Void

	@Environment(\.settingsHeaderInset) private var headerInset

	var body: some View {
		let status = self.model.status
		VStack(spacing: 16) {
			ManualFillingStatusView(
				status: status,
				swapValues: self.swapValues(for: status),
				onShuffle: {
					withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
						self.model.shuffle()
					}
				},
				onInfo: self.onInfo,
				onFix: {
					withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
						self.model.fixParity()
					}
				}
			)
			ManualFillingBoardView(
				size: self.model.size,
				cells: self.model.cells,
				selectedIndex: self.model.selectedIndex,
				errorIndices: self.model.duplicateIndices,
				highlightedIndices: self.model.highlightedIndices,
				onSelect: { self.model.select($0) }
			)
		}
		.padding(.top, self.headerInset + 4)
		.padding(.horizontal, 16)
		.padding(.bottom, 20)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(Color.black)
	}

	/// Числа в клетках, которые предлагается поменять местами (для текста подсказки)
	private func swapValues(for status: ManualFillingModel.Status) -> (MatrixElement, MatrixElement)? {
		guard case let .unsolvable(first, second) = status,
			  let a = self.model.cells[first], let b = self.model.cells[second] else { return nil }
		return (a, b)
	}
}

/// Кнопка «Решить» в шапке: подкрашенное стекло, когда решение есть, и приглушённая — когда нет
private struct SolveButton: View {
	let isEnabled: Bool
	let action: () -> Void

	var body: some View {
		Button(action: self.action) {
			HStack(spacing: 6) {
				Image(systemName: "play.fill")
					.font(.footnote)
				Text("mix.manual.solve".localized)
					.font(.body.weight(.bold))
			}
			.foregroundStyle(self.isEnabled ? Color.white : Color.mm_text_secondary)
			.padding(.horizontal, 16)
			.frame(height: 44)
			.glassBackground(in: Capsule(), tint: self.isEnabled ? .mm_tint_secondary : nil)
		}
		.buttonStyle(.plain)
		.disabled(!self.isEnabled)
		.opacity(self.isEnabled ? 1 : 0.7)
		.animation(.easeInOut(duration: 0.2), value: self.isEnabled)
	}
}

struct SelectSizePicker<T: Hashable & CustomStringConvertible>: View {
	@Binding var selectedSize: T
	let numbersSize: [T]

	var body: some View {
		Picker("Choose the size", selection: $selectedSize) {
			ForEach(numbersSize, id: \.self) { size in
				Text("\(size.description)").tag(size)
			}
		}
		.pickerStyle(SegmentedPickerStyle())
	}
}

#Preview {
	let dependency = MockDependency()
	return ManualFillingView(dependency: dependency)
}
