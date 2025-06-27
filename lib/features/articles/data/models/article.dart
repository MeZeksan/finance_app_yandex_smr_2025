import 'package:flutter/material.dart';

class Article {
  final String id;
  final String title;
  final String category;
  final String emoji;
  final Color iconBackground;

  const Article({
    required this.id,
    required this.title,
    required this.category,
    required this.emoji,
    required this.iconBackground,
  });
} 