# MixPuzzle — 3D-пятнашки на SceneKit

iOS-игра «пятнашки» (sliding puzzle) с 3D-кубиками. UI на SwiftUI, игровые сцены — SceneKit
(`SCNView`, обёрнутый в `UIViewRepresentable`). Автор — Михаил Фокин (MixFon).

## Сборка

- Проект: `MixPuzzle/MixPuzzle.xcodeproj`, одна цель и схема `MixPuzzle`. Тестов нет.
- Bundle ID `ru.mixfon.MixPuzzle`, версия `1.1.1`, iOS 15+, iPhone + iPad
  (`SUPPORTED_PLATFORMS` включает и macOS), Swift 6.0.
- Единственная зависимость — SPM-пакет **MFPuzzle** (`git@github.com:MixFon/MFPuzzle.git`, ветка `main`).
  Из него приходят `Matrix`, `MatrixElement`, `Grid`, `Board`, `GridPoint`, `Compass`, `Direction`,
  `Solution`, `Puzzle` (A*, эвристика `.manhattan`), `Checker`, `MatrixWorker`, `Transporter`.
  Логику решения и генерации матриц правят там, а не здесь.
- Сборка из консоли:
  ```bash
  xcodebuild -project MixPuzzle/MixPuzzle.xcodeproj -scheme MixPuzzle -destination 'generic/platform=iOS Simulator' build
  ```
- В `project.pbxproj` часто бывает локально изменённый `DEVELOPMENT_TEAM` — не коммитить его случайно.
- Проект собирается на Xcode 27 в строгом режиме Swift 6. В SDK блок `SCNAction.customAction` и
  `completionHandler` у `runAction` объявлены `Sendable` и вызываются на потоке рендера, поэтому в них нельзя
  передавать замыкания или вложенные функции, привязанные к `@MainActor` (а все воркеры — `@MainActor`).
- Сборка из песочницы Claude: `xcodebuild` не может разрешить SPM-пакеты, потому что нет SSH-ключей и запрещена
  запись в `/var/folders/.../T` и `/C`. Работает так: склонировать MFPuzzle и MFStructs по HTTPS (репозитории публичные,
  ревизии взять из `Package.resolved`), собрать их модули через `swiftc -emit-module`, затем скомпилировать
  исходники приложения через `swiftc -sdk <iphonesimulator> -target arm64-apple-ios15.0-simulator -swift-version 6
  -disable-sandbox -wmo -c`. Флаг `-disable-sandbox` нужен для макросов (`#Preview`, `@State`).
  Список файлов брать из `project.pbxproj` (`/* X.swift in Sources */`). `-typecheck` ловит не всё:
  ошибки region isolation видны только при `-c`.

## Структура (`MixPuzzle/MixPuzzle/`)

| Папка | Что там |
|---|---|
| `MixPuzzleApp.swift` | `@main`, создаёт `Dependency` и показывает `MenuView` |
| `Dependency/` | Ручной DI-контейнер: собирает все хранилища и воркеры |
| `Workers/` | Сервисы: 3D-объекты, свет, игра, статистика, хранение |
| `Storages/` | Настройки (куб, игра, свет, астероиды), читаются из `NSUbiquitousKeyValueStore` |
| `Scenes/` | Экраны SwiftUI и SceneKit-сцены |
| `Extentions/` | Расширения `Color`/`UIColor` (hex), `Compass`, `Solution`, `String`, `View` |
| `Colors/` | Палитра `Color.mm_*` |
| `Localisation/Localizable.xcstrings` | Исходный язык — английский, перевод на русский |
| `Assets.xcassets` | Иконка и PBR-текстуры кубиков (`TerrazzoSlab018` по умолчанию и др.) |

### Экраны (`Scenes/`)

- `Menu/` — главное меню: `MenuScene` (3D) + `MenuView`, переходы через `fullScreenCover` на Start, Options и поиск решения.
- `StartViews/Start/` — **сама игра**:
  - `StartView` + `StartSceneModel` — набор Combine-`PassthroughSubject` для общения UI со сценой
    (решение, меню, следующий уровень, регенерация, показ пути, тряска, блокировка кнопок).
  - `StartScene` — `UIViewRepresentable` со `SCNView`: обработка тапов (hit test → кубик или 3D-текст меню),
    проверка победы, сохранение при уходе в фон.
  - `StartFactory` — собирает `StartScene` в трёх вариантах: игра, только показ матрицы, проигрывание пути.
  - `StartState`: `.game` / `.menu` / `.solution`.
