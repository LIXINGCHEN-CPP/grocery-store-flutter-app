import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import 'components/already_have_account_row.dart';
import 'components/sign_up_form.dart';
import 'components/sign_up_header.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.scaffoldWithBoxBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SignUpHeader(),
                SizedBox(height: AppDefaults.padding),
                SignUpForm(),
                SizedBox(height: AppDefaults.padding),
                AlreadyHaveAccountRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
