import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

enum GamePlayType { multiplayer, singlePlayer, vsAi }
enum GameModeType { mathRush, patternFinder, memoryFlash, logicGrid, wordRush }
enum AiDifficulty { easy, medium, hard }

extension GamePlayTypeExtension on GamePlayType {
  String get title {
    switch (this) {
      case GamePlayType.multiplayer: return 'MULTIPLAYER';
      case GamePlayType.singlePlayer: return 'SINGLE PLAYER';
      case GamePlayType.vsAi: return 'VS AI';
    }
  }

  String get subtitle {
    switch (this) {
      case GamePlayType.multiplayer: return 'Challenge a real player';
      case GamePlayType.singlePlayer: return 'Practice at your own pace';
      case GamePlayType.vsAi: return 'Challenge the computer';
    }
  }

  String get description {
    switch (this) {
      case GamePlayType.multiplayer: return 'Compete against another player in a real-time online battle.';
      case GamePlayType.singlePlayer: return 'Play offline and improve your skills without an opponent.';
      case GamePlayType.vsAi: return 'Battle an intelligent offline opponent with different difficulty levels.';
    }
  }

  IconData get icon {
    switch (this) {
      case GamePlayType.multiplayer: return Icons.people_alt_rounded;
      case GamePlayType.singlePlayer: return Icons.person_rounded;
      case GamePlayType.vsAi: return Icons.smart_toy_rounded;
    }
  }

  Color get accentColor {
    switch (this) {
      case GamePlayType.multiplayer: return AppColors.yellow;
      case GamePlayType.singlePlayer: return AppColors.purple;
      case GamePlayType.vsAi: return AppColors.cyan;
    }
  }
}

extension GameModeTypeExtension on GameModeType {
  String get name {
    switch (this) {
      case GameModeType.mathRush: return 'Math Rush';
      case GameModeType.patternFinder: return 'Pattern Finder';
      case GameModeType.memoryFlash: return 'Memory Flash';
      case GameModeType.logicGrid: return 'Logic Grid';
      case GameModeType.wordRush: return 'Word Rush';
    }
  }

  String get description {
    switch (this) {
      case GameModeType.mathRush: return 'Solve fast arithmetic calculations (+, -, ×, ÷).';
      case GameModeType.patternFinder: return 'Detect mathematical sequences and missing patterns.';
      case GameModeType.memoryFlash: return 'Memorize flashing symbols and recall their sequence.';
      case GameModeType.logicGrid: return 'Deductive reasoning and logical puzzle solving.';
      case GameModeType.wordRush: return 'Unscramble words, check spelling and word relations.';
    }
  }

  IconData get icon {
    switch (this) {
      case GameModeType.mathRush: return Icons.calculate_rounded;
      case GameModeType.patternFinder: return Icons.auto_graph_rounded;
      case GameModeType.memoryFlash: return Icons.psychology_alt_rounded;
      case GameModeType.logicGrid: return Icons.grid_4x4_rounded;
      case GameModeType.wordRush: return Icons.text_fields_rounded;
    }
  }

  Color get accentColor {
    switch (this) {
      case GameModeType.mathRush: return AppColors.purple;
      case GameModeType.patternFinder: return AppColors.cyan;
      case GameModeType.memoryFlash: return AppColors.yellow;
      case GameModeType.logicGrid: return AppColors.green;
      case GameModeType.wordRush: return AppColors.red;
    }
  }
}

extension AiDifficultyExtension on AiDifficulty {
  String get label {
    switch (this) {
      case AiDifficulty.easy: return 'Easy';
      case AiDifficulty.medium: return 'Medium';
      case AiDifficulty.hard: return 'Hard';
    }
  }

  String get accuracyLabel {
    switch (this) {
      case AiDifficulty.easy: return '70–80% Accuracy';
      case AiDifficulty.medium: return '80–90% Accuracy';
      case AiDifficulty.hard: return '90–97% Accuracy';
    }
  }

  String get speedLabel {
    switch (this) {
      case AiDifficulty.easy: return 'Slower Response';
      case AiDifficulty.medium: return 'Moderate Response';
      case AiDifficulty.hard: return 'Fast Response';
    }
  }

  Color get color {
    switch (this) {
      case AiDifficulty.easy: return AppColors.green;
      case AiDifficulty.medium: return AppColors.yellow;
      case AiDifficulty.hard: return AppColors.red;
    }
  }
}
