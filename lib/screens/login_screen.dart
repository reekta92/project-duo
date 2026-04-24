import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/constants.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../utils/snackbar_helper.dart';
import '../utils/validators.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary400, AppColors.primary700],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingForm),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeader(),
                const SizedBox(height: AppDimensions.spacing3xl),
                _buildLoginCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        Icon(Icons.school, size: AppDimensions.iconLg, color: AppColors.white),
        SizedBox(height: AppDimensions.spacingLg),
        Text(
          AppStrings.wordGame,
          style: TextStyle(
            fontSize: AppDimensions.fontTitle,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Card(
      elevation: AppDimensions.elevationCardHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingInner),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                AppStrings.welcomeBack,
                style: TextStyle(
                  fontSize: AppDimensions.fontSection,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXl),
              TextFormField(
                controller: _emailController,
                validator: Validators.email,
                decoration: InputDecoration(
                  labelText: AppStrings.email,
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              TextFormField(
                controller: _passwordController,
                validator: Validators.password,
                decoration: InputDecoration(
                  labelText: AppStrings.password,
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: AppDimensions.spacing3xl),
              _isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: AppDimensions.buttonHeight,
                          child: ElevatedButton(
                            onPressed: _signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.seed,
                              foregroundColor: AppColors.white,
                              elevation: AppDimensions.elevationButton,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusSm,
                                ),
                              ),
                            ),
                            child: const Text(
                              AppStrings.login,
                              style: TextStyle(
                                fontSize: AppDimensions.fontButton,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingLg),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.signup),
                          child: const Text(
                            AppStrings.noAccount,
                            style: TextStyle(fontSize: AppDimensions.fontSmall),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
