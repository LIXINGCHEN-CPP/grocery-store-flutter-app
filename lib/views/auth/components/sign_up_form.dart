import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/database_service.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/utils/validators.dart';
import 'sign_up_button.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        margin: const EdgeInsets.all(AppDefaults.margin),
        padding: const EdgeInsets.all(AppDefaults.padding),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: AppDefaults.boxShadow,
          borderRadius: AppDefaults.borderRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Name"),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Name is required' : null,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'Enter your full name',
              ),
            ),
            const SizedBox(height: AppDefaults.padding),
            const Text("Email"),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Email is required' : null,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'Enter your email',
              ),
            ),
            const SizedBox(height: AppDefaults.padding),
            const Text("Phone Number"),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Phone number is required' : null,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                hintText: 'Enter your phone number',
              ),
            ),
            const SizedBox(height: AppDefaults.padding),
            const Text("Password"),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              validator: _validatePassword,
              textInputAction: TextInputAction.next,
              obscureText: _obscureText,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                suffixIcon: GestureDetector(
                  onTap: _togglePasswordVisibility,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: !_obscureText
                          ? Colors.green.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SvgPicture.asset(
                      AppIcons.eye,
                      width: 24,
                      colorFilter: ColorFilter.mode(
                        !_obscureText ? Colors.green : Colors.grey,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                suffixIconConstraints: const BoxConstraints(),
              ),
            ),
            const SizedBox(height: AppDefaults.padding),
            SignUpButton(
              formKey: _formKey,
              onPressed: _onSignUp,
            ),
            const SizedBox(height: AppDefaults.padding),
          ],
        ),
      ),
    );
  }

  Future<void> _onSignUp() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate())
      return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final name = _nameController.text;
      final email = _emailController.text;
      final phone = _phoneController.text;
      final password = _passwordController.text;

      print('Attempting register with phone: $phone');
      final response = await DatabaseService.instance
          .registerUser(email, phone, password, name);
      print('Register response: $response');

      if (response['success'] == true) {
        if (mounted) {
          await SessionManager.saveLoginData(response);
          Navigator.pushNamed(context, AppRoutes.numberVerification);
        }
      } else {
        throw Exception(response['message'] ?? 'Login failed');
      }
    } catch (e) {
      print('Register error: $e');
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
}
