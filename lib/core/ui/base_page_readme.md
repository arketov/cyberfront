# BasePage (`lib/core/ui/base_page.dart`)

`BasePage` — базовый каркас для всех страниц приложения. Он даёт единый layout и поведение:

- общий `AppScaffold` (титул, actions, навигация по секциям)
- общий `CustomScrollView` со списком блоков
- “прибитый” (pinned) верхний тикер `InfiniteTickerBar`, который не скроллится
- автоматическая регенерация тикера при входе на страницу / возврате назад (через `RouteAware`)
- возможность добавить **статичные виджеты над списком** (например фильтры/поиск) через `buildTopBlocks()`
- нижний спейсер, чтобы контент не упирался в навбар/нижнюю панель

---

## Как устроена страница

Страница рисуется как `Stack`:

1) **Scrollable слой**: `CustomScrollView`
- (опционально) сверху резервируется место под pinned ticker
- дальше идёт `SliverList` из блоков

2) **Pinned слой**: `Positioned` тикер поверх скролла

Из-за этого тикер:
- всегда “прилипает” сверху
- не участвует в скролле
- не влияет на reflow списка (место под него резервируется слевером)

---

## API: что нужно переопределять в наследниках

### Обязательные методы

#### `AppSection get section`
Определяет текущую секцию приложения (для навигации и заголовка).

#### `List<TickerItem> buildTickerItems(BuildContext context)`
Возвращает список элементов тикера. `BasePage` вызывает этот метод при заходе на страницу и при возврате на неё.

#### `List<Widget> buildBlocks(BuildContext context)`
Основные блоки страницы, которые идут в скроллируемый список.

---

### Опциональные методы

#### `String get title`
По умолчанию `section.label`. Можно переопределить.

#### `bool get showTicker`
По умолчанию `true`. Выключает тикер и его reserved-space.

#### `List<Widget> buildTopBlocks(BuildContext context)`
По умолчанию пусто. Сюда кладёшь **статичные виджеты, которые должны быть над основным списком**:
- строка фильтров
- поиск
- табы
- “hero”-карточка/баннер
- предупреждение/плашка

Важно: это **обычные Widget’ы**, они будут вставлены в `SliverList` перед `buildBlocks()`.

#### `List<Widget> buildActions(BuildContext context)`
Кнопки в AppBar (иконки справа). По умолчанию пусто.

#### `EdgeInsetsGeometry contentPadding(BuildContext context)`
Padding для `SliverPadding`, по умолчанию `fromLTRB(0,10,0,0)`.

#### `double blockSpacing(BuildContext context)`
Вертикальный отступ между блоками. По умолчанию `12`.

#### `double get tickerHeight`
Высота тикера. По умолчанию `44`.

#### `double bottomSpacerHeight(BuildContext context)`
Высота нижнего спейсера после всех блоков (чтобы контент не прятался под нижнюю панель). По умолчанию `115`.

---

## Поведение тикера и RouteAware

`BasePage` подписывается на `appRouteObserver` и вызывает регенерацию тикера:

- `didPush()` — когда страницу открыли
- `didPopNext()` — когда вернулись на неё со следующей

Это сделано специально, чтобы тикер мог быть “живым” и меняться при каждом заходе (например случайные элементы).

---

## Пример страницы-наследника

```dart
class TracksPage extends BasePage {
  const TracksPage({super.key});

  @override
  AppSection get section => AppSection.tracks;

  @override
  List<TickerItem> buildTickerItems(BuildContext context) => const [
    TickerItem('ТРАССЫ'),
    TickerItem('КАРТА', accent: true),
    TickerItem('СУХО'),
    TickerItem('МОКРО'),
  ];

  @override
  List<Widget> buildTopBlocks(BuildContext context) => const [
    // например: фильтры/поиск над списком
    TracksFiltersBar(),
  ];

  @override
  List<Widget> buildBlocks(BuildContext context) => const [
    TracksMapCard(),
    TracksListCard(),
  ];

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(
      icon: const Icon(Icons.search),
      onPressed: () {},
    ),
  ];
}
