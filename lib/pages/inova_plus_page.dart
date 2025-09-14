// lib/pages/inova_plus_page.dart

import 'package:flutter/material.dart';
import '../widgets/background_scaffold.dart';
import '../widgets/animated_logo_image.dart';
import '../widgets/touch_animated_button.dart';
import '../services/points_storage.dart';


class InovaPlusPage extends StatefulWidget {
  const InovaPlusPage({Key? key}) : super(key: key);

  @override
  State<InovaPlusPage> createState() => _InovaPlusPageState();
}

class _InovaPlusPageState extends State<InovaPlusPage> {
  /// Lista “Minhas ideias”. Em produção isso viria do backend.
  final List<Map<String, dynamic>> _myIdeas = [
    {
      'title': 'Aplicativo para treinamentos',
      'status': 'Em análise',
      'date': DateTime(2023, 10, 12),
    },
  ];

  void _onTapNav(BuildContext context, int idx) {
    switch (idx) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/home');
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/qr');
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/points');
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed('/explore');
        break;
    }
  }

  /// Abre a página de submissão, aguarda o retorno e insere a ideia na lista.
  Future<void> _openSubmit() async {
    final result =
        await Navigator.pushNamed(context, '/submit') as Map<String, dynamic>?;

    if (result != null) {
      setState(() {
        _myIdeas.insert(0, {
          'title': (result['title'] as String?) ?? 'Sem título',
          'status': (result['status'] as String?) ?? 'Em análise',
          'date': (result['date'] is DateTime)
              ? result['date'] as DateTime
              : DateTime.now(),
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Header(),
                const SizedBox(height: 32),

                /// Botão que abre a tela de submit e A-G-U-A-R-D-A o retorno
                TouchAnimatedButton(
                  label: 'SUBMETER IDEIA',
                  onPressed: _openSubmit,
                ),

                const SizedBox(height: 40),
                const _SectionTitle('Minhas ideias'),
                const SizedBox(height: 12),

                // Lista dinâmica das suas ideias
                for (final idea in _myIdeas) ...[
                  IdeaCard(
                    title: (idea['title'] as String?) ?? 'Sem título',
                    status: (idea['status'] as String?) ?? 'Em análise',
                    date: (idea['date'] as DateTime?) ?? DateTime.now(),
                  ),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 16),
                const _SectionTitle('Pontos'),
                const SizedBox(height: 12),
                const PointsCard(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Aba “Ideias”
        onTap: (idx) => _onTapNav(context, idx),
        backgroundColor: Colors.white.withOpacity(0.9),
        selectedItemColor: const Color(0xFF1877F2),
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb_outline), label: 'Ideias'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'QR code'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events_outlined), label: 'Pontuação'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Explorar'),
        ],
      ),
    );
  }
}

/// ----------------------------------------------------------------------------
/// Header com logo animado + avatar
/// ----------------------------------------------------------------------------
class _Header extends StatelessWidget {
  const _Header({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        AnimatedLogoImage(height: 40),
        CircleAvatar(radius: 24, backgroundImage: AssetImage('assets/images/avatar.png')),
      ],
    );
  }
}

/// --------------------------------------------------------------------------
/// Título de seção
/// --------------------------------------------------------------------------
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}

/// --------------------------------------------------------------------------
/// Card de ideia (hover/scale) — dados dinâmicos
/// --------------------------------------------------------------------------
class IdeaCard extends StatefulWidget {
  final String title;
  final String status;
  final DateTime date;

  const IdeaCard({
    Key? key,
    required this.title,
    required this.status,
    required this.date,
  }) : super(key: key);

  @override
  _IdeaCardState createState() => _IdeaCardState();
}

class _IdeaCardState extends State<IdeaCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final dateStr =
        MaterialLocalizations.of(context).formatFullDate(widget.date);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        width: double.infinity,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(_hovering ? 1.02 : 1.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: _hovering ? 12 : 4,
              offset: Offset(0, _hovering ? 6 : 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(widget.status,
                style: const TextStyle(fontSize: 14, color: Color(0xFF666666))),
            const SizedBox(height: 4),
            Text(dateStr,
                style: const TextStyle(fontSize: 14, color: Color(0xFF666666))),
          ],
        ),
      ),
    );
  }
}

/// --------------------------------------------------------------------------
/// Card de pontos — agora navega para /points
/// --------------------------------------------------------------------------


class PointsCard extends StatefulWidget {
  const PointsCard({Key? key}) : super(key: key);
  @override
  _PointsCardState createState() => _PointsCardState();
}

class _PointsCardState extends State<PointsCard> {
  bool _hovering = false;
  int _points = 0;

  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    final value = await PointsStorage.getPoints();
    if (!mounted) return;
    setState(() => _points = value);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        width: double.infinity,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(_hovering ? 1.02 : 1.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: _hovering ? 12 : 4,
              offset: Offset(0, _hovering ? 6 : 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$_points',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/points');
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1877F2),
              ),
              child: const Text(
                'resgatar recompensas',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

