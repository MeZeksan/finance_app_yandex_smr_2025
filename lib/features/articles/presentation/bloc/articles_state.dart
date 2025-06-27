import 'package:equatable/equatable.dart';
import 'package:finance_app_yandex_smr_2025/features/articles/data/models/article.dart';

enum ArticlesStatus { initial, loading, success, failure }
enum SearchMode { regular, fuzzy }

class ArticlesState extends Equatable {
  final ArticlesStatus status;
  final List<Article> articles;
  final String searchQuery;
  final SearchMode searchMode;
  final String? errorMessage;

  const ArticlesState({
    this.status = ArticlesStatus.initial,
    this.articles = const [],
    this.searchQuery = '',
    this.searchMode = SearchMode.regular,
    this.errorMessage,
  });

  ArticlesState copyWith({
    ArticlesStatus? status,
    List<Article>? articles,
    String? searchQuery,
    SearchMode? searchMode,
    String? errorMessage,
  }) {
    return ArticlesState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      searchQuery: searchQuery ?? this.searchQuery,
      searchMode: searchMode ?? this.searchMode,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, articles, searchQuery, searchMode, errorMessage];
} 