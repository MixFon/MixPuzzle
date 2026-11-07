//
//  SettingsPreviewLayout.swift
//  MixPuzzle
//
//  Created by Михаил Фокин on 07.11.2026.
//

import SwiftUI

/// Каркас экрана настройки с 3D-превью: сцена уходит под статус-бар и шапку,
/// кнопки шапки лежат «на стекле» поверх сцены, снизу — панель настроек
/// со скруглёнными верхними углами. Панель можно тянуть за граббер с заголовком:
/// она встаёт в одно из трёх положений, а сцена занимает всё место над ней.
/// В свёрнутом положении видны только граббер и заголовок панели.
struct SettingsPreviewLayout<Preview: View, Panel: View, Trailing: View>: View {
	let title: String
	/// Заголовок панели под граббером
	let panelTitle: String
	/// Кнопка справа в шапке (у экранов настроек — «Сохранить»)
	private let trailing: Trailing
	private let preview: Preview
	private let panel: Panel
	/// Можно ли менять высоту панели. Если нет — граббера и жеста нет,
	/// а панель всегда в среднем положении (для экранов без сцены, где больше места не нужно).
	private let isPanelResizable: Bool

	/// Ключ, под которым запоминается последнее положение панели (общее для всех экранов с превью)
	private static var detentKey: String { "settings.preview.panel.detent" }
	/// Текущее положение панели. Именно @State, а не @AppStorage:
	/// изменения @AppStorage не подхватывают withAnimation, и панель перескакивала бы без анимации.
	@State private var detent: SettingsPanelDetent
	/// Смещение пальца во время перетаскивания (вниз — положительное)
	@State private var dragOffset: CGFloat = 0

	init(
		title: String,
		panelTitle: String,
		isPanelResizable: Bool = true,
		@ViewBuilder trailing: () -> Trailing,
		@ViewBuilder preview: () -> Preview,
		@ViewBuilder panel: () -> Panel
	) {
		self.title = title
		self.panelTitle = panelTitle
		self.isPanelResizable = isPanelResizable
		self.trailing = trailing()
		self.preview = preview()
		self.panel = panel()
		let storedDetent = UserDefaults.standard.string(forKey: Self.detentKey).flatMap(SettingsPanelDetent.init(rawValue:))
		self._detent = State(initialValue: storedDetent ?? .medium)
	}

	var body: some View {
		GeometryReader { geometry in
			let heights = SettingsPanelHeights(
				total: geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom,
				safeTop: geometry.safeAreaInsets.top,
				safeBottom: geometry.safeAreaInsets.bottom
			)
			let panelHeight = self.isPanelResizable
				? heights.clamp(heights.height(for: self.detent) - self.dragOffset)
				: heights.clamp(heights.medium)
			ZStack(alignment: .top) {
				VStack(spacing: 0) {
					self.preview
						// Превью уходит под шапку: сообщаем ему, сколько места сверху занято
						.environment(\.settingsHeaderInset, heights.safeTop + SettingsPanelHeights.headerHeight)
						.frame(maxWidth: .infinity)
						.frame(height: max(0, heights.total - panelHeight))
						.clipped()
					self.panelView(height: panelHeight, heights: heights)
				}
				// Сцена занимает и место под статус-баром, панель доходит до низа экрана
				.ignoresSafeArea(edges: [.top, .bottom])
				// Шапка учитывает safe area, поэтому остаётся под статус-баром
				GlassNavigationHeader(title: self.title, trailing: self.trailing)
					.padding(.horizontal)
					.padding(.vertical, 8)
			}
			.frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
		}
		.background(Color.black)
	}

	private func panelView(height: CGFloat, heights: SettingsPanelHeights) -> some View {
		// 0 — панель свёрнута, 1 — открыта хотя бы на 48 pt: контент плавно проявляется, а не обрезается
		let contentVisibility = min(max((height - heights.collapsed) / 48, 0), 1)
		return VStack(spacing: 0) {
			if self.isPanelResizable {
				self.handle(heights: heights)
			} else {
				self.panelTitleView
					// На месте граббера — такой же отступ сверху, чтобы заголовок стоял там же
					.padding(.top, SettingsPanelHeights.grabberHeight)
			}
			VStack(spacing: 16) {
				self.panel
			}
			.padding(.top, 4)
			.padding(.horizontal, 16)
			// Контент заканчивается над индикатором «домой»
			.padding(.bottom, heights.safeBottom)
			.frame(maxHeight: .infinity, alignment: .top)
			.opacity(contentVisibility)
			.allowsHitTesting(contentVisibility > 0.5)
			.accessibilityHidden(contentVisibility == 0)
		}
		.frame(height: height, alignment: .top)
		.background(Color.mm_background_tertiary)
		.clipShape(UnevenTopRoundedRectangle(radius: 28))
		.background(Color.black)
	}

