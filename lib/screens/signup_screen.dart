import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/constants.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../utils/snackbar_helper.dart';
import '../utils/validators.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.newAccount)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingForm),
          child: Card(
            elevation: AppDimensions.elevationCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingForm),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: AppDimensions.spacingXl),
                    TextFormField(
                      controller: _usernameController,
                      validator: (v) =>
                          Validators.required(v, AppStrings.username),
                      decoration: const InputDecoration(
                        labelText: AppStrings.username,
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),
                    TextFormField(
                      controller: _emailController,
                      validator: Validators.email,
                      decoration: const InputDecoration(
                        labelText: AppStrings.emailLabel,
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),
                    TextFormField(
                      controller: _passwordController,
                      validator: Validators.password,
                      decoration: const InputDecoration(
                        labelText: AppStrings.password,
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: AppDimensions.spacingXl),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            height: AppDimensions.buttonHeightSm,
                            child: ElevatedButton(
                              onPressed: _signUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.seed,
                                foregroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusSm,
                                  ),
                                ),
                              ),
                              child: const Text(
                                AppStrings.signUp,
                                style: TextStyle(
                                  fontSize: AppDimensions.fontButton,
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        Icon(
          Icons.person_add,
          size: AppDimensions.iconMd,
          color: AppColors.seed,
        ),
        SizedBox(height: AppDimensions.spacingXl),
        Text(
          AppStrings.joinUs,
          style: TextStyle(
            fontSize: AppDimensions.fontSubheading,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppDimensions.spacingXs),
        Text(AppStrings.joinUsDesc, textAlign: TextAlign.center),
      ],
    );
  }
}
