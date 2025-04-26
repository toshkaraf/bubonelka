import 'package:flutter/material.dart';
import 'package:bubonelka/rutes.dart';
import 'package:bubonelka/pages/edit_phrasecard_page.dart';
import 'package:bubonelka/const_parameters.dart';
import 'package:bubonelka/classes/settings_and_state.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bubonelka'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // показать справку
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ИЛЛЮСТРАЦИЯ
          Container(
            height: 180,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/illustrations/header_image.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // СЕТКА КНОПОК
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  _MenuIconButton(
                    icon: Icons.fiber_new,
                    label: 'Новые темы',
                    heroTag: 'hero_new',
                    destination: chooseThemePageRoute,
                  ),
                  _MenuIconButton(
                    icon: Icons.star,
                    label: 'Избранное',
                    heroTag: 'hero_fav',
                    destination: favoritePhrasesPage,
                  ),
                  _MenuIconButton(
                    icon: Icons.replay,
                    label: 'Повторение',
                    heroTag: 'hero_repeat',
                    destination: chooseThemePageRoute,
                  ),
                  _MenuIconButton(
                    icon: Icons.settings,
                    label: 'Настройки',
                    heroTag: 'hero_settings',
                    destination: themeListPageRoute,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => EditPhraseCardPage(
          //       widgetName: createPhrasePageName,
          //       phraseCard: neutralPhraseCard,
          //       themeNameTranslation: SettingsAndState.getInstance().currentThemeName,
          //     ),
          //   ),
          // );
        },
        tooltip: 'Добавить фразу',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MenuIconButton extends StatefulWidget {
  final String heroTag;
  final IconData icon;
  final String label;
  final String destination;

  const _MenuIconButton({
    required this.heroTag,
    required this.icon,
    required this.label,
    required this.destination,
  });

  @override
  State<_MenuIconButton> createState() => _MenuIconButtonState();
}

class _MenuIconButtonState extends State<_MenuIconButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => Scaffold(
              appBar: AppBar(title: Text(widget.label)),
              body: Hero(
                tag: widget.heroTag,
                child: Center(
                  child: Text('Здесь будет страница: ${widget.label}', style: const TextStyle(fontSize: 24)),
                ),
              ),
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Material(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Hero(
              tag: widget.heroTag,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    size: 48,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.label,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
