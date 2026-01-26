import 'dart:math';

import 'package:cyberdriver/core/auth/auth_service.dart';
import 'package:cyberdriver/core/config/app_config.dart';
import 'package:cyberdriver/core/network/api_client_provider.dart';
import 'package:cyberdriver/core/ui/cards/collapsible_card_base.dart';
import 'package:cyberdriver/core/ui/widgets/app_notifications.dart';
import 'package:cyberdriver/core/utils/date_time_service.dart';
import 'package:cyberdriver/features/admin/data/admin_reg_tokens_api.dart';
import 'package:cyberdriver/shared/models/reg_token_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdminRegTokensCard extends CollapsibleCardBase {
  AdminRegTokensCard({super.key});

  @override
  String get kickerText => '[РЕГ ТОКЕНЫ]';

  @override
  Color? get kickerColor => Colors.white70;

  @override
  Widget buildExpandedContent(BuildContext context, bool expanded) =>
      _AdminRegTokensContent(active: expanded);
}

class _AdminRegTokensContent extends StatefulWidget {
  const _AdminRegTokensContent({required this.active});

  final bool active;

  @override
  State<_AdminRegTokensContent> createState() => _AdminRegTokensContentState();
}

class _AdminRegTokensContentState extends State<_AdminRegTokensContent> {
  static const double _listHeight = 280;

  final ScrollController _scroll = ScrollController();
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _descrController = TextEditingController();

  late final AdminRegTokensApi _api;
  AuthService? _auth;
  bool _authReady = false;

  final List<RegTokenDto> _items = [];
  bool _loadingMore = false;
  bool _loadingInitial = false;
  bool _saving = false;
  bool _deleting = false;
  String? _listError;
  String? _formError;
  int _currentPage = 0;
  int _maxPage = 1;
  bool _activated = false;

  @override
  void initState() {
    super.initState();
    _api = AdminRegTokensApi(createApiClient(AppConfig.dev));
    _activateIfNeeded();
    _scroll.addListener(_handleScroll);
  }