	private var panelTitleView: some View {
		Text(self.panelTitle)
			.font(.headline)
			.foregroundStyle(Color.mm_text_primary)
			.lineLimit(1)
			.minimumScaleFactor(0.8)
			.padding(.horizontal, 16)
			.frame(height: SettingsPanelHeights.titleHeight, alignment: .top)
			.frame(maxWidth: .infinity)
			.accessibilityAddTraits(.isHeader)
	}
	
	/// Граббер с заголовком панели: тянуть — менять высоту, тап — свернуть/вернуть в середину.
	/// Жест висит только здесь, чтобы не мешать прокрутке, ползункам и вращению сцены.
	private func handle(heights: SettingsPanelHeights) -> some View {
		VStack(spacing: 0) {
			Capsule()
				.fill(Color.mm_text_secondary.opacity(0.5))
				.frame(width: 36, height: 5)
				.frame(height: SettingsPanelHeights.grabberHeight)
			self.panelTitleView
		}
			.frame(maxWidth: .infinity)
			.contentShape(Rectangle())
			.onTapGesture {
				self.setDetent(self.detent == .collapsed ? .medium : .collapsed)
			}
			.gesture(
				// Смещение считаем в координатах экрана: ручка едет вместе с пальцем,
				// и в локальных координатах смещение «обнулялось» бы, а панель дёргалась туда-обратно
				DragGesture(coordinateSpace: .global)
					.onChanged { value in
						self.dragOffset = value.translation.height
					}
					.onEnded { value in
						// Учитываем скорость: быстрый взмах «докидывает» панель дальше
						let predicted = heights.clamp(heights.height(for: self.detent) - value.predictedEndTranslation.height)
						self.setDetent(heights.nearestDetent(to: predicted))
					}
			)
			.accessibilityElement()
			.accessibilityLabel(self.panelTitle)
			.accessibilityAddTraits(.isButton)
			.accessibilityAdjustableAction { direction in
				switch direction {
				case .increment:
					self.setDetent(self.detent.larger)
				case .decrement:
					self.setDetent(self.detent.smaller)
				@unknown default:
					break
				}
			}
	}

	private func setDetent(_ detent: SettingsPanelDetent) {
		withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
			self.detent = detent
			self.dragOffset = 0
		}
		UserDefaults.standard.set(detent.rawValue, forKey: Self.detentKey)
	}
}

extension SettingsPreviewLayout where Trailing == SaveCircleButton {
	/// Экран настроек: справа в шапке — круглая кнопка «Сохранить»
	init(
		title: String,
		panelTitle: String,
		onSave: @escaping () -> Void,
		@ViewBuilder preview: () -> Preview,
		@ViewBuilder panel: () -> Panel
	) {
		self.init(title: title, panelTitle: panelTitle, trailing: { SaveCircleButton(action: onSave) }, preview: preview, panel: panel)
	}
}

/// Высота области сверху превью, которую закрывает стеклянная шапка (включая safe area).
/// Нужна превью, у которых контент не должен уходить под шапку (например, поле ручного ввода).
private struct SettingsHeaderInsetKey: EnvironmentKey {
	static let defaultValue: CGFloat = 0
}

extension EnvironmentValues {
	var settingsHeaderInset: CGFloat {
		get { self[SettingsHeaderInsetKey.self] }
		set { self[SettingsHeaderInsetKey.self] = newValue }
	}
}

/// Положения панели настроек
enum SettingsPanelDetent: String, CaseIterable {
	case collapsed
	case medium
	case expanded

	var larger: SettingsPanelDetent {
		switch self {
		case .collapsed: return .medium
		case .medium, .expanded: return .expanded
		}
	}

	var smaller: SettingsPanelDetent {
		switch self {
		case .expanded: return .medium
		case .medium, .collapsed: return .collapsed
		}
	}
}

/// Высоты панели для каждого положения при заданной высоте экрана
struct SettingsPanelHeights {
	/// Высота всего экрана, включая safe area
	let total: CGFloat
	let safeTop: CGFloat
	let safeBottom: CGFloat

	/// Высота шапки под safe area: кнопки 44 pt и отступы по 8 pt
	static let headerHeight: CGFloat = 60
	/// Высота области граббера (полоска по центру)
	static let grabberHeight: CGFloat = 20
	/// Высота строки заголовка под граббером
	static let titleHeight: CGFloat = 36

