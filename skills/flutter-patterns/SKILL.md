---
name: flutter-patterns
description: Flutter development patterns covering widget composition, state management (Bloc/Cubit, Riverpod, Provider), navigation, theming, responsive design, performance optimization, and platform-specific code
---

# Flutter Development Patterns

Comprehensive Flutter patterns for building maintainable, performant, and scalable mobile applications.

## When to Activate

- Building Flutter mobile or web applications
- Implementing state management solutions
- Setting up navigation architecture
- Optimizing Flutter app performance
- Creating responsive and adaptive layouts
- Implementing custom animations and painters
- Managing platform-specific code
- Setting up theming and localization

## Widget Composition

### StatelessWidget vs StatefulWidget

```dart
// ✅ StatelessWidget - for immutable, presentation-only widgets
class UserCard extends StatelessWidget {
  const UserCard({
    super.key,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  final String name;
  final String email;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: avatarUrl != null
              ? NetworkImage(avatarUrl!)
              : null,
          child: avatarUrl == null ? Text(name[0]) : null,
        ),
        title: Text(name),
        subtitle: Text(email),
      ),
    );
  }
}

// ✅ StatefulWidget - for widgets that maintain mutable state
class CounterButton extends StatefulWidget {
  const CounterButton({super.key});

  @override
  State<CounterButton> createState() => _CounterButtonState();
}

class _CounterButtonState extends State<CounterButton> {
  int _count = 0;

  void _increment() {
    setState(() {
      _count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _increment,
      child: Text('Count: $_count'),
    );
  }
}

// ❌ AVOID: StatefulWidget for purely presentational widgets
class BadUserCard extends StatefulWidget {
  const BadUserCard({
    super.key,
    required this.name,
    required this.email,
  });

  final String name;
  final String email;

  @override
  State<BadUserCard> createState() => _BadUserCardState();
}
```

### Widget Composition Patterns

```dart
// ✅ Composition over inheritance
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.isDisabled = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isDisabled || isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : child,
    );
  }
}

// ✅ Builder pattern for complex widgets
class CardBuilder {
  Widget? _header;
  Widget? _body;
  Widget? _footer;
  EdgeInsets _padding = const EdgeInsets.all(16);

  CardBuilder header(Widget header) {
    _header = header;
    return this;
  }

  CardBuilder body(Widget body) {
    _body = body;
    return this;
  }

  CardBuilder footer(Widget footer) {
    _footer = footer;
    return this;
  }

  CardBuilder padding(EdgeInsets padding) {
    _padding = padding;
    return this;
  }

  Widget build() {
    return Card(
      child: Padding(
        padding: _padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_header != null) _header!,
            if (_body != null) Expanded(child: _body!),
            if (_footer != null) _footer!,
          ],
        ),
      ),
    );
  }
}

// Usage
final card = CardBuilder()
    .header(Text('Title'))
    .body(Text('Content'))
    .footer(ElevatedButton(onPressed: () {}, child: Text('Action')))
    .build();
```

### Const Constructors and Performance

```dart
// ✅ Use const constructors when possible
class AppLogo extends StatelessWidget {
  const AppLogo({super.key}); // const constructor

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.flutter_dash); // const widget
  }
}

// ✅ Const widgets are cached and reused
Widget build(BuildContext context) {
  return Column(
    children: const [
      AppLogo(), // Same instance reused
      AppLogo(), // Same instance reused
      AppLogo(), // Same instance reused
    ],
  );
}

// ✅ Extract const widgets to avoid rebuilds
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDynamicContent(), // Rebuilds
        const _StaticFooter(),   // Never rebuilds
      ],
    );
  }

  Widget _buildDynamicContent() {
    return Text(DateTime.now().toString());
  }
}

class _StaticFooter extends StatelessWidget {
  const _StaticFooter();

  @override
  Widget build(BuildContext context) {
    return const Text('© 2026 MyApp');
  }
}
```

## State Management

### Provider Pattern

