import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../utils/snackbar_helper.dart';
import '../utils/validators.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _targetController = TextEditingController();
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = AuthService.currentUser;
      if (user == null) return;

      final profile = await UserService.getProfile(user.id);

      setState(() {
        _targetController.text = profile.dailyTarget.toString();
        _usernameController.text = profile.username;
      });
    } catch (e) {
      debugPrint('Veri yüklenirken hata oluştu: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = AuthService.currentUser;
      if (user == null) throw Exception('Kullanıcı oturumu bulunamadı.');

      final newTarget = int.parse(_targetController.text.trim());

      await UserService.updateProfile(
        userId: user.id,
        username: _usernameController.text.trim(),
        dailyTarget: newTarget,
      );

      if (!mounted) return;
      SnackbarHelper.showSuccess(context, AppStrings.profileUpdated);
      _loadUserData();
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.showError(context, 'Güncelleme Hatası: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    await AuthService.signOut();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  @override
  void dispose() {
    _targetController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              children: [
                _buildSectionTitle(AppStrings.profileSettings),
                _buildProfileCard(),
                const SizedBox(height: AppDimensions.spacingXl),
                _buildSectionTitle(AppStrings.account),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.red),
                    title: const Text(
                      AppStrings.signOut,
                      style: TextStyle(color: AppColors.red),
                    ),
                    onTap: _signOut,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacingXs,
        horizontal: 4.0,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: AppDimensions.fontSubtitle,
          fontWeight: FontWeight.bold,
          color: AppColors.grey,
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingCard),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                validator: (v) => Validators.required(v, AppStrings.username),
                decoration: const InputDecoration(
                  labelText: AppStrings.username,
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              TextFormField(
                controller: _targetController,
                validator: Validators.number,
                decoration: const InputDecoration(
                  labelText: AppStrings.dailyTarget,
                  prefixIcon: Icon(Icons.gps_fixed),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeightXs,
                child: ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.seed,
                    foregroundColor: AppColors.white,
                  ),
                  child: const Text(AppStrings.saveChanges),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