  @override
  void didUpdateWidget(covariant _AdminRegTokensContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _activateIfNeeded();
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_handleScroll);
    _scroll.dispose();
    _tokenController.dispose();
    _descrController.dispose();
    super.dispose();
  }

  void _activateIfNeeded() {
    if (!widget.active || _activated) return;
    _activated = true;
    _initAuth();
  }

  Future<void> _initAuth() async {
    final auth = await AuthService.getInstance();
    await auth.loadSession();
    if (!mounted) return;
    setState(() {
      _auth = auth;
      _authReady = true;
    });
    _loadNextPage();
  }

  void _handleScroll() {
    if (_loadingMore || !_scroll.hasClients) return;
    final pos = _scroll.position;
    if (pos.maxScrollExtent <= 0) return;
    if (pos.pixels >= pos.maxScrollExtent - 120) {
      _loadNextPage();
    }
  }

  Future<void> _loadNextPage() async {
    if (_loadingMore || _loadingInitial) return;
    if (_currentPage >= _maxPage && _currentPage != 0) return;
    final auth = _auth;
    if (auth == null) return;

    final isInitial = _items.isEmpty;
    setState(() {
      _listError = null;
      if (isInitial) {
        _loadingInitial = true;
      } else {
        _loadingMore = true;
      }
    });

    final nextPage = _currentPage == 0 ? 1 : _currentPage + 1;
    try {
      final res = await _api.getTokensWithAuth(auth, page: nextPage);
      if (!mounted) return;
      setState(() {
        _currentPage = res.currentPage;
        _maxPage = res.maxPage;
        _items.addAll(res.data);
        _loadingInitial = false;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _listError = 'Ошибка загрузки токенов';
        _loadingInitial = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _remove(RegTokenDto item) async {
    if (_deleting) return;
    final auth = _auth;
    if (auth == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Удалить токен?'),
          content: const Text('Это действие нельзя отменить.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('ОТМЕНА'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('УДАЛИТЬ'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    setState(() => _deleting = true);
    try {
      await _api.deleteTokenWithAuth(auth, item.regToken);
      if (!mounted) return;
      setState(() {
        _items.removeWhere((e) => e.regToken == item.regToken);
        _deleting = false;
      });
      AppNotifications.show('Токен удален');
    } catch (e) {
      if (!mounted) return;
      setState(() => _deleting = false);
      AppNotifications.error('Ошибка удаления: $e');
    }
  }

  void _generateToken() {
    _tokenController.text = _randomToken(16);
  }

  Future<void> _copyToken(String token) async {
    await Clipboard.setData(ClipboardData(text: token));
    AppNotifications.show('Токен скопирован');
  }

  String? _validate() {
    final token = _tokenController.text.trim();
    final descr = _descrController.text.trim();
    if (token.length < 8) {
      return 'Токен: минимум 8 символов';
    }
    if (token.length > 255) {
      return 'Токен: максимум 255 символов';
    }
    if (descr.length > 100) {
      return 'Описание: максимум 100 символов';
    }
    return null;
  }

  Future<void> _createToken() async {
    if (_saving) return;
    final auth = _auth;
    if (auth == null || auth.session == null) return;

    final validation = _validate();
    if (validation != null) {
      setState(() => _formError = validation);
      return;
    }

    final token = _tokenController.text.trim();
    final descr = _descrController.text.trim();

    setState(() {
      _saving = true;
      _formError = null;
    });

    try {
      await _api.createTokenWithAuth(auth, regToken: token, descr: descr);
      if (!mounted) return;
      setState(() {
        _items.insert(
          0,
          RegTokenDto(
            regToken: token,
            descr: descr,
            createdAt: DateTime.now().toUtc().toIso8601String(),
          ),
        );
        _tokenController.clear();
        _descrController.clear();
        _saving = false;
      });
      AppNotifications.show('Токен создан');
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppNotifications.error('Ошибка создания: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_authReady) {
      return const SizedBox.shrink();
    }
    final auth = _auth;
    if (auth == null || auth.session == null) {
      return const SizedBox.shrink();
    }

    final inputStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.92),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TokensList(
          items: _items,
          controller: _scroll,
          height: _listHeight,
          onDelete: _remove,
          onCopy: _copyToken,
          isLoadingMore: _loadingMore,
          isLoadingInitial: _loadingInitial,
          error: _listError,
          onRetry: _loadNextPage,
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _tokenController,
          maxLength: 255,
          style: inputStyle,
          decoration: InputDecoration(
            labelText: '[РЕГ ТОКЕН]',
            suffixIcon: IconButton(
              onPressed: _generateToken,
              icon: const Icon(Icons.casino_outlined, size: 18),
              tooltip: 'Сгенерировать',
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _descrController,
          maxLength: 100,
          minLines: 2,
          maxLines: 4,
          style: inputStyle,
          decoration: const InputDecoration(
            labelText: '[ОПИСАНИЕ]',
          ),
        ),
        if (_formError != null) ...[
          const SizedBox(height: 10),
          Text(
            _formError!,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.redAccent),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: _saving ? null : _createToken,
                child: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('СОЗДАТЬ'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: _saving
                    ? null
                    : () {
                        _tokenController.clear();
                        _descrController.clear();
                        setState(() => _formError = null);
                      },
                child: const Text('ОЧИСТИТЬ'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _randomToken(int length) {
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = Random();
    return List.generate(length, (_) => alphabet[r.nextInt(alphabet.length)])
        .join();
  }
}

class _TokensList extends StatelessWidget {
  const _TokensList({
    required this.items,
    required this.controller,
    required this.height,
    required this.onDelete,
    required this.onCopy,
    required this.isLoadingMore,
    required this.isLoadingInitial,
    required this.error,
    required this.onRetry,
  });

  final List<RegTokenDto> items;
  final ScrollController controller;
  final double height;
  final ValueChanged<RegTokenDto> onDelete;
  final ValueChanged<String> onCopy;
  final bool isLoadingMore;
  final bool isLoadingInitial;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (isLoadingInitial && items.isEmpty) {
      return Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withValues(alpha: 0.04),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (error != null && items.isEmpty) {
      return Container(
        height: height,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withValues(alpha: 0.04),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              error!,
              style: TextStyle(
                color: cs.onSurface.withValues(alpha: .75),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onRetry,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      return Container(
        height: height,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withValues(alpha: 0.04),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: Text(
          'Пока нет токенов',
          style: TextStyle(
            color: cs.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Container(
      height: height,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
        child: ScrollConfiguration(
          behavior: const ScrollBehavior(),
          child: ListView.separated(
            controller: controller,
            padding: EdgeInsets.zero,
            itemCount: items.length + (isLoadingMore ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              if (i >= items.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              );
            }
            final item = items[i];
            return _RegTokenRow(
              item: item,
              onDelete: () => onDelete(item),
              onCopy: () => onCopy(item.regToken),
            );
          },
        ),
      ),
    );
  }
}

class _RegTokenRow extends StatelessWidget {
  const _RegTokenRow({
    required this.item,
    required this.onDelete,
    required this.onCopy,
  });

  final RegTokenDto item;
  final VoidCallback onDelete;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final createdLocal = DateTimeService.toLocal(item.createdAt);
    final dateText = DateTimeService.formatDayMonth(createdLocal);
    final timeText = DateTimeService.formatTime(createdLocal);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onCopy,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: cs.surface.withValues(alpha: 0.12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.regToken,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                    if (item.descr.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.descr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    dateText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    timeText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onDelete,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
