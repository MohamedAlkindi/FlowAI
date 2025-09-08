import 'package:flow_ai/screens/welcome_screen/widgets/buttom_section.dart';
import 'package:flow_ai/screens/welcome_screen/widgets/page_widget.dart';
import 'package:flow_ai/screens/welcome_screen/widgets/language_selection.dart';
import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final pages = [
      {'custom': 'language', 'title': '', 'subtitle': '', 'icon': ''},
      {
        'title': t.t('welcome_title_1'),
        'subtitle': t.t('welcome_sub_1'),
        'icon': '✨️',
      },
      {
        'title': t.t('welcome_title_2'),
        'subtitle': t.t('welcome_sub_2'),
        'icon': '🪄',
      },
      {
        'title': t.t('welcome_title_3'),
        'subtitle': t.t('welcome_sub_3'),
        'icon': '⚡',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  final page = pages[index];
                  if (page['custom'] == 'language') {
                    return const LanguageSelection();
                  }
                  return buildPage(page: page);
                },
              ),
            ),
            buildBottomSection(
              t: t,
              length: pages.length,
              currentPage: _currentPage,
              pageController: _pageController,
              context: context,
            ),
          ],
        ),
      ),
    );
  }
}
