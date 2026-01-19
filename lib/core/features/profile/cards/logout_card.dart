import 'package:flutter/material.dart';

import 'package:cyberdriver/app/app_router.dart';
import 'package:cyberdriver/core/auth/auth_service.dart';
import 'package:cyberdriver/core/media/media_cache_service.dart';

class LogoutCard extends StatelessWidget {
  const LogoutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LogoutButton();
  }
}

class _LogoutButton extends StatefulWidget {
  const _LogoutButton();

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _loggingOut = false;

  Future<void> _handleLogout() async {
    if (_loggingOut) return;
    setState(() {
      _loggingOut = true;
    });

    final auth = await AuthService.getInstance();
    try {
      await auth.logout();
    } catch (_) {}
    try {
      await MediaCacheService.instance.clearAll();
    } catch (_) {}

    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRouter.start, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: _loggingOut ? null : _handleLogout,
        child: _loggingOut
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('ВЫЙТИ'),
      ),
    );
  }
}