```dart
// Model with ChangeNotifier
class CounterModel extends ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }

  void reset() {
    _count = 0;
    notifyListeners();
  }
}

// Setup Provider
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CounterModel(),
      child: const MyApp(),
    ),
  );
}

// Consume with Consumer
class CounterDisplay extends StatelessWidget {
  const CounterDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CounterModel>(
      builder: (context, counter, child) {
        return Text('Count: ${counter.count}');
      },
    );
  }
}

// Consume with Provider.of
class CounterButton extends StatelessWidget {
  const CounterButton({super.key});

  @override
  Widget build(BuildContext context) {
    // listen: false prevents unnecessary rebuilds
    final counter = Provider.of<CounterModel>(context, listen: false);

    return ElevatedButton(
      onPressed: counter.increment,
      child: const Text('Increment'),
    );
  }
}

// Multiple providers
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CounterModel()),
        ChangeNotifierProvider(create: (_) => UserModel()),
        Provider(create: (_) => ApiService()),
      ],
      child: const MyApp(),
    ),
  );
}

// When to use Provider:
// - Simple state management needs
// - Learning Flutter state management
// - Small to medium applications
// - When you need built-in support (comes with Flutter)
```

### Bloc/Cubit Pattern

```dart
// Define events
abstract class CounterEvent {}
class Increment extends CounterEvent {}
class Decrement extends CounterEvent {}
class Reset extends CounterEvent {}

// Define state
class CounterState {
  final int count;
  final bool isLoading;

  const CounterState({
    required this.count,
    this.isLoading = false,
  });

  CounterState copyWith({int? count, bool? isLoading}) {
    return CounterState(
      count: count ?? this.count,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Bloc implementation
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterState(count: 0)) {
    on<Increment>(_onIncrement);
    on<Decrement>(_onDecrement);
    on<Reset>(_onReset);
  }

  void _onIncrement(Increment event, Emitter<CounterState> emit) {
    emit(state.copyWith(count: state.count + 1));
  }

  void _onDecrement(Decrement event, Emitter<CounterState> emit) {
    emit(state.copyWith(count: state.count - 1));
  }

  void _onReset(Reset event, Emitter<CounterState> emit) {
    emit(const CounterState(count: 0));
  }
}

// Cubit implementation (simpler than Bloc)
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
  void reset() => emit(0);
}

// Setup BlocProvider
void main() {
  runApp(
    BlocProvider(
      create: (_) => CounterBloc(),
      child: const MyApp(),
    ),
  );
}

// Consume with BlocBuilder
class CounterDisplay extends StatelessWidget {
  const CounterDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CounterBloc, CounterState>(
      builder: (context, state) {
        return Text('Count: ${state.count}');
      },
    );
  }
}

// Consume with BlocConsumer (builder + listener)
class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CounterBloc, CounterState>(
      listener: (context, state) {
        if (state.count == 10) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You reached 10!')),
          );
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            Text('Count: ${state.count}'),
            ElevatedButton(
              onPressed: () => context.read<CounterBloc>().add(Increment()),
              child: const Text('Increment'),
            ),
          ],
        );
      },
    );
  }
}

// When to use Bloc/Cubit:
// - Complex state management needs
// - Predictable state transitions
// - Time-travel debugging required
// - Large applications with many states
// - Teams familiar with Redux/MVI patterns
```

### Riverpod Pattern

```dart
// Provider definitions
final counterProvider = StateProvider<int>((ref) => 0);

final userProvider = FutureProvider<User>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getUser();
});

final filteredUsersProvider = Provider<List<User>>((ref) {
  final users = ref.watch(usersProvider);
  final filter = ref.watch(filterProvider);
  return users.where((user) => user.name.contains(filter)).toList();
});

// StateNotifier for complex state
class TodoListNotifier extends StateNotifier<List<Todo>> {
  TodoListNotifier() : super([]);

  void addTodo(String title) {
    state = [...state, Todo(id: DateTime.now().toString(), title: title)];
  }

  void removeTodo(String id) {
    state = state.where((todo) => todo.id != id).toList();
  }

  void toggleTodo(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          todo.copyWith(isCompleted: !todo.isCompleted)
        else
          todo,
    ];
  }
}

final todoListProvider = StateNotifierProvider<TodoListNotifier, List<Todo>>(
  (ref) => TodoListNotifier(),
);

// Setup Riverpod
void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// Consume with ConsumerWidget
class CounterDisplay extends ConsumerWidget {
  const CounterDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return Text('Count: $count');
  }
}

// Consume with Consumer
class CounterButton extends StatelessWidget {
  const CounterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return ElevatedButton(
          onPressed: () => ref.read(counterProvider.notifier).state++,
          child: const Text('Increment'),
        );
      },
    );
  }
}

// Async data with AsyncValue
class UserProfile extends ConsumerWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return userAsync.when(
      data: (user) => Text(user.name),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}

// When to use Riverpod:
// - Modern, compile-safe state management
// - Need better testing capabilities
// - Want to avoid BuildContext for state
// - Complex dependency injection needs
// - Provider patterns but with improvements
```

