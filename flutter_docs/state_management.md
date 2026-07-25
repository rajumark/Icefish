# Flutter State Management

## Options Overview

| Solution | Best For | Complexity |
|----------|----------|------------|
| Riverpod | Most apps | Medium |
| BLoC | Complex apps | High |
| Signals | Animations | Low |
| GetX | Quick apps | Low |

## Riverpod (Recommended)

### Setup
```yaml
dependencies:
  flutter_riverpod: ^2.0.0
```

### Basic Usage
```dart
// Define provider
final counterProvider = StateProvider<int>((ref) => 0);

// Read provider
ref.watch(counterProvider);

// Update provider
ref.read(counterProvider.notifier).state++;
```

## BLoC Pattern

### Setup
```yaml
dependencies:
  flutter_bloc: ^8.0.0
  bloc: ^8.0.0
```

### Basic Usage
```dart
// Event
class IncrementEvent {}

// State
class CounterState {
  final int count;
  CounterState(this.count);
}

// BLoC
class CounterBloc extends Bloc<IncrementEvent, CounterState> {
  CounterBloc() : super(CounterState(0)) {
    on<IncrementEvent>((event, emit) {
      emit(CounterState(state.count + 1));
    });
  }
}
```

## Best Practices

1. **Choose one solution** - Don't mix state management
2. **Keep state minimal** - Only store essential data
3. **Use selectors** - Minimize widget rebuilds
4. **Test state logic** - Unit test providers/blocs
5. **Document decisions** - Explain why you chose a solution
