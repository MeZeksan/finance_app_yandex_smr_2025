import 'package:auto_route/annotations.dart';
import 'package:finance_app_yandex_smr_2025/core/di/service_locator.dart';
import 'package:finance_app_yandex_smr_2025/core/services/theme_service.dart';
import 'package:finance_app_yandex_smr_2025/features/articles/data/repository/mock_articles_repository.dart';
import 'package:finance_app_yandex_smr_2025/features/articles/presentation/bloc/articles_bloc.dart';
import 'package:finance_app_yandex_smr_2025/features/articles/presentation/bloc/articles_event.dart';
import 'package:finance_app_yandex_smr_2025/features/articles/presentation/bloc/articles_state.dart';
import 'package:finance_app_yandex_smr_2025/features/articles/presentation/widgets/article_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class ArticlesScreen extends StatelessWidget {
  const ArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ArticlesBloc(
        repository: MockArticlesRepository(),
      )..add(const LoadArticles()),
      child: const ArticlesView(),
    );
  }
}

class ArticlesView extends StatefulWidget {
  const ArticlesView({super.key});

  @override
  State<ArticlesView> createState() => _ArticlesViewState();
}

class _ArticlesViewState extends State<ArticlesView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  late ThemeService _themeService;

  @override
  void initState() {
    super.initState();
    _themeService = ServiceLocator.themeService;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<ArticlesBloc>().add(SearchArticles(_searchController.text));
  }

  void _toggleSearchMode() {
    final currentState = context.read<ArticlesBloc>().state;
    final newMode = currentState.searchMode == SearchMode.regular
        ? SearchMode.fuzzy
        : SearchMode.regular;
    
    context.read<ArticlesBloc>().add(ToggleSearchMode(newMode));
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double topPadding = statusBarHeight + 16.0;

    return ListenableBuilder(
      listenable: _themeService,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _themeService.backgroundColor,
          body: BlocBuilder<ArticlesBloc, ArticlesState>(
        builder: (context, state) {
          return Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _themeService.headerColor,
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: topPadding),
                  child: Text(
                    'Мои статьи',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: _themeService.textColor,
                    ),
                  ),
                ),
              ),

              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: _themeService.containerColor,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Найти статью',
                          prefixIcon: Icon(Icons.search, color: _themeService.textColor),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: _themeService.textColor),
                                  onPressed: () {
                                    _searchController.clear();
                                    FocusScope.of(context).unfocus();
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: _themeService.backgroundColor,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _isSearching = true;
                          });
                        },
                        onSubmitted: (_) {
                          setState(() {
                            _isSearching = false;
                          });
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                    if (_isSearching || _searchController.text.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _toggleSearchMode,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: state.searchMode == SearchMode.fuzzy
                                ? _themeService.headerColor.withValues(alpha: 0.2)
                                : _themeService.textColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 16,
                                color: state.searchMode == SearchMode.fuzzy
                                    ? _themeService.headerColor
                                    : _themeService.textColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Fuzzy',
                                style: TextStyle(
                                  color: state.searchMode == SearchMode.fuzzy
                                      ? _themeService.headerColor
                                      : _themeService.textColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _buildContent(state),
              ),
            ],
          );
        },
      ),
        );
      },
    );
  }

  Widget _buildContent(ArticlesState state) {
    if (state.status == ArticlesStatus.loading && state.articles.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: _themeService.headerColor,
        ),
      );
    }

    if (state.status == ArticlesStatus.failure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              state.errorMessage ?? 'Произошла ошибка',
              style: TextStyle(
                fontSize: 16,
                color: Colors.red[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<ArticlesBloc>().add(const LoadArticles());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _themeService.headerColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (state.articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: _themeService.textColor.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Статьи не найдены'
                  : 'Нет доступных статей',
              style: TextStyle(
                fontSize: 16,
                color: _themeService.textColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: state.articles.length,
      itemBuilder: (context, index) {
        return ArticleTile(
          article: state.articles[index],
          isFirst: index == 0,
          isLast: index == state.articles.length - 1,
        );
      },
    );
  }
}
