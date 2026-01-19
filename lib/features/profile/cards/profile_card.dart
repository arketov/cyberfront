import 'dart:io';

import 'package:flutter/material.dart';

import 'package:cyberdriver/core/config/app_config.dart';
import 'package:cyberdriver/core/media/media_cache_service.dart';
import 'package:cyberdriver/core/ui/cards/card_base.dart';
import 'package:cyberdriver/core/ui/widgets/kicker.dart';
import 'package:cyberdriver/core/ui/widgets/sub_card.dart';
import 'package:cyberdriver/shared/models/user_dto.dart';

const double _avatarSize = 64.0;
const Duration _cacheDuration = Duration(days: 1);

class ProfileCard extends StatefulWidget {
  const ProfileCard({
    super.key,
    required this.user,
    required this.mediaCache,
    required this.config,
  });

  final UserDto? user;
  final MediaCacheService mediaCache;
  final AppConfig config;

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  bool _expanded = false;

  static const _miniBlocks = [
    SubCard(title: 'Хеллоу', value: "Дарова"),
    SubCard(title: 'Хеллоу', value: "Дарова"),
    SubCard(title: 'Хеллоу', value: "Дарова"),
    SubCard(title: 'Хеллоу', value: "Дарова"),
    SubCard(title: 'Хеллоу', value: "Дарова"),
    SubCard(title: 'Хеллоу', value: "Дарова"),
    SubCard(title: 'Хеллоу', value: "Дарова"),
    SubCard(title: 'Хеллоу', value: "Дарова"),
    SubCard(title: 'Хеллоу', value: "Дарова"),
    SubCard(title: 'Хеллоу', value: "Дарова"),
    SubCard(title: 'Хеллоу', value: "Дарова"),

  ];

  void _toggleExpanded() {
    if (_miniBlocks.isEmpty) return;
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    return _ProfileCardShell(
      onTapCallback: _toggleExpanded,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (widget.user == null) {
      return const Text('Нет данных пользователя');
    }

    final textTheme = Theme.of(context).textTheme;

    final titleStyle = textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w900,
    );

    final metaLabelStyle = textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: 0.9,
      color: Colors.white.withValues(alpha: 0.60),
    );

    final metaValueStyle = textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: 0.9,
      color: Colors.white.withValues(alpha: 0.68),
    );

    final user = widget.user!;
    final displayName = user.name.isEmpty ? user.login : user.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Kicker('[ЭТО ТЫ]', color: Colors.white70),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileAvatar(
              imageHash: user.imageHash,
              mediaCache: widget.mediaCache,
              config: widget.config,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayName, style: titleStyle),
                  const SizedBox(height: 4),
                  _MetaLine(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    span: TextSpan(
                      children: [
                        _kv(
                          'LOGIN',
                          user.login,
                          metaLabelStyle,
                          metaValueStyle,
                        ),
                        _dot(metaLabelStyle),
                        _kv(
                          'EMAIL',
                          user.email,
                          metaLabelStyle,
                          metaValueStyle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  _MetaLine(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    span: TextSpan(
                      children: [
                        _kv('REGISTERED', '', metaLabelStyle, metaValueStyle),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const _StatGrid(
          items: [
            // _StatItem('aga', 'ugu', SubCardTone.pink),
          ],
        ),
        if (_miniBlocks.isNotEmpty) ...[
          const SizedBox(height: 14),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints:
                  _expanded ? const BoxConstraints() : const BoxConstraints(maxHeight: 0),
              child: ClipRect(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _miniBlocks,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ProfileCardShell extends CardBase {
  const _ProfileCardShell({
    required this.child,
    required this.onTapCallback,
  });

  final Widget child;
  final VoidCallback onTapCallback;

  @override
  VoidCallback? onTap(BuildContext context) => onTapCallback;

  @override
  Widget buildContent(BuildContext context) => child;
}

class _StatItem {
  const _StatItem(this.title, this.value, this.tone);

  final String title;
  final String value;
  final SubCardTone tone;
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.items});

  final List<_StatItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTwoColumn = constraints.maxWidth >= 360;
        if (!isTwoColumn) {
          return Column(
            children: [
              for (final item in items) ...[
                SubCard(title: item.title, value: item.value, tone: item.tone),
                if (item != items.last) const SizedBox(height: 12),
              ],
            ],
          );
        }

        final rows = <Widget>[];
        for (var i = 0; i < items.length; i += 2) {
          final left = items[i];
          final right = i + 1 < items.length ? items[i + 1] : null;
          rows.add(
            Row(
              children: [
                Expanded(
                  child: SubCard(
                    title: left.title,
                    value: left.value,
                    tone: left.tone,
                  ),
                ),
                if (right != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: SubCard(
                      title: right.title,
                      value: right.value,
                      tone: right.tone,
                    ),
                  ),
                ],
              ],
            ),
          );
          if (i + 2 < items.length) {
            rows.add(const SizedBox(height: 12));
          }
        }

        return Column(children: rows);
      },
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.span, this.maxLines, this.overflow});

  final InlineSpan span;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      span,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: true,
    );
  }
}

TextSpan _kv(
  String label,
  String value,
  TextStyle? labelStyle,
  TextStyle? valueStyle,
) {
  return TextSpan(
    children: [
      TextSpan(text: '$label: ', style: labelStyle),
      TextSpan(text: value.isEmpty ? '—' : value, style: valueStyle),
    ],
  );
}

TextSpan _dot(TextStyle? style) => TextSpan(text: ' • ', style: style);

class _ProfileMiniBlock extends StatelessWidget {
  const _ProfileMiniBlock({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: Colors.white.withOpacity(0.72),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.imageHash,
    required this.mediaCache,
    required this.config,
  });

  final String imageHash;
  final MediaCacheService mediaCache;
  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: _avatarSize,
      height: _avatarSize,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: const Icon(Icons.person, size: 28),
    );

    if (imageHash.isEmpty) {
      return placeholder;
    }

    return FutureBuilder<File>(
      future: mediaCache.getImageFile(
        id: imageHash,
        cacheDuration: _cacheDuration,
        config: config,
      ),
      builder: (context, snapshot) {
        final file = snapshot.data;
        if (file == null) {
          return placeholder;
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.file(
            file,
            width: _avatarSize,
            height: _avatarSize,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
