import 'package:flutter/material.dart';

class UserProfile {
  final String name;
  final String tier;
  final String imageUrl;
  final int availablePoints;
  final int pointsToNextTier;
  final String nextTierName;

  UserProfile({
    required this.name,
    required this.tier,
    required this.imageUrl,
    required this.availablePoints,
    required this.pointsToNextTier,
    required this.nextTierName,
  });
}

class RewardOption {
  final String title;
  final int points;
  final IconData icon;

  RewardOption({
    required this.title,
    required this.points,
    required this.icon,
  });
}