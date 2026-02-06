---
name: dart-testing
description: Dart testing patterns with dart test package, including mocking with mockito, async testing, test coverage, TDD workflow, and integration testing strategies
---

# Dart Testing Patterns

Comprehensive Dart testing patterns covering the dart test package, mockito for mocking, async testing, test coverage, and TDD methodology for writing maintainable, reliable tests.

## When to Activate

- Writing new Dart classes or methods
- Adding test coverage to existing Dart code
- Setting up test frameworks for Dart projects
- Following TDD workflow in Dart applications
- Testing Flutter or server-side Dart applications
- Creating package tests for pub.dev

## Dart Test Package Basics

### Test Structure and Organization

```dart
// test/calculator_test.dart
import 'package:test/test.dart';
import 'package:my_package/calculator.dart';

void main() {
  // group - organizes related tests
  group('Calculator', () {
    // test - defines a single test case
    test('adds two numbers correctly', () {
      final calculator = Calculator();
      final result = calculator.add(2, 3);
      expect(result, equals(5));
    });

    test('subtracts two numbers correctly', () {
      final calculator = Calculator();
      final result = calculator.subtract(5, 3);
      expect(result, equals(2));
    });

    // Nested groups for better organization
    group('multiply', () {
      test('multiplies positive numbers', () {
        final calculator = Calculator();
        expect(calculator.multiply(3, 4), equals(12));
      });

      test('multiplies with zero', () {
        final calculator = Calculator();
        expect(calculator.multiply(5, 0), equals(0));
      });

      test('multiplies negative numbers', () {
        final calculator = Calculator();
        expect(calculator.multiply(-2, -3), equals(6));
      });
    });
  });
}
```

### setUp and tearDown Hooks

```dart
import 'package:test/test.dart';

void main() {
  group('Database', () {
    late Database database;

    // setUp runs before each test
    setUp(() {
      database = Database.connect();
      database.initialize();
    });

    // tearDown runs after each test
    tearDown(() {
      database.close();
    });

    test('inserts a record', () {
      final result = database.insert('users', {'name': 'Alice'});
      expect(result, isTrue);
    });

    test('queries records', () {
      database.insert('users', {'name': 'Alice'});
      final users = database.query('users');
      expect(users, hasLength(1));
    });
  });
}
```

### setUpAll and tearDownAll

```dart
void main() {
  group('API Tests', () {
    late HttpServer server;
    late ApiClient client;

    // setUpAll runs once before all tests in the group
    setUpAll(() async {
      server = await HttpServer.bind('localhost', 8080);
      client = ApiClient('http://localhost:8080');
    });

    // tearDownAll runs once after all tests in the group
    tearDownAll(() async {
      await client.close();
      await server.close();
    });

    // setUp/tearDown for per-test setup
    setUp(() {
      // Reset state before each test
      client.clearCache();
    });

    test('fetches user data', () async {
      final user = await client.getUser('1');
      expect(user.name, equals('Alice'));
    });

    test('handles 404 errors', () async {
      expect(
        () => client.getUser('nonexistent'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });
}
```

## Test Directory Structure

```
my_package/
├── lib/
│   ├── my_package.dart
│   └── src/
│       ├── models/
│       │   ├── user.dart
│       │   └── product.dart
│       ├── services/
│       │   ├── api_service.dart
│       │   └── auth_service.dart
│       └── utils/
│           └── validators.dart
├── test/
│   ├── models/
│   │   ├── user_test.dart
│   │   └── product_test.dart
│   ├── services/
│   │   ├── api_service_test.dart
│   │   └── auth_service_test.dart
│   ├── utils/
│   │   └── validators_test.dart
│   ├── integration/
│   │   └── user_flow_test.dart
│   └── test_helpers.dart
└── pubspec.yaml
```

### File Naming Conventions

```dart
// Source file: lib/src/services/user_service.dart
// Test file: test/services/user_service_test.dart

// Use _test.dart suffix for test files
// Mirror the lib/ directory structure in test/

// Test file example
// test/services/user_service_test.dart
import 'package:test/test.dart';
import 'package:my_package/src/services/user_service.dart';

void main() {
  test('UserService processes users', () {
    // Test implementation
  });
}
```

## Test Matchers

### Core Matchers

