import 'package:flutter/material.dart';
import 'package:bubonelka/rutes.dart';
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
              // TODO: Показать справку
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.25,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/illustrations/header_image.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1.2,
                children: [
                  _AnimatedMenuButton(
                    icon: Icons.menu_book,
                    label: 'Новые темы',
                    destination: chooseThemePageRoute,
                  ),
                  _AnimatedMenuButton(
                    icon: Icons.star,
                    label: 'Избранное',
                    destination: favoritePhrasesPage,
                  ),
                  _AnimatedMenuButton(
                    icon: Icons.replay,
                    label: 'Повторение',
                    destination: repeatRecommendedPage,
                  ),
                  _AnimatedMenuButton(
                    icon: Icons.add_circle_outline,
                    label: 'Добавить фразу',
                    destination: themeListPageRoute,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedMenuButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final String destination;
  final VoidCallback? onTapOverride;

  const _AnimatedMenuButton({
    required this.icon,
    required this.label,
    required this.destination,
    this.onTapOverride,
  });

  @override
  State<_AnimatedMenuButton> createState() => _AnimatedMenuButtonState();
}

class _AnimatedMenuButtonState extends State<_AnimatedMenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();

        if (widget.onTapOverride != null) {
          widget.onTapOverride!();
        } else {
          Navigator.pushNamed(context, widget.destination);
        }
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Material(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
          elevation: 4,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              splashColor: Colors.blue.withOpacity(0.3),
              highlightColor: Colors.blue.withOpacity(0.1),
              child: Center(
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
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
