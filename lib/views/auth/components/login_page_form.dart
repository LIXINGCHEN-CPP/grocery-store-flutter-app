import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/themes/app_themes.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/utils/validators.dart';
import '../../../core/services/database_service.dart';
import 'login_button.dart';

class LoginPageForm extends StatefulWidget {
  const LoginPageForm({
    super.key,
  });

  @override
  State<LoginPageForm> createState() => _LoginPageFormState();
}

class _LoginPageFormState extends State<LoginPageForm> {
  final _key = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isPasswordShown = false;
  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  onPassShowClicked() {
    isPasswordShown = !isPasswordShown;
    setState(() {});
  }

  Future<void> onLogin() async {
    if (_key.currentState == null || !_key.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final phone = _phoneController.text;
      final password = _passwordController.text;

      print('Attempting login with phone: $phone');
      final response =
          await DatabaseService.instance.loginWithPhone(phone, password);
      print('Login response: $response');

      if (response['success'] == true) {
        if (mounted) {
          await SessionManager.saveLoginData(response);
          Navigator.pushNamed(context, AppRoutes.entryPoint);
        }
      } else {
        throw Exception(response['message'] ?? 'Login failed');
      }
    } catch (e) {
      print('Login error: $e');
      String message = e.toString().replaceAll('Exception: ', '');
      if (message.contains('Wrong phone number or password')) {
        message = 'Wrong phone number or password';
      } else if (message.contains('Connection timeout')) {
        message = 'Connection timeout. Please check your network';
      }
      setState(() {
        errorMessage = message;
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.defaultTheme.copyWith(
        inputDecorationTheme: AppTheme.secondaryInputDecorationTheme,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Form(
          key: _key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Phone Field
              const Text("Phone Number"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: Validators.requiredWithFieldName('Phone').call,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Enter your phone number',
                ),
              ),
              const SizedBox(height: AppDefaults.padding),

              // Password Field
              const Text("Password"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                validator: Validators.password.call,
                onFieldSubmitted: (v) => onLogin(),
                textInputAction: TextInputAction.done,
                obscureText: !isPasswordShown,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  suffixIcon: GestureDetector(
                    onTap: onPassShowClicked,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isPasswordShown
                            ? Colors.green.withOpacity(0.1) // 显示密码时的背景色
                            : Colors.transparent, // 隐藏密码时透明背景
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SvgPicture.asset(
                        AppIcons.eye,
                        width: 24,
                        colorFilter: ColorFilter.mode(
                          isPasswordShown
                              ? Colors.green // 显示密码时的图标颜色
                              : Colors.grey, // 隐藏密码时的图标颜色
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  suffixIconConstraints: const BoxConstraints(),
                ),
              ),

              // Forget Password labelLarge
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.forgotPassword,);
                  },
                  child: const Text('Forget Password?'),
                ),
              ),

              // Error Message
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              // Login Button
              LoginButton(
                onPressed: onLogin,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
