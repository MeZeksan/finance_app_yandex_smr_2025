import 'package:finance_app_yandex_smr_2025/features/articles/data/models/article.dart';
import 'package:flutter/material.dart';

class MockArticlesRepository {
  final List<Article> _articles = [
    Article(
      id: '1',
      title: 'Аренда квартиры',
      category: 'Жилье',
      emoji: '🏠',
      iconBackground: Colors.green[100]!,
    ),
    Article(
      id: '2',
      title: 'Одежда',
      category: 'Покупки',
      emoji: '👚',
      iconBackground: Colors.purple[100]!,
    ),
    Article(
      id: '3',
      title: 'На собачку',
      category: 'Питомцы',
      emoji: '🐶',
      iconBackground: Colors.brown[100]!,
    ),
    Article(
      id: '4',
      title: 'На собачку (корм)',
      category: 'Питомцы',
      emoji: '🐕',
      iconBackground: Colors.brown[100]!,
    ),
    Article(
      id: '5',
      title: 'Ремонт квартиры',
      category: 'Жилье',
      emoji: '🔨',
      iconBackground: Colors.green[100]!,
    ),
    Article(
      id: '6',
      title: 'Продукты',
      category: 'Еда',
      emoji: '🍎',
      iconBackground: Colors.pink[100]!,
    ),
    Article(
      id: '7',
      title: 'Спортзал',
      category: 'Здоровье',
      emoji: '🏋️',
      iconBackground: Colors.blue[100]!,
    ),
    Article(
      id: '8',
      title: 'Медицина',
      category: 'Здоровье',
      emoji: '💊',
      iconBackground: Colors.red[100]!,
    ),
  ];

  List<Article> getAllArticles() {
    return List.from(_articles);
  }

  List<Article> searchArticles(String query) {
    if (query.isEmpty) {
      return getAllArticles();
    }
    
    final lowercaseQuery = query.toLowerCase();
    return _articles.where((article) {
      return article.title.toLowerCase().contains(lowercaseQuery) ||
             article.category.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  List<Article> fuzzySearchArticles(String query) {
    if (query.isEmpty) {
      return getAllArticles();
    }
    
    final lowercaseQuery = query.toLowerCase();
    final List<MapEntry<Article, int>> scoredArticles = [];
    
    for (final article in _articles) {
      final titleScore = _calculateFuzzyScore(article.title.toLowerCase(), lowercaseQuery);
      final categoryScore = _calculateFuzzyScore(article.category.toLowerCase(), lowercaseQuery);
      final maxScore = titleScore > categoryScore ? titleScore : categoryScore;
      
      if (maxScore > 0) {
        scoredArticles.add(MapEntry(article, maxScore));
      }
    }
    
    // Sort by score (descending)
    scoredArticles.sort((a, b) => b.value.compareTo(a.value));
    
    // Return articles sorted by relevance
    return scoredArticles.map((entry) => entry.key).toList();
  }
  
  int _calculateFuzzyScore(String text, String query) {
    if (text.contains(query)) {
      return 100; // Exact match gets highest score
    }
    
    int score = 0;
    final queryChars = query.split('');
    int lastFoundIndex = -1;
    int sequenceBonus = 0;
    
    for (final char in queryChars) {
      final charIndex = text.indexOf(char, lastFoundIndex + 1);
      
      if (charIndex != -1) {
        score += 10; // Base score for finding the character
        
        // Bonus for characters being close to each other
        if (lastFoundIndex != -1 && charIndex == lastFoundIndex + 1) {
          sequenceBonus += 5;
        }
        
        lastFoundIndex = charIndex;
      } else {
        // Character not found, reduce score
        score -= 5;
      }
    }
    
    return score + sequenceBonus;
  }
} 