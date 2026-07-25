# Flutter Project Best Practices (2025)

## Folder Structure

```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── theme/
│   └── utils/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── pages/
│   ├── widgets/
│   └── providers/
├── features/
│   ├── feature_name/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── ...
└── main.dart
```

## Key Principles

### 1. Feature-First Organization
- Each feature in its own folder
- Separate data, domain, presentation layers
- Easy to work on modules independently

### 2. Layer Separation
- **Data Layer**: API calls, databases, caching
- **Domain Layer**: Business logic, use cases
- **Presentation Layer**: UI, widgets, state management

### 3. Naming Conventions
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/functions: `camelCase`
- Constants: `kConstantName`

### 4. State Management Options
- **Riverpod**: Recommended for most apps (compile-time safe)
- **BLoC**: Event-driven, good for complex apps
- **Signals**: Lightweight, high-frequency updates
- **GetX**: All-in-one solution

### 5. Performance Targets
- App startup: < 3 seconds
- Page navigation: < 300ms
- API response: < 2 seconds
- Memory usage: < 100MB

## Best Practices

### Code Organization
1. Use barrel files (`index.dart`) for imports
2. Keep widgets small and focused
3. Extract business logic to separate files
4. Use `const` constructors when possible

### Testing
1. Mirror `lib/` structure in `test/`
2. Write unit tests for business logic
3. Write widget tests for UI
4. Use integration tests for flows

### Documentation
1. Document architecture decisions
2. Add comments for complex logic
3. Keep README updated
4. Use meaningful variable names

### Dependencies
1. Minimize third-party packages
2. Check package maintenance status
3. Use version constraints properly
4. Regular dependency updates

## Common Patterns

### Clean Architecture
```
Feature/
├── data/
│   ├── models/
│   ├── datasources/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── bloc/
    ├── pages/
    └── widgets/
```

### BLoC Pattern
```
├── bloc/
│   ├── event.dart
│   ├── state.dart
│   └── bloc.dart
```

### Riverpod Pattern
```
├── providers/
│   ├── provider.dart
│   └── state.dart
```