```dart
import 'package:test/test.dart';

void main() {
  group('Core Matchers', () {
    test('equality matchers', () {
      expect(2 + 2, equals(4));
      expect([1, 2, 3], equals([1, 2, 3]));
      expect({'a': 1}, equals({'a': 1}));

      // same() checks object identity
      final list = [1, 2, 3];
      expect(list, same(list));
      expect([1, 2, 3], isNot(same([1, 2, 3])));
    });

    test('boolean matchers', () {
      expect(true, isTrue);
      expect(false, isFalse);
      expect(1 < 2, isTrue);
      expect(null, isNull);
      expect('text', isNotNull);
    });

    test('numeric matchers', () {
      expect(5, greaterThan(3));
      expect(5, greaterThanOrEqualTo(5));
      expect(3, lessThan(5));
      expect(3, lessThanOrEqualTo(3));
      expect(3.14, closeTo(3.1, 0.1));
      expect(10, isPositive);
      expect(-5, isNegative);
      expect(0, isZero);
      expect(0, isNonZero);
    });

    test('string matchers', () {
      expect('hello world', contains('world'));
      expect('hello', startsWith('hel'));
      expect('world', endsWith('rld'));
      expect('test@example.com', matches(r'^\w+@\w+\.\w+$'));
      expect('HELLO', equalsIgnoringCase('hello'));
      expect('  text  ', equalsIgnoringWhitespace('text'));
    });

    test('collection matchers', () {
      expect([1, 2, 3], contains(2));
      expect([1, 2, 3], containsAll([1, 3]));
      expect([1, 2, 3], hasLength(3));
      expect([], isEmpty);
      expect([1], isNotEmpty);

      // unorderedEquals - order doesn't matter
      expect([3, 1, 2], unorderedEquals([1, 2, 3]));

      // containsAllInOrder - subset in order
      expect([1, 2, 3, 4], containsAllInOrder([1, 3, 4]));

      // everyElement - all elements match
      expect([2, 4, 6], everyElement(isEven));

      // anyElement - at least one matches
      expect([1, 2, 3], anyElement(greaterThan(2)));
    });

    test('type matchers', () {
      expect(42, isA<int>());
      expect('hello', isA<String>());
      expect([1, 2], isA<List<int>>());
      expect({'key': 'value'}, isA<Map<String, String>>());
    });

    test('map matchers', () {
      final map = {'name': 'Alice', 'age': 30};

      expect(map, containsPair('name', 'Alice'));
      expect(map, containsValue(30));
    });

    test('combining matchers', () {
      expect(5, allOf([greaterThan(3), lessThan(10)]));
      expect(5, anyOf([equals(5), equals(6)]));
      expect(5, isNot(equals(6)));
    });
  });
}
```

### Custom Matchers

```dart
import 'package:test/test.dart';

// Custom matcher for even numbers
class IsEven extends Matcher {
  @override
  bool matches(item, Map matchState) {
    return item is int && item % 2 == 0;
  }

  @override
  Description describe(Description description) {
    return description.add('an even number');
  }

  @override
  Description describeMismatch(
    item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    return mismatchDescription.add('$item is not even');
  }
}

// Convenience function
Matcher isEven() => IsEven();

// Custom matcher for valid email
class IsValidEmail extends Matcher {
  final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  bool matches(item, Map matchState) {
    return item is String && _emailRegex.hasMatch(item);
  }

  @override
  Description describe(Description description) {
    return description.add('a valid email address');
  }
}

Matcher isValidEmail() => IsValidEmail();

// Usage
void main() {
  test('custom matchers', () {
    expect(4, isEven());
    expect(7, isNot(isEven()));
    expect('test@example.com', isValidEmail());
    expect('invalid-email', isNot(isValidEmail()));
  });
}
```

## Exception and Error Testing

