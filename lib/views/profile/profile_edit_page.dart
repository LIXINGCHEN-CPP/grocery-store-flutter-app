import 'package:flutter/material.dart';

import '../../core/components/app_back_button.dart';
import '../../core/constants/constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/database_service.dart';
import '../../core/utils/session_manager.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {

  Map<String, dynamic>? userInfo;

  final TextEditingController _firstNameController  = TextEditingController();
  final TextEditingController _lastNameController  = TextEditingController();
  final TextEditingController _phoneController  = TextEditingController();
  final TextEditingController _genderController  = TextEditingController();
  final TextEditingController _birthdayController  = TextEditingController();



  @override
  void initState() {
    super.initState();
    SessionManager.getUserInfo().then((res) {
      setState(() {
        userInfo = res;
        _getUserInfo().then((user) {
          _firstNameController.text = user?['data']?['firstName']??'';
          _lastNameController.text = user?['data']?['lastName']??'';
          _phoneController.text = user?['data']?['phone']??'';
          _genderController.text = user?['data']?['gender']??'';
          _birthdayController.text = user?['data']?['birthday']??'';
        });

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardColor,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text(
          'Profile',
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(AppDefaults.padding),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDefaults.padding,
            vertical: AppDefaults.padding * 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackground,
            borderRadius: AppDefaults.borderRadius,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /* <----  First Name -----> */
              const Text("First Name"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _firstNameController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppDefaults.padding),

              /* <---- Last Name -----> */
              const Text("Last Name"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lastNameController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppDefaults.padding),

              /* <---- Phone Number -----> */
              const Text("Phone Number"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppDefaults.padding),

              /* <---- Gender -----> */
              const Text("Gender"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _genderController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppDefaults.padding),

              /* <---- Birthday -----> */
              const Text("Birthday"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _birthdayController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppDefaults.padding),

              /* <---- Password -----> */

              /* <---- Birthday -----> */
              // const Text("Password"),
              // const SizedBox(height: 8),
              // TextFormField(
              //   keyboardType: TextInputType.visiblePassword,
              //   textInputAction: TextInputAction.next,
              //   obscureText: true,
              // ),
              // const SizedBox(height: AppDefaults.padding),

              /* <---- Submit -----> */
              const SizedBox(height: AppDefaults.padding),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateUserInfo,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateUserInfo() async {

    setState(() {
      // isLoading = true;
      // errorMessage = null;
    });

    try {
      final id = userInfo?['id'];
      final firstName = _firstNameController.text;
      final lastName = _lastNameController.text;
      final phone = _phoneController.text;
      final gender = _genderController.text;
      final birthday = _birthdayController.text;

      print('Attempting register with phone: $phone');
      final response =
      await DatabaseService.instance.updateUser(id, firstName, lastName, phone, gender, birthday);
      print('Register response: $response');

      if (response['success'] == true) {
        if (mounted) {
          // await SessionManager.saveLoginData(response);
          // Navigator.pushNamed(context, AppRoutes.entryPoint);
          Navigator.pop(context);
        }
      } else {
        throw Exception(response['message'] ?? 'Update failed');
      }
    } catch (e) {
      print('Update error: $e');
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

  Future<Map<String, dynamic>?> _getUserInfo() async {

    setState(() {
      // isLoading = true;
      // errorMessage = null;
    });

    try {
      final id = userInfo?['id'];

      final response =
      await DatabaseService.instance.getUserInfo(id,);
      print('Register response: $response');

      if (response['success'] == true) {
        if (mounted) {
          // await SessionManager.saveLoginData(response);
          // Navigator.pushNamed(context, AppRoutes.entryPoint);
          // Navigator.pop(context);
          return response;
        }
      } else {
        throw Exception(response['message'] ?? '_getUserInfo failed');
      }
    } catch (e) {
      print('_getUserInfo error: $e');
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
