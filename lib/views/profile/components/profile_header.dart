import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../../core/services/database_service.dart';
import '../../../core/utils/session_manager.dart';
import 'profile_header_options.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// Background
        Image.asset('assets/images/profile_background.png'),

        /// Content
        Column(
          children: [
            AppBar(
              automaticallyImplyLeading: false,
              title: const Text('Profile'),
              elevation: 0,
              backgroundColor: Colors.transparent,
              titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const _UserData(),
            const ProfileHeaderOptions()
          ],
        ),
      ],
    );
  }
}

class _UserData extends StatefulWidget {
  const _UserData();

  @override
  State<_UserData> createState() => _UserDataState();
}

class _UserDataState extends State<_UserData> {

  Map<String, dynamic>? userInfo;

  @override
  void initState() {
    super.initState();

    SessionManager.getUserInfo().then((res) {
      setState(() {
        userInfo = res;
      });
      _getUserInfo().then((user) {
        String firstName  = user?['data']?['firstName']??'';
        String lastName = user?['data']?['lastName']??'';
        if (userInfo != null && firstName.isNotEmpty && lastName.isNotEmpty) {
          setState(() {
            userInfo!["name"] = '$firstName $lastName';
          });
        }
      });
    });

    SessionManager.getUserInfo().then((res) {
      setState(() {
        userInfo = res;
        print('User name: ${userInfo?['name']}');
      });

    });

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Row(
        children: [
          const SizedBox(width: AppDefaults.padding),
          SizedBox(
            width: 100,
            height: 100,
            child: ClipOval(
              child: AspectRatio(
                aspectRatio: 1 / 1,
                child: Image.asset(
                  'assets/images/local_avatar.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDefaults.padding),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${userInfo?['name']??'Shirley Hart'}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'ID: ${userInfo?['id']??'157683'}',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.white),
              ),
            ],
          )
        ],
      ),
    );
  }
}
