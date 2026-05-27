import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_strings.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../theme/color_tokens.dart';
import '../utils/snackbar_helper.dart';
import '../utils/validators.dart';
import '../widgets/common_widgets.dart';
import '../widgets/zen_background.dart';
import '../widgets/glass_app_bar.dart';
import '../theme/animations.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final res = await AuthService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (res.user != null) {
        await UserService.createProfile(
          userId: res.user!.id,
          username: _usernameController.text.trim(),
          dailyTarget: AppStrings.defaultDailyTarget,
        );

        if (!mounted) return;
        SnackbarHelper.showSuccess(context, AppStrings.signUpSuccess);
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      SnackbarHelper.showError(context, 'Kayıt Hatası: ${e.message}');
    } on PostgrestException catch (e) {
      if (!mounted) return;
      SnackbarHelper.showError(context, 'Profil Hatası: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.showError(context, 'Kayıt Hatası: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const ZenBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: const GlassAppBar(
            title: '',
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: GlassCard(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ZenAnimations.staggeredEntrance(
                          index: 0,
                          child: _buildHeader(context),
                        ),
                        const SizedBox(height: 32),
                        ZenAnimations.staggeredEntrance(
                          index: 1,
                          child: ZenTextField(
                            controller: _usernameController,
                            validator: (v) =>
                                Validators.required(v, AppStrings.username),
                            labelText: AppStrings.username,
                            prefixIcon: Icons.person_rounded,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ZenAnimations.staggeredEntrance(
                          index: 2,
                          child: ZenTextField(
                            controller: _emailController,
                            validator: Validators.email,
                            labelText: AppStrings.emailLabel,
                            prefixIcon: Icons.email_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ZenAnimations.staggeredEntrance(
                          index: 3,
                          child: ZenTextField(
                            controller: _passwordController,
                            validator: Validators.password,
                            labelText: AppStrings.password,
                            prefixIcon: Icons.lock_rounded,
                            obscureText: true,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ZenAnimations.staggeredEntrance(
                          index: 4,
                          child: ZenButton(
                            onPressed: _isLoading ? null : _signUp,
                            label: AppStrings.signUp,
                            color: ColorTokens.primary(context),
                            isFullWidth: true,
                            isLoading: _isLoading,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorTokens.primary(context).withValues(alpha: 0.15),
            boxShadow: [
              BoxShadow(
                color: ColorTokens.primary(context).withValues(alpha: 0.2),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            Icons.person_add_rounded,
            size: 40,
            color: ColorTokens.primary(context),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          AppStrings.joinUs,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: ColorTokens.textPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.joinUsDesc,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: ColorTokens.textSecondary(context),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