```dart
import 'package:test/test.dart';

void main() {
  group('Exception Testing', () {
    test('throws any exception', () {
      expect(() => throw Exception('error'), throwsException);
    });

    test('throws specific exception type', () {
      expect(() => throw FormatException(), throwsFormatException);
      expect(() => throw ArgumentError(), throwsArgumentError);
      expect(() => throw StateError('bad state'), throwsStateError);
      expect(() => throw UnsupportedError('not supported'), throwsUnsupportedError);
    });

    test('throws with type matcher', () {
      expect(() => throw CustomException('error'), throwsA(isA<CustomException>()));
    });

    test('throws with predicate', () {
      expect(
        () => throw ArgumentError('invalid value'),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('invalid'),
          ),
        ),
      );
    });

    test('throws with custom message check', () {
      expect(
        () => throw Exception('custom error'),
        throwsA(
          predicate((e) => e.toString().contains('custom error')),
        ),
      );
    });

    test('async function throws', () async {
      await expectLater(
        () async => throw Exception('async error'),
        throwsException,
      );
    });
  });
}

class CustomException implements Exception {
  final String message;
  CustomException(this.message);

  @override
  String toString() => 'CustomException: $message';
}
```

## Mocking with Mockito

### Setting Up Mockito

```yaml
# pubspec.yaml
dev_dependencies:
  test: ^1.24.0
  mockito: ^5.4.0
  build_runner: ^2.4.0
```

### Creating Mock Classes

```dart
// lib/src/services/user_service.dart
abstract class UserRepository {
  Future<User> getUser(String id);
  Future<void> saveUser(User user);
  Future<List<User>> getAllUsers();
}

// test/services/user_service_test.dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

// Generate mocks with build_runner
@GenerateNiceMocks([MockSpec<UserRepository>()])
import 'user_service_test.mocks.dart';

void main() {
  group('UserService', () {
    late MockUserRepository mockRepository;
    late UserService service;

    setUp(() {
      mockRepository = MockUserRepository();
      service = UserService(mockRepository);
    });

    test('getUser calls repository', () async {
      final user = User(id: '1', name: 'Alice');

      // Stub method call
      when(mockRepository.getUser('1'))
          .thenAnswer((_) async => user);

      final result = await service.getUser('1');

      expect(result.name, equals('Alice'));

      // Verify method was called
      verify(mockRepository.getUser('1')).called(1);
    });

    test('saveUser validates before saving', () async {
      final user = User(id: '1', name: '');

      expect(
        () => service.saveUser(user),
        throwsA(isA<ValidationException>()),
      );

      // Verify repository was never called
      verifyNever(mockRepository.saveUser(any));
    });
  });
}

// Run: dart run build_runner build
```

### Mockito Argument Matchers

```dart
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  group('Argument Matchers', () {
    late MockUserRepository repository;

    setUp(() {
      repository = MockUserRepository();
    });

    test('any matcher', () async {
      when(repository.getUser(any))
          .thenAnswer((_) async => User(id: '1', name: 'Alice'));

      final user = await repository.getUser('any-id');
      expect(user.name, equals('Alice'));

      verify(repository.getUser(any));
    });

    test('argThat with predicate', () async {
      when(repository.getUser(argThat(startsWith('user-'))))
          .thenAnswer((_) async => User(id: '1', name: 'Alice'));

      final user = await repository.getUser('user-123');
      expect(user.name, equals('Alice'));

      verify(repository.getUser(argThat(startsWith('user-'))));
    });

    test('captureThat for inspecting arguments', () async {
      when(repository.saveUser(any))
          .thenAnswer((_) async => {});

      final user = User(id: '1', name: 'Alice');
      await repository.saveUser(user);

      final captured = verify(repository.saveUser(captureAny)).captured;
      expect(captured.single, same(user));
    });

    test('different return values for different arguments', () async {
      when(repository.getUser('1'))
          .thenAnswer((_) async => User(id: '1', name: 'Alice'));
      when(repository.getUser('2'))
          .thenAnswer((_) async => User(id: '2', name: 'Bob'));

      final user1 = await repository.getUser('1');
      final user2 = await repository.getUser('2');

      expect(user1.name, equals('Alice'));
      expect(user2.name, equals('Bob'));
    });

    test('throwing exceptions', () {
      when(repository.getUser('invalid'))
          .thenThrow(NotFoundException('User not found'));

      expect(
        () => repository.getUser('invalid'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('sequential return values', () async {
      when(repository.getUser('1'))
          .thenAnswer((_) async => User(id: '1', name: 'Alice'))
          .thenAnswer((_) async => User(id: '1', name: 'Alice Updated'));

      final user1 = await repository.getUser('1');
      final user2 = await repository.getUser('1');

      expect(user1.name, equals('Alice'));
      expect(user2.name, equals('Alice Updated'));
    });
  });
}
```