- `FindSolutionViews/` — «найти решение»: ручной ввод матрицы (`ManualFillingView`) → проверка
  инверсий (`InversionView`, объяснение разрешимости) → `LoadingView` (асинхронный A*
  `searchSolutionWithHeap`, можно отменить) → `VisualizationSolutionView` (проигрывание ходов по компасам).
- `OprionViews/` (опечатка в названии папки — так исторически) — настройки: куб (с 3D-превью), астероиды,
  свет, вибрация, выбор уровня (размер 3…10), выбор целевой раскладки, статистика (iOS 16+, Swift Charts).
- `Common/` — общие компоненты: `NavigationBar`, `MixButtonStyle`, `Snackbar`, `LimitedTextField`, кнопка «назад».
- `Draft/Test.swift` — пустой черновик.

### Воркеры (`Workers/`)

- `BoxesWorker` — сетка 3D-кубиков: создание, позиции, анимация хода на место нуля, тряска,
  позиция камеры, перевод хода ↔ `Compass`. Создаётся отдельно на каждую сцену (через `StartFactory`), в `Workers` его нет.
- `CubeWorker` / `ImageWorker` / `MaterialsWorker` — геометрия кубика (фаска), картинка с номером, материалы и текстуры.
- `LightsWorker`, `AsteroidsWorker`, `RotationWorker` — освещение, астероиды на орбите, вращение.
- `TextNodeWorker` — 3D-текст финального меню (`FinalMenuText`: next / retry).
- `GameWorker` — состояние партии: текущая и целевая матрицы, генерация с исправлением чётности,
  смена уровня, история ходов (компасы), статистика.
- `StatisticsWorker` — ходы, ошибки, победы, регенерации; хранится как JSON (`Decoder`).
- `FeedbackGenerator` — вибрация (actor).
- `_Keeper` — интерфейс хранения строк. Сейчас используется `UbiquitousKeyValueStoreWorker` (iCloud KV);
  `FileWorker` — старая реализация на файлах, в DI не подключена.

## Как устроен код

- Протоколы называются с подчёркиванием: `_GameWorker`, `_BoxesWorker`, `_Dependency` и т. д.
  Рядом с реализацией обычно лежит `Mock…` для SwiftUI Preview (`MockDependency` — в `MenuView.swift`,
  `MockWorkers` — в `Workers.swift`).
- Зависимости передаются явно через `_Dependency` в инициализаторы View.
- Навигация — через `ObservableObject`-роутеры с `@Published` флагами и `fullScreenCover`.
- Связь SwiftUI ↔ SceneKit — только через Combine-subject'ы в `StartSceneModel`/`MenuViewModel`.
- Комментарии и документация в коде — на русском. Стиль отступов смешанный (табы и пробелы) — подстраиваться под файл.
- Нужна совместимость с iOS 15: новые API оборачивать в `#available` (так сделано со статистикой).
- Swift 6: на SceneKit стоит `@preconcurrency import`, многое помечено `@MainActor`.

## Данные и хранение

- Всё лежит в `NSUbiquitousKeyValueStore` (синхронизация через iCloud), entitlements в `MixPuzzle.entitlements`.
- Ключи для каждого размера доски: `matrix.mix.NxN`, `compasses.mix.NxN`, `statistics.mix.<solution>.NxN`.
- Выбранная цель (`solution.mix`) хранится в `UserDefaults.standard`, а не в iCloud.
- Настройки: `settings.cube.*`, `settings.game.*`, `settings.light.*`, `settings.asteroids.*`.
  Значения «по умолчанию» получаются из нуля (`0 → 3`, `0 → 200` и т. п.), а некоторые bool-флаги хранятся
  инвертированными (`isUseVibration`, `isMotionEnabled`, `isShadowEnabled`): `false` в хранилище означает «включено».
- Уровень = размер доски, от 3 до `availableLevel = 10`.
- Целевые раскладки (`Solution` из MFPuzzle): classic, snail (улитка), boustrophedon (змейка).

## Мёртвые файлы (лежат в репозитории, но не входят в цель)

- `FreeGame/FreeGame.swift` — пустой.
- `Scenes/OprionViews/SettingsAsteroids/SettingsAsteroids.swift` — копия `SettingsAsteroidsView.swift`.
  Если добавить его в цель, появятся дублирующиеся типы.
