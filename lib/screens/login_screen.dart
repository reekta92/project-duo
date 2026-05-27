import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_strings.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../theme/color_tokens.dart';
import '../theme/theme_provider.dart';
import '../utils/snackbar_helper.dart';
import '../utils/validators.dart';
import '../widgets/common_widgets.dart';
import '../widgets/zen_background.dart';
import '../theme/animations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await AuthService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;
      SnackbarHelper.showSuccess(context, AppStrings.loginSuccess);
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } on AuthException catch (e) {
      if (!mounted) return;
      SnackbarHelper.showError(context, e.message);
    } catch (_) {
      if (!mounted) return;
      SnackbarHelper.showError(context, AppStrings.loginFail);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final emailCtrl = TextEditingController(text: _emailController.text);
    final email = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ColorTokens.surfaceElevated(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Şifremi Unuttum', style: TextStyle(color: ColorTokens.textPrimary(context))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'E-posta adresinizi girin, size şifre sıfırlama bağlantısı gönderelim.',
              style: TextStyle(color: ColorTokens.textSecondary(context)),
            ),
            const SizedBox(height: 16),
            ZenTextField(
              controller: emailCtrl,
              labelText: 'E-posta',
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('İptal', style: TextStyle(color: ColorTokens.textMuted(context))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, emailCtrl.text.trim()),
            child: Text('Gönder', style: TextStyle(color: ColorTokens.primary(context), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (email == null || email.isEmpty) return;
    try {
      await AuthService.resetPassword(email);
      if (!mounted) return;
      SnackbarHelper.showSuccess(
        context,
        'Şifre sıfırlama bağlantısı e-posta adresinize gönderildi.',
      );
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.showError(context, 'Hata: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        const ZenBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ZenAnimations.staggeredEntrance(
                          index: 0,
                          child: _buildHeader(isDark),
                        ),
                        const SizedBox(height: 48),
                        ZenAnimations.staggeredEntrance(
                          index: 1,
                          child: _buildLoginCard(),
                        ),
                      ],
                    ),
                  ),
                ),
                // Theme toggle top-right
                Positioned(
                  top: 8,
                  right: 8,
                  child: Consumer<ThemeProvider>(
                    builder: (_, tp, __) => IconButton(
                      icon: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: ColorTokens.textMuted(context),
                      ),
                      onPressed: () => tp.toggleTheme(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorTokens.primary(context).withValues(alpha: 0.15),
            boxShadow: [
              BoxShadow(
                color: ColorTokens.primary(context).withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            Icons.school_rounded,
            size: 48,
            color: ColorTokens.primary(context),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          AppStrings.wordGame,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: ColorTokens.textPrimary(context),
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return GlassCard(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(
              AppStrings.welcomeBack,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ColorTokens.textPrimary(context),
              ),
            ),
            const SizedBox(height: 32),
            ZenTextField(
              controller: _emailController,
              validator: Validators.email,
              labelText: AppStrings.email,
              prefixIcon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            ZenTextField(
              controller: _passwordController,
              validator: Validators.password,
              labelText: AppStrings.password,
              prefixIcon: Icons.lock_rounded,
              obscureText: true,
            ),
            const SizedBox(height: 32),
            ZenButton(
              onPressed: _isLoading ? null : _signIn,
              label: AppStrings.login,
              color: ColorTokens.primary(context),
              isFullWidth: true,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _showForgotPasswordDialog,
              child: Text(
                'Şifremi Unuttum',
                style: TextStyle(
                  fontSize: 14,
                  color: ColorTokens.textSecondary(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
              child: Text(
                AppStrings.noAccount,
                style: TextStyle(
                  fontSize: 14,
                  color: ColorTokens.primary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 24),
              const GlassDivider(),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
                child: const Text(
                  '🔧 Debug: Skip Login',
                  style: TextStyle(
                    fontSize: 13,
                    color: ColorTokens.lightTextMuted,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