### Verification with Mockito

```dart
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  group('Verification', () {
    late MockUserRepository repository;

    setUp(() {
      repository = MockUserRepository();
    });

    test('verify called once', () async {
      when(repository.getUser(any))
          .thenAnswer((_) async => User(id: '1', name: 'Alice'));

      await repository.getUser('1');

      verify(repository.getUser('1')).called(1);
    });

    test('verify called multiple times', () async {
      when(repository.getUser(any))
          .thenAnswer((_) async => User(id: '1', name: 'Alice'));

      await repository.getUser('1');
      await repository.getUser('1');
      await repository.getUser('1');

      verify(repository.getUser('1')).called(3);
    });

    test('verify never called', () {
      verifyNever(repository.getUser(any));
    });

    test('verify call order', () async {
      when(repository.getUser(any))
          .thenAnswer((_) async => User(id: '1', name: 'Alice'));
      when(repository.saveUser(any))
          .thenAnswer((_) async => {});

      await repository.getUser('1');
      await repository.saveUser(User(id: '1', name: 'Alice'));

      verifyInOrder([
        repository.getUser('1'),
        repository.saveUser(any),
      ]);
    });

    test('verifyNoMoreInteractions', () async {
      when(repository.getUser('1'))
          .thenAnswer((_) async => User(id: '1', name: 'Alice'));

      await repository.getUser('1');

      verify(repository.getUser('1'));
      verifyNoMoreInteractions(repository);
    });

    test('untilCalled for async waiting', () async {
      // Start async operation
      Future.delayed(Duration(milliseconds: 100), () {
        repository.getUser('1');
      });

      // Wait until method is called
      await untilCalled(repository.getUser('1'));

      verify(repository.getUser('1')).called(1);
    });
  });
}
```

## Async Testing Patterns

### Testing Futures

```dart
import 'package:test/test.dart';

void main() {
  group('Future Testing', () {
    test('async function returns correct value', () async {
      final result = await fetchData();
      expect(result, equals('data'));
    });

    test('async function with expectLater', () {
      expectLater(fetchData(), completion(equals('data')));
    });

    test('async function throws', () async {
      await expectLater(
        fetchDataWithError(),
        throwsA(isA<Exception>()),
      );
    });

    test('future completes successfully', () {
      expect(Future.value(42), completion(equals(42)));
    });

    test('future throws exception', () {
      expect(
        Future.error(Exception('error')),
        throwsException,
      );
    });

    test('multiple async operations', () async {
      final results = await Future.wait([
        fetchData(),
        fetchData(),
        fetchData(),
      ]);

      expect(results, hasLength(3));
      expect(results, everyElement(equals('data')));
    });

    test('async with timeout', () async {
      await expectLater(
        slowOperation().timeout(Duration(milliseconds: 100)),
        throwsA(isA<TimeoutException>()),
      );
    });
  });
}

Future<String> fetchData() async {
  await Future.delayed(Duration(milliseconds: 10));
  return 'data';
}

Future<void> fetchDataWithError() async {
  await Future.delayed(Duration(milliseconds: 10));
  throw Exception('error');
}

Future<void> slowOperation() async {
  await Future.delayed(Duration(seconds: 1));
}
```

### Testing Streams

