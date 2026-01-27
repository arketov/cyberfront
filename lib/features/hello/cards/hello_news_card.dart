// lib/features/hello/cards/hello_news_card.dart
import 'package:cyberdriver/core/config/app_config.dart';
import 'package:cyberdriver/core/network/api_client_provider.dart';
import 'package:cyberdriver/core/ui/cards/card_base.dart';
import 'package:cyberdriver/features/news/cards/news_card.dart';
import 'package:cyberdriver/features/news/data/news_api.dart';
import 'package:cyberdriver/shared/models/news_dto.dart';
import 'package:flutter/material.dart';

class HelloNewsCard extends StatefulWidget {
  const HelloNewsCard({super.key});

  @override
  State<HelloNewsCard> createState() => _HelloNewsCardState();
}

class _HelloNewsCardState extends State<HelloNewsCard> {
  late final NewsApi _api;
  late Future<NewsDto?> _future;

  @override
  void initState() {
    super.initState();
    _api = NewsApi(createApiClient(AppConfig.dev));
    _future = _loadLatest();
  }

  Future<NewsDto?> _loadLatest() async {
    final page = await _api.getNewsPage(page: 1);
    if (page.data.isEmpty) return null;
    return page.data.first;
  }

  void _retry() {
    setState(() {
      _future = _loadLatest();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<NewsDto?>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _LoadingNewsCard();
        }

        if (snap.hasError) {
          return _EmptyNewsCard(
            message: 'Ошибка загрузки новостей',
            onRetry: _retry,
          );
        }

        final news = snap.data;
        if (news == null) {
          return const _EmptyNewsCard(message: 'Новостей пока нет');
        }

        return NewsCard(
          news: news,
          onAllTap: () => Navigator.of(context).pushNamed('/news'),
          showKicker: true,
        );
      },
    );
  }
}

class _LoadingNewsCard extends CardBase {
  const _LoadingNewsCard();

  @override
  Widget buildContent(BuildContext context) {
    return const SizedBox(
      height: 120,
      child: Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _EmptyNewsCard extends CardBase {
  const _EmptyNewsCard({
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget buildContent(BuildContext context) {
    final textStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: Colors.white.withValues(alpha: 0.75));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '[НОВОСТИ]',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 10),
        Text(message, style: textStyle),
        if (onRetry != null) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            child: const Text('Повторить'),
          ),
        ],
      ],
    );
  }
}