## Navigation Patterns

### Navigator 2.0 with go_router

```dart
// Define routes
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'users/:userId',
          builder: (context, state) {
            final userId = state.pathParameters['userId']!;
            return UserPage(userId: userId);
          },
          routes: [
            GoRoute(
              path: 'edit',
              builder: (context, state) {
                final userId = state.pathParameters['userId']!;
                return EditUserPage(userId: userId);
              },
            ),
          ],
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
  ],
  redirect: (context, state) {
    final isLoggedIn = // Check auth state
    final isLoginRoute = state.matchedLocation == '/login';

    if (!isLoggedIn && !isLoginRoute) {
      return '/login';
    }
    if (isLoggedIn && isLoginRoute) {
      return '/';
    }
    return null; // No redirect
  },
  errorBuilder: (context, state) => ErrorPage(error: state.error),
);

// Setup MaterialApp with router
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      theme: ThemeData.light(),
    );
  }
}

// Navigate programmatically
void _navigateToUser(BuildContext context, String userId) {
  context.go('/users/$userId');
}

void _navigateToUserEdit(BuildContext context, String userId) {
  context.push('/users/$userId/edit');
}

void _goBack(BuildContext context) {
  context.pop();
}

// Query parameters
GoRoute(
  path: '/search',
  builder: (context, state) {
    final query = state.uri.queryParameters['q'] ?? '';
    return SearchPage(query: query);
  },
),

// Navigate with query params
context.go('/search?q=flutter');

// Named routes
final router = GoRouter(
  routes: [
    GoRoute(
      name: 'home',
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      name: 'user',
      path: '/users/:userId',
      builder: (context, state) => UserPage(
        userId: state.pathParameters['userId']!,
      ),
    ),
  ],
);

// Navigate by name
context.goNamed('user', pathParameters: {'userId': '123'});

// Bottom navigation with go_router
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }
}
```

## Theming

### Theme Configuration

```dart
// Define theme data
final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.light,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 16),
    bodyMedium: TextStyle(fontSize: 14),
  ),
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
);

final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.dark,
  ),
  textTheme: lightTheme.textTheme,
);

// Apply theme
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system, // or ThemeMode.light, ThemeMode.dark
      home: const HomePage(),
    );
  }
}

// Access theme in widgets
class ThemedWidget extends StatelessWidget {
  const ThemedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      color: colorScheme.surface,
      child: Text(
        'Themed Text',
        style: textTheme.displayMedium?.copyWith(
          color: colorScheme.primary,
        ),
      ),
    );
  }
}

// Custom theme extensions
@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    required this.success,
    required this.warning,
    required this.danger,
  });

  final Color success;
  final Color warning;
  final Color danger;

  @override
  CustomColors copyWith({
    Color? success,
    Color? warning,
    Color? danger,
  }) {
    return CustomColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

// Add extension to theme
final theme = ThemeData(
  extensions: <ThemeExtension<dynamic>>[
    const CustomColors(
      success: Colors.green,
      warning: Colors.orange,
      danger: Colors.red,
    ),
  ],
);

// Use custom theme extension
final customColors = Theme.of(context).extension<CustomColors>()!;
Container(color: customColors.success);
```

## Responsive Design

### LayoutBuilder Pattern

```dart
class ResponsiveWidget extends StatelessWidget {
  const ResponsiveWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return _buildMobileLayout();
        } else if (constraints.maxWidth < 1200) {
          return _buildTabletLayout();
        } else {
          return _buildDesktopLayout();
        }
      },
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        const Header(),
        Expanded(child: Content()),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        const Sidebar(width: 200),
        Expanded(
          child: Column(
            children: [
              const Header(),
              Expanded(child: Content()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        const Sidebar(width: 300),
        Expanded(
          child: Column(
            children: [
              const Header(),
              Expanded(
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Content()),
                    const Expanded(flex: 1, child: RightPanel()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Responsive breakpoints helper
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1200;
  static const double desktop = 1800;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile &&
      MediaQuery.of(context).size.width < tablet;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tablet;
}

// MediaQuery responsive sizing
class ResponsivePadding extends StatelessWidget {
  const ResponsivePadding({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final padding = width < 600 ? 16.0 : width < 1200 ? 24.0 : 32.0;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: child,
    );
  }
}

// Adaptive widgets for different platforms
Widget _buildAdaptiveButton(BuildContext context) {
  if (Theme.of(context).platform == TargetPlatform.iOS) {
    return CupertinoButton(
      onPressed: () {},
      child: const Text('iOS Button'),
    );
  }
  return ElevatedButton(
    onPressed: () {},
    child: const Text('Material Button'),
  );
}
```

