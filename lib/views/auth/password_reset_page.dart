import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/components/app_back_button.dart';
import '../../core/constants/constants.dart';
import '../../core/services/database_service.dart';
import '../../core/utils/session_manager.dart';

class PasswordResetPage extends StatefulWidget {
  final String phone;
  const PasswordResetPage({super.key, required this.phone});

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Validate password meets complexity requirements
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain special character';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldWithBoxBackground,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('New Password'),
        backgroundColor: AppColors.scaffoldBackground,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(AppDefaults.margin),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDefaults.padding,
                    vertical: AppDefaults.padding * 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppDefaults.borderRadius,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Add New password',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppDefaults.padding * 3),
                      const Text("New Password"),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        validator: _validatePassword,
                        decoration: const InputDecoration(
                          hintText: 'Enter new password',
                        ),
                      ),
                      const SizedBox(height: AppDefaults.padding),
                      const Text("Confirm Password"),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          hintText: 'Confirm new password',
                        ),
                      ),
                      const SizedBox(height: AppDefaults.padding * 2),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              // Navigator.pushNamed(context, AppRoutes.login);
                              _onResetPassword();
                            }
                          },
                          child: const Text('Done'),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onResetPassword() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) return;

    setState(() {
      // isLoading = true;
      // errorMessage = null;
    });

    try {
      final password = _passwordController.text;

      print('password reset: ${widget.phone}');
      final response =
      await DatabaseService.instance.resetPassword(widget.phone, password);
      print('passwordReset response: $response');

      if (response['success'] == true) {
        if (mounted) {
          await SessionManager.saveLoginData(response);
          Navigator.pushNamed(context, AppRoutes.entryPoint);
        }
      } else {
        throw Exception(response['message'] ?? 'Login failed');
      }
    } catch (e) {
      print('passwordReset error: $e');
      String message = e.toString().replaceAll('Exception: ', '');
      if (message.contains('Wrong phone number or password')) {
        message = 'Wrong phone number or password';
      } else if (message.contains('Connection timeout')) {
        message = 'Connection timeout. Please check your network';
      }
      setState(() {
        // errorMessage = message;
      });
    } finally {
      if (mounted) {
        setState(() {
          // isLoading = false;
        });
      }
    }
  }
}