	/// Свёрнуто: видны только граббер и заголовок панели
	var collapsed: CGFloat { self.safeBottom + Self.grabberHeight + Self.titleHeight }
	/// Середина: чуть меньше половины экрана
	var medium: CGFloat { max(self.collapsed, self.total * 0.45) }
	/// Развёрнуто: над панелью остаются шапка и полоска сцены
	var expanded: CGFloat { max(self.medium, self.total - self.safeTop - Self.headerHeight - 120) }

	func height(for detent: SettingsPanelDetent) -> CGFloat {
		switch detent {
		case .collapsed: return self.collapsed
		case .medium: return self.medium
		case .expanded: return self.expanded
		}
	}

	/// Ограничивает высоту панели положениями «свёрнуто…развёрнуто» и высотой экрана.
	/// В первом проходе раскладки экран бывает нулевой высоты: тогда свёрнутая панель
	/// не помещается, и без ограничения высота сцены ушла бы в минус.
	func clamp(_ height: CGFloat) -> CGFloat {
		guard height.isFinite else { return max(0, min(self.collapsed, self.total)) }
		return max(0, min(max(height, self.collapsed), self.expanded, self.total))
	}

	func nearestDetent(to height: CGFloat) -> SettingsPanelDetent {
		SettingsPanelDetent.allCases.min(by: { abs(self.height(for: $0) - height) < abs(self.height(for: $1) - height) }) ?? .medium
	}
}

/// Шапка экрана поверх сцены: «Назад», заголовок и кнопка действия на стеклянной подложке.
/// Пустое место между элементами не перехватывает касания, поэтому сцену можно вращать и под шапкой.
private struct GlassNavigationHeader<Trailing: View>: View {
	let title: String
	let trailing: Trailing

	@Environment(\.dismiss) private var dismiss

	var body: some View {
		HStack(spacing: 12) {
			Button {
				self.dismiss()
			} label: {
				Image(systemName: "arrow.left")
					.font(.body.weight(.semibold))
					.foregroundStyle(Color.mm_text_primary)
					.frame(width: 44, height: 44)
					.glassBackground(in: Circle())
			}
			.buttonStyle(.plain)
			.accessibilityLabel("Back".localized)
			Spacer(minLength: 0)
			Text(self.title)
				.font(.headline)
				.foregroundStyle(Color.mm_text_primary)
				.lineLimit(1)
				.padding(.horizontal, 16)
				.frame(height: 36)
				.glassBackground(in: Capsule())
			Spacer(minLength: 0)
			self.trailing
		}
	}
}

/// Круглая кнопка сохранения с галочкой на стекле, подкрашенном акцентным цветом
struct SaveCircleButton: View {
	let action: () -> Void

	var body: some View {
		Button(action: self.action) {
			Image(systemName: "checkmark")
				.font(.body.weight(.bold))
				.foregroundStyle(Color.white)
				.frame(width: 44, height: 44)
				.glassBackground(in: Circle(), tint: Color.mm_tint_secondary)
		}
		.buttonStyle(.plain)
		.accessibilityLabel("Save".localized)
	}
}

extension View {
	/// Стеклянная подложка: Liquid Glass на iOS 26+, размытие на более старых версиях
	@ViewBuilder
	func glassBackground<S: Shape>(in shape: S, tint: Color? = nil) -> some View {
		if #available(iOS 26.0, *) {
			self.glassEffect(Glass.regular.tint(tint).interactive(), in: shape)
		} else {
			self
				.background(tint.map { $0.opacity(0.85) } ?? Color.clear, in: shape)
				.background(.ultraThinMaterial, in: shape)
				.overlay(shape.stroke(Color.white.opacity(0.25), lineWidth: 0.5))
				.shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 2)
		}
	}
}

/// Группа строк внутри панели настроек
struct SettingsPanelGroup<Content: View>: View {
	@ViewBuilder let content: Content

	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			self.content
		}
		.padding(16)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(Color.mm_background_secondary)
		.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
	}
}

/// Скругление только верхних углов (UnevenRoundedRectangle доступен с iOS 16)
struct UnevenTopRoundedRectangle: Shape {
	let radius: CGFloat

	func path(in rect: CGRect) -> Path {
		Path(UIBezierPath(
			roundedRect: rect,
			byRoundingCorners: [.topLeft, .topRight],
			cornerRadii: CGSize(width: self.radius, height: self.radius)
		).cgPath)
	}
}

@available(iOS 17.0, *)
#Preview {
	@Previewable @State var isOn = true
	@Previewable @State var value = 30.0
	return SettingsPreviewLayout(title: "Preview", panelTitle: "Panel", onSave: { debugPrint("save") }) {
		Color.indigo
			.frame(height: 300)
	} panel: {
		SettingsPanelGroup {
			ToggleCellView(icon: "star", text: "Toggle", isOn: $isOn)
			SliderCellView(title: "Slider", range: 0...100, value: $value)
		}
	}
}
