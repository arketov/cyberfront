// lib/features/profile/profile_page.dart

import 'dart:math';
import 'package:cyberdriver/features/profile/cards/logout_card.dart';
import 'package:cyberdriver/features/profile/cards/profile_card.dart';
import 'package:flutter/material.dart';

import 'package:cyberdriver/core/auth/auth_service.dart';
import 'package:cyberdriver/core/config/app_config.dart';
import 'package:cyberdriver/core/media/media_cache_service.dart';
import 'package:cyberdriver/core/navigation/app_section.dart';
import 'package:cyberdriver/core/ui/base_page.dart';
import 'package:cyberdriver/core/ui/cards/card_base.dart';
import 'package:cyberdriver/core/ui/widgets/cyber_dots_loader.dart';
import 'package:cyberdriver/core/ui/widgets/infinite_ticker.dart';
import 'package:cyberdriver/core/ui/widgets/kicker.dart';
import 'package:cyberdriver/core/ui/widgets/logo.dart';
import 'package:cyberdriver/shared/models/user_dto.dart';

TickerItem _choice(Random r, List<TickerItem> items) => items[r.nextInt(items.length)];

class ProfilePage extends BasePage {
  const ProfilePage({super.key});

  @override
  AppSection get section => AppSection.profile;

  @override
  List<TickerItem> buildTickerItems(BuildContext context) {
    final r = Random();
    return <TickerItem>[
      _choice(r, const [
        TickerItem('АНАЛОГОВЫЙ ПАС', accent: true),
        TickerItem('АНАЛЬГИНОВЫЙ', accent: true),
        TickerItem('ПРОФНАСТИЛ', accent: true),
      ]),
      const TickerItem('КИБЕРВОДИЛА', accent: true),
      _choice(r, const [
        TickerItem('ПОРТФЕЛЬ', accent: true),
        TickerItem('АНКЕТА', accent: true),
        TickerItem('МЕДКАРТА', accent: true),
      ]),
      const TickerItem('КИБЕРВОДИЛА', accent: true),
      _choice(r, const [
        TickerItem('СТАТЫ'),
        TickerItem('ДОСТИЖЕНИЯ'),
        TickerItem('ЛИГА'),
        TickerItem('СЕЗОН'),
        TickerItem('РЕЙТИНГ'),
      ]),
      const TickerItem('КИБЕРВОДИЛА', accent: true),
      _choice(r, const [
        TickerItem('СНЮС', accent: true),
        TickerItem('ПАС', accent: true),
        TickerItem('2FA', accent: true),
      ]),
    ];
  }

  @override
  List<Widget> buildBlocks(BuildContext context) {
    return [
      const ProfileGate(),
    ];
  }
}

class ProfileGate extends StatefulWidget {
  const ProfileGate({super.key});

  @override
  State<ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<ProfileGate> {
  AuthService? _auth;
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    final auth = await AuthService.getInstance();
    await auth.loadSession();
    if (!mounted) return;
    setState(() {
      _auth = auth;
      _loading = false;
    });
  }

  Future<void> _handleLogin() async {
    if (_auth == null) return;
    final username = _loginController.text.trim();
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = 'Введите логин и пароль');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await _auth!.login(username: username, password: password);
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Ошибка входа: $e');
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  void _clearError() {
    if (_error != null) {
      setState(() => _error = null);
    }
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CyberDotsLoader());
    }

    final session = _auth?.session;
    if (session == null) {
      final viewportHeight = MediaQuery.of(context).size.height;
      return ConstrainedBox(
        constraints: BoxConstraints(minHeight: viewportHeight * 0.65),
        child: Center(
          child: _LoginPanel(
            loginController: _loginController,
            passwordController: _passwordController,
            error: _error,
            submitting: _submitting,
            onLogin: _submitting ? null : _handleLogin,
            onChanged: _clearError,
          ),
        ),
      );
    }

    return _ProfileSummaryCard(
      user: session.user,
      mediaCache: MediaCacheService.instance,
      config: AppConfig.dev,
    );
  }
}

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({
    required this.loginController,
    required this.passwordController,
    required this.error,
    required this.submitting,
    required this.onLogin,
    required this.onChanged,
  });

  final TextEditingController loginController;
  final TextEditingController passwordController;
  final String? error;
  final bool submitting;
  final VoidCallback? onLogin;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final errorStyle = textTheme.bodySmall?.copyWith(color: Colors.redAccent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Logo(
          size: 36,
          gap: 0,
          alignment: Alignment.center,
        ),
        const SizedBox(height: 5),
        const Kicker('Кто ты, КиберВоин?'),
        const SizedBox(height: 22),
        LoginCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: loginController,
                textInputAction: TextInputAction.next,
                onChanged: (_) => onChanged(),
                decoration: const InputDecoration(
                  labelText: '[ЭТО ЛОГИН]',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onChanged: (_) => onChanged(),
                onSubmitted: (_) => onLogin?.call(),
                decoration: const InputDecoration(
                  labelText: '[ЭТО ПАРОЛЬ]',
                ),
              ),
              const SizedBox(height: 14),
              if (error != null) ...[
                Text(error!, style: errorStyle),
                const SizedBox(height: 10),
              ],
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: onLogin,
                  child: submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('ВОЙТИ'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LoginCard extends CardBase {
  const LoginCard({super.key, required this.child});

  final Widget child;

  @override
  Widget buildContent(BuildContext context) => child;
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({
    required this.user,
    required this.mediaCache,
    required this.config,
  });

  final UserDto user;
  final MediaCacheService mediaCache;
  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileCard(user: user, mediaCache: mediaCache, config: config),
        const SizedBox(height: 12),
        const LogoutCard(),
      ],
    );
  }
}
