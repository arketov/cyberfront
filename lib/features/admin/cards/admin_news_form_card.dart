// lib/features/admin/cards/admin_news_form_card.dart
import 'dart:io';

import 'package:cyberdriver/core/auth/auth_service.dart';
import 'package:cyberdriver/core/config/app_config.dart';
import 'package:cyberdriver/core/network/api_client_provider.dart';
import 'package:cyberdriver/core/ui/cards/collapsible_card_base.dart';
import 'package:cyberdriver/core/ui/widgets/app_notifications.dart';
import 'package:cyberdriver/features/admin/data/admin_news_api.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AdminNewsFormCard extends CollapsibleCardBase {
  AdminNewsFormCard({super.key});

  @override
  String get kickerText => '[ДОБАВИТЬ НОВОСТЬ]';

  @override
  Color? get kickerColor => Colors.white70;

  @override
  Widget buildExpandedContent(BuildContext context, bool expanded) =>
      const _AdminNewsFormContent();
}

class _AdminNewsFormContent extends StatefulWidget {
  const _AdminNewsFormContent();

  @override
  State<_AdminNewsFormContent> createState() => _AdminNewsFormContentState();
}

class _AdminNewsFormContentState extends State<_AdminNewsFormContent> {
  static const int _titleMin = 10;
  static const int _titleMax = 255;
  static const int _bodyMin = 10;

  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final PageController _pageController = PageController();
  final List<File> _images = [];

  late final AdminNewsApi _api;
  AuthService? _auth;
  bool _authReady = false;
  bool _saving = false;
  String? _error;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _api = AdminNewsApi(createApiClient(AppConfig.dev));
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
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result == null) return;

    final files = result.files
        .where((f) => f.path != null && f.path!.isNotEmpty)
        .map((f) => File(f.path!))
        .toList();
    if (files.isEmpty) return;

    setState(() {
      _images.addAll(files);
      _index = _index.clamp(0, _images.length - 1);
    });
  }

  void _removeImage(int i) {
    if (i < 0 || i >= _images.length) return;
    setState(() {
      _images.removeAt(i);
      if (_images.isEmpty) {
        _index = 0;
      } else {
        _index = _index.clamp(0, _images.length - 1);
      }
    });
  }

  void _resetForm() {
    setState(() {
      _titleController.clear();
      _bodyController.clear();
      _images.clear();
      _index = 0;
      _error = null;
    });
  }

  String? _validate() {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.length < _titleMin) {
      return 'Заголовок: минимум $_titleMin символов';
    }
    if (title.length > _titleMax) {
      return 'Заголовок: максимум $_titleMax символов';
    }
    if (body.length < _bodyMin) {
      return 'Текст: минимум $_bodyMin символов';
    }
    return null;
  }

  Future<void> _save() async {
    if (_saving) return;
    final auth = _auth;
    if (auth == null || auth.session == null) return;

    final validation = _validate();
    if (validation != null) {
      setState(() => _error = validation);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final newsId = await _api.createNewsWithAuth(
        auth,
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
      );
      for (final image in _images) {
        await _api.uploadImageWithAuth(auth, newsId, image);
      }
      if (!mounted) return;
      _resetForm();
      AppNotifications.show('Новость создана');
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Ошибка сохранения: $e');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
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
        _ImageCarousel(
          images: _images,
          controller: _pageController,
          index: _index,
          onIndexChanged: (i) => setState(() => _index = i),
          onRemove: _removeImage,
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _saving ? null : _pickImages,
            icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
            label: const Text('ДОБАВИТЬ КАРТИНКУ'),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _titleController,
          maxLength: _titleMax,
          style: inputStyle,
          decoration: const InputDecoration(
            labelText: '[ЗАГОЛОВОК]',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _bodyController,
          minLines: 6,
          maxLines: 16,
          style: inputStyle,
          decoration: const InputDecoration(
            labelText: '[ТЕКСТ]',
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(
            _error!,
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
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('СОХРАНИТЬ'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: _saving ? null : _resetForm,
                child: const Text('ОТМЕНА'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ImageCarousel extends StatelessWidget {
  const _ImageCarousel({
    required this.images,
    required this.controller,
    required this.index,
    required this.onIndexChanged,
    required this.onRemove,
  });

  final List<File> images;
  final PageController controller;
  final int index;
  final ValueChanged<int> onIndexChanged;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (images.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withValues(alpha: 0.04),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.image, color: cs.onSurface.withValues(alpha: 0.35)),
      );
    }

    return SizedBox(
      height: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            PageView.builder(
              controller: controller,
              itemCount: images.length,
              onPageChanged: onIndexChanged,
              itemBuilder: (context, i) {
                return Image.file(
                  images[i],
                  fit: BoxFit.cover,
                );
              },
            ),
            Positioned(
              top: 10,
              right: 10,
              child: _TrashButton(
                onTap: () => onRemove(index),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _Dots(current: index, total: images.length),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrashButton extends StatelessWidget {
  const _TrashButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.delete_outline, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final safeTotal = total <= 0 ? 1 : total;
    final safeIndex = current.clamp(0, safeTotal - 1);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < safeTotal; i++)
          Container(
            width: i == safeIndex ? 8 : 6,
            height: i == safeIndex ? 8 : 6,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i == safeIndex
                  ? cs.primary.withValues(alpha: 0.9)
                  : Colors.white.withValues(alpha: 0.25),
            ),
          ),
      ],
    );
  }
}