```dart
import 'package:test/test.dart';

void main() {
  group('Stream Testing', () {
    test('stream emits expected values', () {
      final stream = Stream.fromIterable([1, 2, 3]);

      expect(stream, emitsInOrder([1, 2, 3]));
    });

    test('stream emits and completes', () {
      final stream = Stream.fromIterable([1, 2, 3]);

      expect(
        stream,
        emitsInOrder([
          1,
          2,
          3,
          emitsDone,
        ]),
      );
    });

    test('stream emits error', () {
      final stream = Stream.error(Exception('error'));

      expect(stream, emitsError(isA<Exception>()));
    });

    test('async stream processing', () async {
      final stream = countStream(3);
      final values = <int>[];

      await for (final value in stream) {
        values.add(value);
      }

      expect(values, equals([1, 2, 3]));
    });

    test('expectLater with streams', () async {
      final stream = countStream(3);

      await expectLater(
        stream,
        emitsInOrder([1, 2, 3, emitsDone]),
      );
    });

    test('stream emits any of values', () {
      final stream = Stream.fromIterable([1, 2, 3]);

      expect(stream, emits(anyOf([1, 2, 3])));
    });

    test('stream with transformations', () {
      final stream = Stream.fromIterable([1, 2, 3])
          .map((n) => n * 2);

      expect(stream, emitsInOrder([2, 4, 6]));
    });

    test('broadcast stream with multiple listeners', () {
      final controller = StreamController<int>.broadcast();
      final stream = controller.stream;

      expect(stream, emitsInOrder([1, 2, 3]));
      expect(stream, emitsInOrder([1, 2, 3]));

      controller.add(1);
      controller.add(2);
      controller.add(3);
      controller.close();
    });

    test('stream controller lifecycle', () async {
      final controller = StreamController<int>();

      final future = expectLater(
        controller.stream,
        emitsInOrder([1, 2, 3, emitsDone]),
      );

      controller.add(1);
      controller.add(2);
      controller.add(3);
      await controller.close();

      await future;
    });
  });
}

Stream<int> countStream(int max) async* {
  for (int i = 1; i <= max; i++) {
    await Future.delayed(Duration(milliseconds: 10));
    yield i;
  }
}
```

### Testing with FakeAsync

```dart
import 'package:test/test.dart';
import 'package:fake_async/fake_async.dart';

void main() {
  group('FakeAsync Testing', () {
    test('controls time progression', () {
      fakeAsync((async) {
        var callbackExecuted = false;

        Future.delayed(Duration(seconds: 5), () {
          callbackExecuted = true;
        });

        // Time hasn't elapsed yet
        expect(callbackExecuted, isFalse);

        // Advance time by 5 seconds
        async.elapse(Duration(seconds: 5));

        // Now callback has executed
        expect(callbackExecuted, isTrue);
      });
    });

    test('tests periodic timers', () {
      fakeAsync((async) {
        var count = 0;

        Timer.periodic(Duration(seconds: 1), (timer) {
          count++;
          if (count >= 3) timer.cancel();
        });

        expect(count, equals(0));

        async.elapse(Duration(seconds: 1));
        expect(count, equals(1));

        async.elapse(Duration(seconds: 1));
        expect(count, equals(2));

        async.elapse(Duration(seconds: 1));
        expect(count, equals(3));
      });
    });

    test('flushMicrotasks', () {
      fakeAsync((async) {
        var executed = false;

        scheduleMicrotask(() {
          executed = true;
        });

        expect(executed, isFalse);

        async.flushMicrotasks();

        expect(executed, isTrue);
      });
    });

    test('flushTimers', () {
      fakeAsync((async) {
        var count = 0;

        Timer(Duration(seconds: 1), () => count++);
        Timer(Duration(seconds: 2), () => count++);
        Timer(Duration(seconds: 3), () => count++);

        expect(count, equals(0));

        async.flushTimers();

        expect(count, equals(3));
      });
    });
  });
}
```

## Test Coverage

### Running Coverage

```bash
# Install coverage package
dart pub global activate coverage

# Run tests with coverage
dart run coverage:test_with_coverage

# Generate HTML report
genhtml -o coverage/html coverage/lcov.info

# Open coverage report
open coverage/html/index.html
```

### Coverage Configuration

```yaml
# dart_test.yaml
coverage:
  enabled: true
  # Exclude generated files
  exclude:
    - '**/*.g.dart'
    - '**/*.freezed.dart'
    - 'lib/generated/**'
  # Set minimum coverage threshold
  minimum: 80
```

### Coverage Expectations

| Code Type | Target Coverage |
|-----------|----------------|
| Critical business logic | 100% |
| Models and data classes | 90%+ |
| Services and repositories | 90%+ |
| Utilities and helpers | 85%+ |
| UI code (Flutter widgets) | 70%+ |
| Generated code | Excluded |

### Interpreting Coverage Results

```dart
// Good coverage - all paths tested
int divide(int a, int b) {
  if (b == 0) {
    throw ArgumentError('Cannot divide by zero');
  }
  return a ~/ b;
}

// Test with full coverage
test('divide with coverage', () {
  expect(divide(10, 2), equals(5));
  expect(() => divide(10, 0), throwsArgumentError);
});

// Poor coverage - missing error case
test('divide without full coverage', () {
  expect(divide(10, 2), equals(5));
  // Missing: divide by zero case
});
```

