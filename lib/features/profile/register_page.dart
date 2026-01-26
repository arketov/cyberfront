// lib/features/profile/register_page.dart
import 'dart:math';

import 'package:cyberdriver/core/navigation/app_section.dart';
import 'package:cyberdriver/core/theme/app_theme.dart';
import 'package:cyberdriver/core/ui/base_page.dart';
import 'package:cyberdriver/core/ui/cards/card_base.dart';
import 'package:cyberdriver/core/ui/widgets/app_notifications.dart';
import 'package:cyberdriver/core/ui/widgets/infinite_ticker.dart';
import 'package:cyberdriver/core/ui/widgets/kicker.dart';
import 'package:cyberdriver/core/ui/widgets/logo.dart';
import 'package:cyberdriver/core/auth/auth_service.dart';
import 'package:cyberdriver/core/network/api_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

TickerItem _choice(Random r, List<TickerItem> items) => items[r.nextInt(items.length)];

class RegisterPage extends BasePage {
  const RegisterPage({super.key});

  @override
  AppSection get section => AppSection.profile;

  @override
  List<TickerItem> buildTickerItems(BuildContext context) {
    final r = Random();
    return <TickerItem>[
      _choice(r, const [
        TickerItem('РЕГИСТРАЦИЯ'),
        TickerItem('НОВЫЙ ПРОФИЛЬ'),
        TickerItem('КИБЕРВОДИЛА'),
      ]),
      const TickerItem('РЕГИСТРАЦИЯ', accent: true),
      _choice(r, const [
        TickerItem('ЛОГИН'),
        TickerItem('ПАРОЛЬ'),
        TickerItem('ДОСТУП'),
      ]),
    ];
  }

  @override
  List<Widget> buildBlocks(BuildContext context) => const [
        _RegisterPanel(),
      ];
}

class _RegisterPanel extends StatefulWidget {
  const _RegisterPanel();

  @override
  State<_RegisterPanel> createState() => _RegisterPanelState();
}

class _RegisterPanelState extends State<_RegisterPanel> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _tokenController = TextEditingController();
  String? _error;
  bool _submitting = false;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_error != null) {
      setState(() => _error = null);
    }
  }

  String? _validate() {
    final login = _loginController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();
    final token = _tokenController.text.trim();

    final loginOk = RegExp(r'^[a-zA-Z0-9_-]{3,50}$').hasMatch(login);
    if (!loginOk) {
      return 'Логин: 3–50 символов, латиница/цифры/-/_';
    }
    if (password.length < 6 || password.length > 28) {
      return 'Пароль: 6–28 символов';
    }
    if (name.isEmpty) {
      return 'Имя: обязательное поле';
    }
    if (token.isEmpty) {
      return 'Рег токен: обязательное поле';
    }
    return null;
  }

  void _handleRegister() {
    final validation = _validate();
    if (validation != null) {
      setState(() => _error = validation);
      return;
    }
    setState(() => _submitting = true);
    _submitRegistration();
  }

  Future<void> _submitRegistration() async {
    final login = _loginController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();
    final token = _tokenController.text.trim();

    try {
      final auth = await AuthService.getInstance();
      await auth.register(
        login: login,
        password: password,
        regToken: token,
        name: name,
      );
      if (!mounted) return;
      AppNotifications.show('Регистрация успешна');
      Navigator.of(context).pushReplacementNamed('/profile');
    } catch (e) {
      if (!mounted) return;
      if (e is ApiException) {
        setState(() => _error = e.message);
      } else {
        setState(() => _error = 'Ошибка регистрации: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = Theme.of(context).extension<AppPalette>();
    final errorStyle = textTheme.bodySmall?.copyWith(color: Colors.redAccent);

    final viewportHeight = MediaQuery.of(context).size.height;
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: viewportHeight * 0.75),
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 640;
            final maxWidth = isWide ? 760.0 : 420.0;
            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Logo(
                    size: 36,
                    gap: 0,
                    alignment: Alignment.center,
                  ),
                  const SizedBox(height: 5),
                  const Kicker('Создай доступ'),
                  const SizedBox(height: 22),
                  _RegisterCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        LayoutBuilder(
                          builder: (context, innerConstraints) {
                            const spacing = 16.0;
                            final availableWidth = innerConstraints.maxWidth;
                            final useTwoColumns = availableWidth >= 520;
                            final fieldWidth = useTwoColumns
                                ? (availableWidth - spacing) / 2
                                : availableWidth;

                            Widget fieldBlock({
                              required Widget field,
                              required String hint,
                            }) {
                              return SizedBox(
                                width: fieldWidth,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    field,
                                    const SizedBox(height: 6),
                                    Text(
                                      hint,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withValues(alpha: 0.55),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return Wrap(
                              spacing: spacing,
                              runSpacing: 12,
                              children: [
                                fieldBlock(
                                  field: TextField(
                                    controller: _loginController,
                                    textInputAction: TextInputAction.next,
                                    onChanged: (_) => _clearError(),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[a-zA-Z0-9_-]'),
                                      ),
                                      LengthLimitingTextInputFormatter(50),
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: '[ЭТО ЛОГИН]',
                                    ),
                                  ),
                                  hint: 'Латиница/цифры/-/_ — 3–50 символов',
                                ),
                                fieldBlock(
                                  field: TextField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    textInputAction: TextInputAction.next,
                                    onChanged: (_) => _clearError(),
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(28),
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: '[ЭТО ПАРОЛЬ]',
                                    ),
                                  ),
                                  hint: 'Длина 6–28 символов',
                                ),
                                fieldBlock(
                                  field: TextField(
                                    controller: _nameController,
                                    textInputAction: TextInputAction.next,
                                    onChanged: (_) => _clearError(),
                                    decoration: const InputDecoration(
                                      labelText: '[ЭТО ИМЯ]',
                                    ),
                                  ),
                                  hint: 'Обязательное поле',
                                ),
                                fieldBlock(
                                  field: TextField(
                                    controller: _tokenController,
                                    textInputAction: TextInputAction.done,
                                    onChanged: (_) => _clearError(),
                                    decoration: const InputDecoration(
                                      labelText: '[РЕГ ТОКЕН]',
                                    ),
                                  ),
                                  hint: 'Обязательное поле',
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        if (_error != null) ...[
                          Text(_error!, style: errorStyle),
                          const SizedBox(height: 10),
                        ],
                        SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: _submitting ? null : _handleRegister,
                            child: _submitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('ЗАРЕГИСТРИРОВАТЬСЯ'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed('/profile'),
                    child: Text(
                      'УЖЕ ЕСТЬ АККАУНТ? ВОЙТИ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: palette?.pink ??
                            Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RegisterCard extends CardBase {
  const _RegisterCard({required this.child});

  final Widget child;

  @override
  Widget buildContent(BuildContext context) => child;
}
