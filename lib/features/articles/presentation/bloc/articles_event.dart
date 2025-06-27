import 'package:equatable/equatable.dart';
import 'package:finance_app_yandex_smr_2025/features/articles/presentation/bloc/articles_state.dart';

abstract class ArticlesEvent extends Equatable {
  const ArticlesEvent();

  @override
  List<Object?> get props => [];
}

class LoadArticles extends ArticlesEvent {
  const LoadArticles();
}

class SearchArticles extends ArticlesEvent {
  final String query;

  const SearchArticles(this.query);

  @override
  List<Object?> get props => [query];
}

class ToggleSearchMode extends ArticlesEvent {
  final SearchMode searchMode;

  const ToggleSearchMode(this.searchMode);

  @override
  List<Object?> get props => [searchMode];
} 