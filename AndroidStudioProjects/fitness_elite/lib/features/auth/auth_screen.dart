import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/responsive_utils.dart';
import '../../shared/animations/fade_in_animation.dart';
import '../../shared/animations/glass_entrance_animation.dart';
import '../../shared/animations/slide_in_animation.dart';
import '../../shared/widgets/fitness_elite_logo.dart';
import '../../shared/widgets/glass_card.dart';
import 'domain/auth_state.dart';
import 'presentation/providers/auth_provider.dart';

/// Premium Authentication Screen for FitnessElite.ai.
/// Supports Sign In, Create Account (Sign Up), Google Sign-In architecture,
/// Show/Hide password toggles, Form Validations, and local session persistence.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSignUpMode = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isSignUpMode = !_isSignUpMode;
      _signInFormKey.currentState?.reset();
      _signUpFormKey.currentState?.reset();
    });
  }

  Future<void> _submitSignIn() async {
    if (!(_signInFormKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();

    await ref.read(authNotifierProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  Future<void> _submitSignUp() async {
    if (!(_signUpFormKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();

    await ref.read(authNotifierProvider.notifier).signUp(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  Future<void> _handleForgotPassword() async {
    final l10n = AppLocalizations.of(context);
    final email = _emailController.text.trim();

    if (email.isEmpty ||
        AuthValidators.validateEmail(email, l10n) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.validationEmailInvalid),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    await ref
        .read(authNotifierProvider.notifier)
        .sendPasswordResetEmail(email);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.passwordResetSent),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);
    final authState = ref.watch(authNotifierProvider);

    // Listen to authentication state changes for routing & error banners
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.isAuthenticated) {
        context.go('/health-profile');
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        String msg = l10n.errInvalidCredentials;
        if (next.errorType == AuthErrorType.networkError) {
          msg = l10n.errNetwork;
        } else if (next.errorType == AuthErrorType.accountCreationFailure) {
          msg = l10n.errAccountCreation;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const FitnessEliteLogo(
          iconSize: 26,
          fontSize: 18,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/onboarding'),
          tooltip: l10n.revisitOnboarding,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // Welcome Title
              SlideInAnimation(
                direction: SlideDirection.up,
                child: Text(
                  l10n.welcomeToFitnessElite,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              FadeInAnimation(
                delay: const Duration(milliseconds: 150),
                child: Text(
                  l10n.authSubtitleTagline,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                ),
              ),

              const SizedBox(height: 24),

              // Main Auth Card
              GlassEntranceAnimation(
                delay: const Duration(milliseconds: 250),
                child: GlassCard(
                  enableGlow: true,
                  padding: const EdgeInsets.all(20),
                  child: AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: _isSignUpMode
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: _buildSignInForm(context, l10n, isDark, authState),
                    secondChild: _buildSignUpForm(context, l10n, isDark, authState),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // OR Divider
              FadeInAnimation(
                delay: const Duration(milliseconds: 350),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: isDark
                            ? AppColors.darkGlassBorder
                            : AppColors.lightGlassBorder,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        l10n.orDivider,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: isDark
                            ? AppColors.darkGlassBorder
                            : AppColors.lightGlassBorder,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Google Sign-In Button
              FadeInAnimation(
                delay: const Duration(milliseconds: 400),
                child: SizedBox(
                  height: 54,
                  child: OutlinedButton(
                    onPressed: authState.isLoading
                        ? null
                        : () {
                            ref
                                .read(authNotifierProvider.notifier)
                                .signInWithGoogle();
                          },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: BorderSide(
                        color: isDark
                            ? AppColors.darkGlassBorder
                            : AppColors.lightGlassBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.g_mobiledata_rounded,
                          size: 32,
                          color: AppColors.electricBlue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.continueWithGoogle,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Toggle between Sign In and Create Account
              FadeInAnimation(
                delay: const Duration(milliseconds: 450),
                child: Center(
                  child: TextButton(
                    onPressed: _toggleAuthMode,
                    child: Text(
                      _isSignUpMode
                          ? l10n.alreadyHaveAccount
                          : l10n.dontHaveAccount,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.electricBlue,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
    AuthState authState,
  ) {
    return Form(
      key: _signInFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.signIn,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 16),

          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) => AuthValidators.validateEmail(value, l10n),
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: _buildInputDecoration(
              context,
              label: l10n.emailAddress,
              hint: l10n.emailHint,
              icon: Icons.email_outlined,
              isDark: isDark,
            ),
          ),

          const SizedBox(height: 16),

          // Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            validator: (value) => AuthValidators.validatePassword(value, l10n),
            style: Theme.of(context).textTheme.bodyMedium,
            onFieldSubmitted: (_) => _submitSignIn(),
            decoration: _buildInputDecoration(
              context,
              label: l10n.password,
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              isDark: isDark,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _handleForgotPassword,
              child: Text(
                l10n.forgotPassword,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.electricBlue,
                    ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Submit Button
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: authState.isLoading ? null : _submitSignIn,
              child: authState.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.black,
                      ),
                    )
                  : Text(l10n.signIn),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
    AuthState authState,
  ) {
    return Form(
      key: _signUpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.createAccount,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 16),

          // Full Name Field
          TextFormField(
            controller: _nameController,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            validator: (value) => AuthValidators.validateName(value, l10n),
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: _buildInputDecoration(
              context,
              label: l10n.fullName,
              hint: l10n.fullNameHint,
              icon: Icons.person_outline_rounded,
              isDark: isDark,
            ),
          ),

          const SizedBox(height: 16),

          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) => AuthValidators.validateEmail(value, l10n),
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: _buildInputDecoration(
              context,
              label: l10n.emailAddress,
              hint: l10n.emailHint,
              icon: Icons.email_outlined,
              isDark: isDark,
            ),
          ),

          const SizedBox(height: 16),

          // Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            validator: (value) => AuthValidators.validatePassword(value, l10n),
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: _buildInputDecoration(
              context,
              label: l10n.password,
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              isDark: isDark,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Confirm Password Field
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            validator: (value) => AuthValidators.validateConfirmPassword(
              value,
              _passwordController.text,
              l10n,
            ),
            style: Theme.of(context).textTheme.bodyMedium,
            onFieldSubmitted: (_) => _submitSignUp(),
            decoration: _buildInputDecoration(
              context,
              label: l10n.confirmPassword,
              hint: '••••••••',
              icon: Icons.lock_clock_outlined,
              isDark: isDark,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Submit Button
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: authState.isLoading ? null : _submitSignUp,
              child: authState.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.black,
                      ),
                    )
                  : Text(l10n.createAccount),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    BuildContext context, {
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: AppColors.electricBlue,
        size: 22,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDark
          ? AppColors.darkSurfaceVariant
          : AppColors.lightSurfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark
              ? AppColors.darkGlassBorder
              : AppColors.lightGlassBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.electricBlue,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.error,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }
}