## Integration Testing

### API Integration Tests

```dart
// test/integration/api_integration_test.dart
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('API Integration Tests', () {
    late http.Client client;
    late String baseUrl;

    setUpAll(() {
      client = http.Client();
      baseUrl = 'http://localhost:8080';
    });

    tearDownAll(() {
      client.close();
    });

    test('full user workflow', () async {
      // Create user
      final createResponse = await client.post(
        Uri.parse('$baseUrl/users'),
        body: {'name': 'Alice', 'email': 'alice@example.com'},
      );
      expect(createResponse.statusCode, equals(201));

      final userId = jsonDecode(createResponse.body)['id'];

      // Get user
      final getResponse = await client.get(
        Uri.parse('$baseUrl/users/$userId'),
      );
      expect(getResponse.statusCode, equals(200));

      final user = jsonDecode(getResponse.body);
      expect(user['name'], equals('Alice'));

      // Update user
      final updateResponse = await client.put(
        Uri.parse('$baseUrl/users/$userId'),
        body: {'name': 'Alice Updated'},
      );
      expect(updateResponse.statusCode, equals(200));

      // Delete user
      final deleteResponse = await client.delete(
        Uri.parse('$baseUrl/users/$userId'),
      );
      expect(deleteResponse.statusCode, equals(204));

      // Verify deletion
      final verifyResponse = await client.get(
        Uri.parse('$baseUrl/users/$userId'),
      );
      expect(verifyResponse.statusCode, equals(404));
    });
  });
}
```

### Database Integration Tests

```dart
// test/integration/database_integration_test.dart
import 'package:test/test.dart';

void main() {
  group('Database Integration', () {
    late Database database;

    setUpAll(() async {
      database = await Database.connect('test_db');
      await database.migrate();
    });

    tearDownAll(() async {
      await database.dropAllTables();
      await database.close();
    });

    setUp(() async {
      await database.clearAllData();
    });

    test('user CRUD operations', () async {
      // Create
      final user = User(name: 'Alice', email: 'alice@example.com');
      final savedUser = await database.users.insert(user);
      expect(savedUser.id, isNotNull);

      // Read
      final fetchedUser = await database.users.findById(savedUser.id);
      expect(fetchedUser?.name, equals('Alice'));

      // Update
      final updatedUser = fetchedUser!.copyWith(name: 'Alice Updated');
      await database.users.update(updatedUser);
      final refetchedUser = await database.users.findById(savedUser.id);
      expect(refetchedUser?.name, equals('Alice Updated'));

      // Delete
      await database.users.delete(savedUser.id);
      final deletedUser = await database.users.findById(savedUser.id);
      expect(deletedUser, isNull);
    });

    test('transaction rollback', () async {
      await database.transaction((txn) async {
        await txn.users.insert(User(name: 'Alice', email: 'alice@example.com'));
        await txn.users.insert(User(name: 'Bob', email: 'bob@example.com'));
        throw Exception('Rollback transaction');
      }).catchError((_) {});

      final users = await database.users.findAll();
      expect(users, isEmpty);
    });
  });
}
```

### Component Integration Tests

```dart
// test/integration/user_service_integration_test.dart
import 'package:test/test.dart';

void main() {
  group('UserService Integration', () {
    late UserService userService;
    late UserRepository repository;
    late EmailService emailService;

    setUp(() {
      repository = InMemoryUserRepository();
      emailService = MockEmailService();
      userService = UserService(
        repository: repository,
        emailService: emailService,
      );
    });

    test('user registration flow', () async {
      final result = await userService.registerUser(
        name: 'Alice',
        email: 'alice@example.com',
        password: 'password123',
      );

      expect(result.isSuccess, isTrue);
      expect(result.user.name, equals('Alice'));

      // Verify user was saved
      final savedUser = await repository.findByEmail('alice@example.com');
      expect(savedUser, isNotNull);

      // Verify welcome email was sent
      verify(emailService.sendWelcomeEmail(any)).called(1);
    });

    test('prevents duplicate registration', () async {
      await userService.registerUser(
        name: 'Alice',
        email: 'alice@example.com',
        password: 'password123',
      );

      final result = await userService.registerUser(
        name: 'Alice',
        email: 'alice@example.com',
        password: 'password123',
      );

      expect(result.isSuccess, isFalse);
      expect(result.error, contains('already exists'));
    });
  });
}
```