## Platform-Specific Code

### Platform Detection

```dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

// Check platform
if (Platform.isAndroid) {
  // Android-specific code
} else if (Platform.isIOS) {
  // iOS-specific code
} else if (kIsWeb) {
  // Web-specific code
}

// Platform channels for native code
class BatteryLevel {
  static const platform = MethodChannel('com.example.app/battery');

  static Future<int> getBatteryLevel() async {
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      return result;
    } on PlatformException catch (e) {
      print("Failed to get battery level: '${e.message}'.");
      return -1;
    }
  }
}

// Native Android (Kotlin)
// class MainActivity: FlutterActivity() {
//   private val CHANNEL = "com.example.app/battery"
//
//   override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//     super.configureFlutterEngine(flutterEngine)
//     MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
//       .setMethodCallHandler { call, result ->
//         if (call.method == "getBatteryLevel") {
//           val batteryLevel = getBatteryLevel()
//           result.success(batteryLevel)
//         }
//       }
//   }
// }

// Conditional imports
import 'platform_stub.dart'
    if (dart.library.io) 'platform_mobile.dart'
    if (dart.library.html) 'platform_web.dart';

// platform_stub.dart
class PlatformInfo {
  static String getPlatformName() => 'Unknown';
}

// platform_mobile.dart
import 'dart:io';
class PlatformInfo {
  static String getPlatformName() => Platform.operatingSystem;
}

// platform_web.dart
class PlatformInfo {
  static String getPlatformName() => 'Web';
}
```

## Asset Management

### Asset Configuration

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/images/
    - assets/images/icons/
    - assets/data/
    - assets/fonts/

  fonts:
    - family: Roboto
      fonts:
        - asset: assets/fonts/Roboto-Regular.ttf
        - asset: assets/fonts/Roboto-Bold.ttf
          weight: 700
```

### Loading Assets

```dart
// Load image asset
Image.asset('assets/images/logo.png')

// Load image with size
Image.asset(
  'assets/images/logo.png',
  width: 100,
  height: 100,
  fit: BoxFit.cover,
)

// Load JSON asset
Future<Map<String, dynamic>> loadJsonAsset() async {
  final String jsonString = await rootBundle.loadString('assets/data/config.json');
  return jsonDecode(jsonString);
}

// Load text file
Future<String> loadTextAsset() async {
  return await rootBundle.loadString('assets/data/readme.txt');
}

// Network image with caching
CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
)

// AssetImage for decoration
Container(
  decoration: const BoxDecoration(
    image: DecorationImage(
      image: AssetImage('assets/images/background.jpg'),
      fit: BoxFit.cover,
    ),
  ),
)

// SVG assets (with flutter_svg package)
SvgPicture.asset(
  'assets/images/icon.svg',
  width: 24,
  height: 24,
  color: Colors.blue,
)
```

## Localization

### Setup Localization

```yaml
# pubspec.yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.18.0

flutter:
  generate: true
```

```yaml
# l10n.yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

### ARB Files

```json
// lib/l10n/app_en.arb
{
  "@@locale": "en",
  "appTitle": "My App",
  "@appTitle": {
    "description": "The title of the application"
  },
  "welcomeMessage": "Welcome, {name}!",
  "@welcomeMessage": {
    "description": "Welcome message with name parameter",
    "placeholders": {
      "name": {
        "type": "String",
        "example": "John"
      }
    }
  },
  "itemCount": "{count, plural, =0{No items} =1{1 item} other{{count} items}}",
  "@itemCount": {
    "description": "Number of items with plural forms",
    "placeholders": {
      "count": {
        "type": "int",
        "example": "5"
      }
    }
  }
}

// lib/l10n/app_es.arb
{
  "@@locale": "es",
  "appTitle": "Mi Aplicación",
  "welcomeMessage": "¡Bienvenido, {name}!",
  "itemCount": "{count, plural, =0{Sin artículos} =1{1 artículo} other{{count} artículos}}"
}
```

### Using Localization

```dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('fr'),
      ],
      home: const HomePage(),
    );
  }
}

// Use in widgets
class LocalizedWidget extends StatelessWidget {
  const LocalizedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Text(l10n.appTitle),
        Text(l10n.welcomeMessage('John')),
        Text(l10n.itemCount(5)),
      ],
    );
  }
}

// Change locale dynamically
void changeLocale(BuildContext context, Locale locale) {
  // Using a state management solution
  context.read<LocaleModel>().setLocale(locale);
}
```

## Performance Optimization

### List Optimization

```dart
// ✅ Use ListView.builder for large lists
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(title: Text(items[index]));
  },
)

// ✅ Use ListView.separated for lists with dividers
ListView.separated(
  itemCount: items.length,
  itemBuilder: (context, index) => ListTile(title: Text(items[index])),
  separatorBuilder: (context, index) => const Divider(),
)

// ✅ Use const widgets when possible
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return const ListTile(
      leading: Icon(Icons.star), // const
      trailing: Icon(Icons.arrow_forward), // const
      title: Text('Static Text'), // const
    );
  },
)

// ✅ Use keys for list items that can be reordered
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(
      key: ValueKey(items[index].id),
      title: Text(items[index].name),
    );
  },
)

// ❌ AVOID: Building entire list at once
Column(
  children: items.map((item) => ListTile(title: Text(item))).toList(),
)
```

### Widget Optimization

```dart
// ✅ Use RepaintBoundary for expensive widgets
RepaintBoundary(
  child: ComplexChart(data: data),
)

// ✅ Cache expensive computations
class ExpensiveWidget extends StatelessWidget {
  const ExpensiveWidget({super.key, required this.data});

  final List<int> data;

  @override
  Widget build(BuildContext context) {
    // Cache the result
    final sortedData = useMemoized(() => data.sorted(), [data]);

    return ListView.builder(
      itemCount: sortedData.length,
      itemBuilder: (context, index) {
        return Text('${sortedData[index]}');
      },
    );
  }
}

// ✅ Split large build methods
class LargeWidget extends StatelessWidget {
  const LargeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildContent(),
        _buildFooter(),
      ],
    );
  }

  Widget _buildHeader() => const _Header();
  Widget _buildContent() => const _Content();
  Widget _buildFooter() => const _Footer();
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) => const Text('Header');
}

// ✅ Use AutomaticKeepAliveClientMixin for TabBarView
class MyTabView extends StatefulWidget {
  const MyTabView({super.key});

  @override
  State<MyTabView> createState() => _MyTabViewState();
}

class _MyTabViewState extends State<MyTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required!
    return const Text('Tab content preserved');
  }
}
```

### Image Optimization

```dart
// ✅ Resize images appropriately
Image.asset(
  'assets/images/large.jpg',
  width: 100,
  height: 100,
  cacheWidth: 100,  // Decode to exact size
  cacheHeight: 100,
)

// ✅ Use precacheImage for critical images
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  precacheImage(
    const AssetImage('assets/images/splash.jpg'),
    context,
  );
}

// ✅ Compress images during build
// Use tools like:
// - flutter_image_compress
// - ImageMagick
// - TinyPNG
```

### Async Optimization

```dart
// ✅ Use FutureBuilder for one-time async data
FutureBuilder<User>(
  future: fetchUser(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return Text(snapshot.data!.name);
    }
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    return const CircularProgressIndicator();
  },
)

// ✅ Use StreamBuilder for continuous data
StreamBuilder<int>(
  stream: counterStream,
  initialData: 0,
  builder: (context, snapshot) {
    return Text('Count: ${snapshot.data}');
  },
)

// ✅ Cancel subscriptions properly
class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = stream.listen((data) {
      // Handle data
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container();
}
```

## Custom Painters

### Basic CustomPainter

```dart
class CirclePainter extends CustomPainter {
  CirclePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

// Usage
CustomPaint(
  size: const Size(100, 100),
  painter: CirclePainter(color: Colors.blue),
)

// Complex painter
class ChartPainter extends CustomPainter {
  ChartPainter({required this.data});

  final List<double> data;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final stepWidth = size.width / (data.length - 1);

    for (var i = 0; i < data.length; i++) {
      final x = i * stepWidth;
      final y = size.height - (data[i] * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    for (var i = 0; i < data.length; i++) {
      final x = i * stepWidth;
      final y = size.height - (data[i] * size.height);
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}

// Gradient painter
class GradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = const LinearGradient(
      colors: [Colors.blue, Colors.purple],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

## Animations

### Implicit Animations

```dart
// AnimatedContainer
AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  width: isExpanded ? 200 : 100,
  height: isExpanded ? 200 : 100,
  color: isExpanded ? Colors.blue : Colors.red,
  child: const Center(child: Text('Tap me')),
)

