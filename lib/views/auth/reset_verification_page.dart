import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/components/network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/constants/app_images.dart';
import '../../core/routes/app_routes.dart';
import '../../core/themes/app_themes.dart';

class ResetVerificationPage extends StatefulWidget {
  final String phone;
  const ResetVerificationPage({Key? key, required this.phone})
      : super(key: key);

  @override
  State<ResetVerificationPage> createState() => _ResetVerificationPageState();
}

class _ResetVerificationPageState extends State<ResetVerificationPage> {
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int _remainingTime = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime == 0) {
        timer.cancel();
      } else {
        setState(() {
          _remainingTime--;
        });
      }
    });
  }

  void _resendCode() {
    setState(() {
      _remainingTime = 60;
    });
    _startTimer();
  }

  bool _validateOtpFields() {
    for (var controller in _otpControllers) {
      if (controller.text.isEmpty) return false;
    }
    return true;
  }

  void _verifyCode() {
    if (!_validateOtpFields()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 4 digits'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate verification process
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
      Navigator.pushNamed(
        context,
        AppRoutes.passwordReset,
        arguments: widget.phone,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldWithBoxBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDefaults.padding),
                    margin: const EdgeInsets.all(AppDefaults.margin),
                    decoration: BoxDecoration(
                      color: AppColors.scaffoldBackground,
                      borderRadius: AppDefaults.borderRadius,
                    ),
                    child: Column(
                      children: [
                        _buildHeader(),
                        OTPTextFields(
                          controllers: _otpControllers,
                          focusNodes: _otpFocusNodes,
                        ),
                        const SizedBox(height: AppDefaults.padding * 3),
                        _buildResendButton(),
                        const SizedBox(height: AppDefaults.padding),
                        _buildVerifyButton(),
                        const SizedBox(height: AppDefaults.padding),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: AppDefaults.padding),
        Text(
          'Password Reset Verification',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppDefaults.padding),
        Text(
          'We have sent a verification code to ${widget.phone}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppDefaults.padding),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          child: const AspectRatio(
            aspectRatio: 1 / 1,
            child: NetworkImageWithLoader(
              AppImages.numberVerfication,
            ),
          ),
        ),
        const SizedBox(height: AppDefaults.padding * 3),
      ],
    );
  }

  Widget _buildResendButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Didn\'t receive code?'),
        TextButton(
          onPressed: _remainingTime > 0 ? null : _resendCode,
          child: _remainingTime > 0
              ? Text('Resend in $_remainingTime s')
              : const Text('Resend'),
        ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _verifyCode,
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text('Verify'),
      ),
    );
  }
}

class OTPTextFields extends StatelessWidget {
  const OTPTextFields({
    super.key,
    required this.controllers,
    required this.focusNodes,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.defaultTheme.copyWith(
        inputDecorationTheme: AppTheme.otpInputDecorationTheme,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          4,
          (index) => SizedBox(
            width: 68,
            height: 68,
            child: TextFormField(
              controller: controllers[index],
              focusNode: focusNodes[index],
              onChanged: (v) {
                if (v.length == 1 && index < 3) {
                  FocusScope.of(context).requestFocus(focusNodes[index + 1]);
                } else if (v.isEmpty && index > 0) {
                  FocusScope.of(context).requestFocus(focusNodes[index - 1]);
                }
              },
              validator: (value) => value?.isEmpty ?? true
                  ? ''
                  : null, // Empty error to maintain spacing
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
                FilteringTextInputFormatter.digitsOnly,
              ],
              keyboardType: TextInputType.number,
            ),
          ),
        ),
      ),
    );
  }
}