## Test Fixtures and Test Data

### Test Data Management

```dart
// test/fixtures/test_data.dart
class TestData {
  static User createUser({
    String id = '1',
    String name = 'Test User',
    String email = 'test@example.com',
    int age = 30,
  }) {
    return User(
      id: id,
      name: name,
      email: email,
      age: age,
    );
  }

  static List<User> createUsers(int count) {
    return List.generate(
      count,
      (i) => createUser(
        id: '$i',
        name: 'User $i',
        email: 'user$i@example.com',
      ),
    );
  }

  static Product createProduct({
    String id = '1',
    String name = 'Test Product',
    double price = 99.99,
  }) {
    return Product(
      id: id,
      name: name,
      price: price,
    );
  }
}

// Usage in tests
void main() {
  test('processes user', () {
    final user = TestData.createUser(name: 'Alice');
    final result = processUser(user);
    expect(result, isTrue);
  });

  test('processes multiple users', () {
    final users = TestData.createUsers(10);
    expect(users, hasLength(10));
  });
}
```

### Loading Test Fixtures from Files

```dart
// test/fixtures/users.json
// [
//   {"id": "1", "name": "Alice", "email": "alice@example.com"},
//   {"id": "2", "name": "Bob", "email": "bob@example.com"}
// ]

// test/test_helpers.dart
import 'dart:io';
import 'dart:convert';

class FixtureLoader {
  static Future<String> loadFixture(String fileName) async {
    final file = File('test/fixtures/$fileName');
    return await file.readAsString();
  }

  static Future<List<User>> loadUsers() async {
    final json = await loadFixture('users.json');
    final list = jsonDecode(json) as List;
    return list.map((item) => User.fromJson(item)).toList();
  }

  static Future<Map<String, dynamic>> loadJsonFixture(String fileName) async {
    final json = await loadFixture(fileName);
    return jsonDecode(json);
  }
}

// Usage
void main() {
  test('loads fixture data', () async {
    final users = await FixtureLoader.loadUsers();
    expect(users, hasLength(2));
    expect(users[0].name, equals('Alice'));
  });
}
```

## TDD Workflow in Dart

### RED-GREEN-REFACTOR Cycle

```dart
// Step 1: RED - Write failing test first
// test/services/calculator_service_test.dart
import 'package:test/test.dart';

void main() {
  group('CalculatorService', () {
    test('calculates total with tax', () {
      final calculator = CalculatorService();
      final result = calculator.calculateTotalWithTax(100, taxRate: 0.1);
      expect(result, equals(110));
    });
  });
}

// Run: dart test
// Result: FAIL - CalculatorService class doesn't exist

// Step 2: GREEN - Write minimal code to pass
// lib/src/services/calculator_service.dart
class CalculatorService {
  double calculateTotalWithTax(double amount, {required double taxRate}) {
    return amount + (amount * taxRate);
  }
}

// Run: dart test
// Result: PASS

// Step 3: REFACTOR - Improve code while keeping tests green
class CalculatorService {
  double calculateTotalWithTax(double amount, {required double taxRate}) {
    if (amount < 0) {
      throw ArgumentError('Amount must be non-negative');
    }
    if (taxRate < 0 || taxRate > 1) {
      throw ArgumentError('Tax rate must be between 0 and 1');
    }

    final tax = _calculateTax(amount, taxRate);
    return amount + tax;
  }

  double _calculateTax(double amount, double rate) {
    return amount * rate;
  }
}

// Add more tests for edge cases
test('throws on negative amount', () {
  final calculator = CalculatorService();
  expect(
    () => calculator.calculateTotalWithTax(-10, taxRate: 0.1),
    throwsArgumentError,
  );
});

test('throws on invalid tax rate', () {
  final calculator = CalculatorService();
  expect(
    () => calculator.calculateTotalWithTax(100, taxRate: 1.5),
    throwsArgumentError,
  );
});

// Run tests again: PASS
```

### TDD Best Practices

