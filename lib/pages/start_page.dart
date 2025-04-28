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
              // Иллюстрация с тенью
              Container(
                height: MediaQuery.of(context).size.height * 0.25, // 25% высоты экрана
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/illustrations/header_image.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              // Небольшой разделитель, если нужен
              const SizedBox(height: 16),
              
              // Сетка кнопок
              GridView.count(
                shrinkWrap: true, // Чтобы сетка сжималась до размера содержимого
                physics: const NeverScrollableScrollPhysics(), // Отключаем скролл для сетки
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1.2, // Регулирует соотношение сторон ячеек
                children: [
                  _AnimatedMenuButton(
                    icon: Icons.menu_book, // Иконка книги вместо fiber_new
                    label: 'Новые темы',
                    heroTag: 'hero_new',
                    destination: chooseThemePageRoute,
                  ),
                  _AnimatedMenuButton(
                    icon: Icons.star,
                    label: 'Избранное',
                    heroTag: 'hero_fav',
                    destination: favoritePhrasesPage,
                  ),
                  _AnimatedMenuButton(
                    icon: Icons.replay,
                    label: 'Повторение',
                    heroTag: 'hero_repeat',
                    destination: chooseThemePageRoute,
                  ),
                  _AnimatedMenuButton(
                    icon: Icons.add_circle_outline, // Иконка добавления
                    label: 'Добавить фразу', // Изменено с "Настройки"
                    heroTag: 'hero_add',
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

// Переименованный класс с анимацией нажатия
class _AnimatedMenuButton extends StatefulWidget {
  final String heroTag;
  final IconData icon;
  final String label;
  final String destination;

  const _AnimatedMenuButton({
    required this.heroTag,
    required this.icon,
    required this.label,
    required this.destination,
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
        Navigator.pushNamed(context, widget.destination);
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
      ),
    );
  }
}