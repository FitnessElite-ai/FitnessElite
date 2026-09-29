# FitnessElite.ai — Complete Tech Stack

## 1. Frontend & Mobile Framework
- **Framework**: Flutter (3.x, Dart 3.x)
- **UI Design System**: Material 3 (Custom Glassmorphism, Dual Dark & Light Themes)
- **Design Tokens**: `brand_design_system.dart` (`BrandColors`, `BrandTypography`, `BrandSpacing`, `BrandRadii`, `BrandShadows`, `BrandAnimations`)
- **Responsive Layout**: `ResponsiveUtils` (Fluid layouts for phones, large screens, and tablets)

## 2. State Management & Dependency Injection
- **State Management**: Flutter Riverpod (`NotifierProvider`, `Provider`, `StateNotifierProvider`)
- **Architecture Pattern**: Clean Architecture (Presentation, Domain, Data/Repositories)
- **Immutability**: Immutable models with `copyWith`, `toMap`, `fromMap`, `toJson`, `fromJson`

## 3. Autonomous AI Agent System
- **Agent Orchestrator**: `AgentOrchestrator` (Deterministic Observe-Understand-Plan-Decide-Act-Reflect Loop)
- **Specialized Sub-Agents**: `WorkoutAgent`, `NutritionAgent`, `RecoveryAgent`, `ProgressAgent`, `CoachAgent`, `VisionAgent`, `DeviceAgent`, `YogaAgent`, `GoalAgent`, `HabitAgent`, `BreathAgent` (Breath Coach)
- **Tool Abstraction Layer**: 20 Strictly-Typed `AgentTool` classes with input/output parameter validation
- **Personal Memory Service**: `FitnessMemoryService` & `LocalFitnessMemoryService` (Structured memory retention across 11 categories)
- **Permissions & Safety**: `AgentPermissionPolicy` (4-tier permission levels), `FitnessSafetyPolicy`, and `BreathSafetyPolicy`

## 4. Breathwork & AI Guided Breathing System
- **Breathwork Engine**: `BreathingSessionEngine` (Deterministic phase state machine: Preparing, Inhaling, HoldAfterInhale, Exhaling, HoldAfterExhale, Paused, Completed)
- **Exercise Breathing Coaching**: Biomechanical inhale/exhale instructions integrated directly into `Exercise` and `ExerciseLibrary`
- **Breathing Library**: 10 structured breathwork patterns (`BreathingLibrary`)
- **Interactive Player**: `BreathingSessionScreen` with animated expanding/contracting breathing circle, phase timers, voice guidance, and haptic cues
- **Accessibility**: Support for reduced motion settings (clean text phase indicators)

## 5. Voice Agent & Natural Language System
- **Voice Pipeline**: `VoiceAgentService`, `VoiceNotifier`, `VoiceAssistantBottomSheet`
- **Speech-to-Intent Engine**: `StructuredUserIntent` parser (Extracts time constraints, fatigue, exercise dislikes, schedule changes, voice queries offline)
- **LLM Adapter Architecture**: `ConversationalAIProvider` (Pluggable interface for OpenAI GPT-4o, Gemini 1.5 Pro, AWS Bedrock, Custom LLMs, and `DeterministicFallbackProvider`)

## 6. Wearables, HealthKit & Bluetooth Integration
- **Device Service**: `DeviceIntegrationService`, `BluetoothFitnessDeviceService`
- **Device Repository**: `DeviceDataRepository` & `LocalDeviceDataRepository`
- **Data Normalization**: `DeviceFitnessData` (Steps, Heart Rate, Resting HR, Sleep Duration, Active Calories, Weight, Timestamp)
- **UI & Permissions**: `DeviceConnectionScreen` (Apple Health, Google Health Connect, Bluetooth devices)

## 7. Yoga & Mobility System
- **Yoga Poses & Sessions**: `YogaPose` (12 foundational poses with setup, steps, breathing, benefits), `YogaSession`, `YogaLibrary`
- **Session Types**: Morning Mobility, Recovery Yoga, Post-Workout Stretch, Evening Wind-Down, Flexibility, Beginner Yoga
- **Interactive Session UI**: `YogaSessionScreen`

## 8. Fitness & Metabolic Engine
- **Metabolic Formulations**: Mifflin-St Jeor BMR, Activity-Multiplied TDEE, Calorie Surplus/Deficit calculations
- **Rule-Based Engine**: `RuleBasedFitnessEngine` (Deterministic plan generation & exercise filtering)
- **Exercise Database**: `ExerciseLibrary` (Multi-muscle group, multi-equipment catalog)

## 9. Local Persistence & Data Architecture
- **Local Storage**: `SharedPreferences` via `LocalStorageService`
- **Repository Pattern**: `LocalFitnessPlanRepository`, `LocalWorkoutHistoryRepository`, `LocalAICoachRepository`, `LocalUserDataRepository`, `LocalDeviceDataRepository`, `LocalFitnessMemoryService`
- **Data Export**: Complete JSON export capability via `UserDataRepository`

## 10. Monetization, Ads & Subscriptions
- **In-App Purchases**: RevenueCat Integration (`purchases_flutter`)
- **Subscription Management**: Dynamic `CustomerInfo`, Entitlements, 3-Day Free Trial offers ($9/mo, $89/yr), and Restore Purchases
- **Contextual Ad Service**: `AdService` and `AdCard` for free users (gated off for Premium subscribers)

## 11. Navigation & Routing
- **Router**: `go_router` (Declarative routing with deep linking & parameter passing)

## 12. Observability & System Services
- **Telemetry & Analytics**: `LocalAnalyticsService` (Privacy-focused non-sensitive event tracking)
- **Error Reporting**: `LocalErrorReportingService` (Exception tracking without capturing biometrics)
- **Agent Observability**: `LocalAgentObservabilityService` (Structured `AgentLog` run tracking)
- **Notifications**: `FitnessNotificationService` & `LocalFitnessNotificationService`

## 13. Localization & Internationalization
- **Locales Supported**: 9 Languages (English, Spanish, Mandarin Chinese, Hindi, Arabic, Bengali, Telugu, Marathi, Tamil)
- **Localization System**: `AppLocalizations` & `flutter_localizations`
- **RTL Support**: Full Right-to-Left mirror layout support for Arabic

## 14. Testing & Quality Assurance
- **Test Framework**: `flutter_test` (71 Unit, Widget, and Integration tests passing)
- **Static Analysis**: `flutter analyze` (0 warnings, 0 errors)