```dart
// 1. Start with the simplest test
test('adds two positive numbers', () {
  final calculator = Calculator();
  expect(calculator.add(2, 3), equals(5));
});

// 2. Write just enough code to pass
class Calculator {
  int add(int a, int b) => 5; // Simplest implementation
}

// 3. Add more specific tests
test('adds different numbers', () {
  final calculator = Calculator();
  expect(calculator.add(1, 1), equals(2));
  expect(calculator.add(10, 5), equals(15));
});

// 4. Now implement properly
class Calculator {
  int add(int a, int b) => a + b;
}

// 5. Test edge cases
group('edge cases', () {
  late Calculator calculator;

  setUp(() {
    calculator = Calculator();
  });

  test('handles zero', () {
    expect(calculator.add(0, 0), equals(0));
    expect(calculator.add(5, 0), equals(5));
  });

  test('handles negative numbers', () {
    expect(calculator.add(-5, -3), equals(-8));
    expect(calculator.add(-5, 10), equals(5));
  });

  test('handles large numbers', () {
    expect(calculator.add(1000000, 2000000), equals(3000000));
  });
});

// 6. Refactor with confidence
class Calculator {
  int add(int a, int b) {
    _validateInput(a);
    _validateInput(b);
    return _performAddition(a, b);
  }

  void _validateInput(int value) {
    // Add validation if needed
  }

  int _performAddition(int a, int b) => a + b;
}
```

## Golden Tests (Flutter Compatibility)

### Widget Golden Tests

```dart
// test/widgets/user_card_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  group('UserCard Golden Tests', () {
    testGoldens('renders correctly', (tester) async {
      await loadAppFonts();

      final builder = GoldenBuilder.grid(
        columns: 2,
        widthToHeightRatio: 1,
      )
        ..addScenario(
          'Default',
          UserCard(
            name: 'Alice',
            email: 'alice@example.com',
          ),
        )
        ..addScenario(
          'With Avatar',
          UserCard(
            name: 'Bob',
            email: 'bob@example.com',
            avatarUrl: 'https://example.com/avatar.jpg',
          ),
        )
        ..addScenario(
          'Long Name',
          UserCard(
            name: 'Christopher Alexander',
            email: 'christopher.alexander@example.com',
          ),
        );

      await tester.pumpWidgetBuilder(builder.build());
      await screenMatchesGolden(tester, 'user_card');
    });
  });
}

// Generate golden files: dart test --update-goldens
// Compare: dart test
```

## Best Practices

**DO:**
- Write tests FIRST (TDD)
- Use descriptive test names that explain the behavior
- Keep tests simple and focused on one thing
- Use setUp/tearDown for common initialization
- Mock external dependencies
- Test both happy paths and error cases
- Use meaningful matcher messages
- Organize tests with groups
- Clean up resources in tearDown
- Aim for high test coverage (80%+)

**DON'T:**
- Test private methods directly
- Use sleep() for timing (use FakeAsync)
- Create flaky tests that pass/fail randomly
- Ignore test failures
- Over-mock (prefer real objects when fast)
- Test framework code
- Leave commented-out tests
- Create dependencies between tests
- Test implementation details

## Running Tests

```bash
# Run all tests
dart test

# Run specific test file
dart test test/services/user_service_test.dart

# Run tests matching name pattern
dart test --name="user"

# Run with coverage
dart test --coverage=coverage

# Run in watch mode
dart test --watch

# Run with verbose output
dart test --verbose

# Run tests in specific directory
dart test test/integration/

# Run with custom concurrency
dart test --concurrency=1

# Run with timeout
dart test --timeout=30s

# Update golden files (Flutter)
flutter test --update-goldens
```

## Summary

Dart testing provides comprehensive tools for writing reliable tests:

1. **Use dart test package** - Core testing framework with groups and matchers
2. **Organize tests properly** - Mirror lib/ structure in test/
3. **Mock with mockito** - Generate type-safe mocks for dependencies
4. **Test async code** - Use async/await, expectLater, emitsInOrder
5. **Measure coverage** - Aim for 80%+ overall coverage
6. **Integration tests** - Test component interactions
7. **Manage test data** - Use fixtures and test data helpers
8. **Follow TDD** - Red-Green-Refactor cycle
9. **Use matchers effectively** - Rich built-in and custom matchers
10. **Keep tests maintainable** - Tests are code too

Remember: Good tests enable confident refactoring and serve as living documentation of expected behavior.