// AnimatedOpacity
AnimatedOpacity(
  opacity: isVisible ? 1.0 : 0.0,
  duration: const Duration(milliseconds: 500),
  child: const Text('Fading text'),
)

// AnimatedPositioned (inside Stack)
Stack(
  children: [
    AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      left: isLeft ? 0 : 100,
      top: 50,
      child: Container(width: 50, height: 50, color: Colors.blue),
    ),
  ],
)

// AnimatedCrossFade
AnimatedCrossFade(
  duration: const Duration(milliseconds: 300),
  firstChild: const Icon(Icons.favorite_border),
  secondChild: const Icon(Icons.favorite),
  crossFadeState: isFavorited
      ? CrossFadeState.showSecond
      : CrossFadeState.showFirst,
)

// TweenAnimationBuilder
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0, end: 1),
  duration: const Duration(seconds: 2),
  builder: (context, value, child) {
    return Opacity(
      opacity: value,
      child: Transform.scale(
        scale: value,
        child: child,
      ),
    );
  },
  child: const Text('Animated Text'),
)
```

### Explicit Animations

```dart
class ExplicitAnimationExample extends StatefulWidget {
  const ExplicitAnimationExample({super.key});

  @override
  State<ExplicitAnimationExample> createState() =>
      _ExplicitAnimationExampleState();
}

class _ExplicitAnimationExampleState extends State<ExplicitAnimationExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Transform.scale(
            scale: _animation.value,
            child: child,
          ),
        );
      },
      child: const Text('Animated'),
    );
  }
}

// Multiple animations
class MultiAnimationExample extends StatefulWidget {
  const MultiAnimationExample({super.key});

  @override
  State<MultiAnimationExample> createState() => _MultiAnimationExampleState();
}

class _MultiAnimationExampleState extends State<MultiAnimationExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _colorAnimation = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(_controller);

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: Container(
              width: 100,
              height: 100,
              color: _colorAnimation.value,
            ),
          ),
        );
      },
    );
  }
}

// Hero animation (page transitions)
// Page 1
Hero(
  tag: 'imageHero',
  child: Image.network('https://example.com/image.jpg'),
)

// Page 2
Hero(
  tag: 'imageHero',
  child: Image.network('https://example.com/image.jpg'),
)
// Hero will automatically animate between pages
```

## Best Practices

**DO:**
- Use const constructors whenever possible
- Prefer StatelessWidget over StatefulWidget when no state is needed
- Choose the right state management solution for your app complexity
- Extract widgets into separate classes for reusability
- Use ListView.builder for long or infinite lists
- Implement proper error handling in async operations
- Use keys when list items can be reordered
- Dispose controllers and close streams in dispose()
- Use MediaQuery and LayoutBuilder for responsive layouts
- Optimize images with appropriate sizes
- Follow Material Design or Cupertino guidelines consistently
- Test on multiple screen sizes and platforms

**DON'T:**
- Create setState calls in build methods
- Ignore memory leaks (always dispose resources)
- Use global keys unnecessarily
- Nest widgets too deeply (extract to separate widgets)
- Build large lists without builders
- Perform expensive operations in build methods
- Use print() in production (use proper logging)
- Forget to handle loading and error states
- Hard-code strings (use localization)
- Ignore platform differences

## Summary

Flutter patterns provide a robust foundation for mobile development:

1. **Widget Composition** - StatelessWidget vs StatefulWidget, const constructors
2. **State Management** - Provider for simple apps, Bloc/Cubit for complex apps, Riverpod for modern approach
3. **Navigation** - go_router for declarative routing and deep linking
4. **Theming** - Consistent design with ThemeData and custom extensions
5. **Responsive Design** - LayoutBuilder and MediaQuery for adaptive UIs
6. **Platform-Specific** - Platform channels and conditional imports
7. **Asset Management** - Efficient loading of images, fonts, and data files
8. **Localization** - Multi-language support with ARB files
9. **Performance** - List optimization, widget caching, image compression
10. **Custom Painters** - Canvas drawing for custom graphics
11. **Animations** - Implicit for simple, explicit for complex animations

Remember: Choose patterns that match your app's complexity. Start simple and scale up as needed.
