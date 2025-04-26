import 'package:flutter/material.dart';
import 'dart:io';

// Start & Main Menu
import 'screens/start_menu/start_menu_screen.dart';
import 'screens/main_menu/main_menu_screen.dart';

// Exam Flow
import 'screens/exam/exam_menu_screen.dart';
import 'screens/exam/countdown_screen.dart';
import 'screens/exam/evaluation_screen.dart';
import 'screens/exam/exam_summary_screen.dart';

// Learn Section
import 'screens/learn/learn_menu_screen.dart';
import 'screens/learn/technique_filter_screen.dart';
import 'screens/learn/technique_list_screen.dart';
import 'screens/learn/vocabulary_screen.dart';

// Progression Section
import 'screens/progression/progression_list_screen.dart';
import 'screens/progression/progression_detail_screen.dart';

// Config
import 'screens/config/config_screen.dart';

// More Info Section
import 'screens/info/more_infos_screen.dart';

class AppRoutes {
  static const start = '/';
  static const mainMenu = '/main-menu';

  // Exam
  static const examMenu = '/exam/menu';
  static const countdown = '/exam/countdown';
  static const evaluation = '/exam/evaluation';
  static const examSummary = '/exam/summary';

  // learn
  static const learnMenu = '/learn/menu';
  static const techniqueFilter = '/learn/technique-filter';
  static const techniqueList = '/learn/technique-list';
  static const vocabulary = '/learn/vocabulary';

  // Progression
  static const progressionList = '/progression/list';
  static const progressionDetail = '/progression/detail';

  // Config
  static const config = '/config';

  // More Infos
  static const moreInfos = '/info';
}

final Map<String, WidgetBuilder> appRoutes = {
  AppRoutes.start: (context) => const StartMenuScreen(),
  AppRoutes.mainMenu: (context) => const MainMenuScreen(),

  // Exam
  AppRoutes.examMenu: (context) => const ExamMenuScreen(),
  AppRoutes.countdown: (context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args == null) {
      return const Center(child: Text("Error: No arguments passed!"));
    }
    final examFile = args['examFile'] as File?;
    if (examFile == null || !examFile.existsSync()) {
      return const Center(child: Text("Error: Invalid exam file!"));
    }
    return CountdownScreen(
      examFile: examFile,
    );
  },
  AppRoutes.evaluation: (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final examFile = args['examFile'] as File? ?? File('');
    final index = args['index'] as int? ?? 0;
    return EvaluationScreen(
      examFile: examFile,
      index: index,
    );
  },
  AppRoutes.examSummary: (context) => const ExamSummaryScreen(),

  // Learn
  AppRoutes.learnMenu: (context) => const LearnMenuScreen(),
  AppRoutes.techniqueFilter: (context) => const TechniqueFilterScreen(),
  AppRoutes.techniqueList: (context) => const TechniqueListScreen(),
  AppRoutes.vocabulary: (context) => const VocabularyScreen(),

  // Progression
  AppRoutes.progressionList: (context) => const ProgressionListScreen(),
  AppRoutes.progressionDetail: (context) => const ProgressionDetailScreen(),

  // Config
  AppRoutes.config: (context) => const ConfigScreen(),

  // More Infos
  AppRoutes.moreInfos: (context) => const MoreInfoScreen(),
};
