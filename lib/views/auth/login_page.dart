import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import 'components/dont_have_account_row.dart';
import 'components/login_header.dart';
import 'components/login_page_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.scaffoldWithBoxBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                LoginHeader(),
                SizedBox(height: AppDefaults.padding),
                LoginPageForm(),
                SizedBox(height: AppDefaults.padding),
                DontHaveAccountRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
