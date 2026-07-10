import 'package:flutter/material.dart';

enum ExportFormat {
  resumeBullet,
  linkedInPost,
  twitterPost,
  instagramCaption,
  portfolioSummary,
  weeklyRecap,
}

extension ExportFormatDisplay on ExportFormat {
  String get displayName {
    return switch (this) {
      ExportFormat.resumeBullet => 'Resume bullet',
      ExportFormat.linkedInPost => 'LinkedIn post',
      ExportFormat.twitterPost => 'Twitter/X post',
      ExportFormat.instagramCaption => 'Instagram caption',
      ExportFormat.portfolioSummary => 'Portfolio summary',
      ExportFormat.weeklyRecap => 'Weekly recap',
    };
  }

  String get helperText {
    return switch (this) {
      ExportFormat.resumeBullet => 'A concise achievement line for resumes.',
      ExportFormat.linkedInPost => 'A professional progress update.',
      ExportFormat.twitterPost => 'A short public build-in-public update.',
      ExportFormat.instagramCaption =>
        'A warmer caption for visual progress posts.',
      ExportFormat.portfolioSummary =>
        'A polished summary for portfolio pages.',
      ExportFormat.weeklyRecap => 'A simple weekly proof-of-work recap.',
    };
  }

  IconData get icon {
    return switch (this) {
      ExportFormat.resumeBullet => Icons.description_outlined,
      ExportFormat.linkedInPost => Icons.business_center_outlined,
      ExportFormat.twitterPost => Icons.alternate_email,
      ExportFormat.instagramCaption => Icons.photo_camera_outlined,
      ExportFormat.portfolioSummary => Icons.web_outlined,
      ExportFormat.weeklyRecap => Icons.auto_awesome,
    };
  }
}
