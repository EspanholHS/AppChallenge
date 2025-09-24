// lib/pages/points_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:my_flutter_app/widgets/logout_button.dart';

import '../widgets/background_scaffold.dart';
import '../widgets/animated_logo_image.dart';
import '../widgets/touch_animated_button.dart';
import '../services/points_storage.dart';

class PointsPage extends StatefulWidget {
  const PointsPage({Key? key}) : super(key: key);

  @override
  State<PointsPage> createState() => _PointsPageState();
}

class RewardTier {
  RewardTier({
    required this.name,
    required this.cost,
    required this.description,
    required this.icon,
    this.claimed = false,
  });

  final String name;
  final int cost;
  final String description;
  final IconData icon;
  bool claimed;
}

class _PointsPageState extends State<PointsPage> {
  int currentPoints = 0;
  late final List<RewardTier> rewards;

  @override
  void initState() {
    super.initState();
    rewards = [
      RewardTier(
        name: 'Brinde Inova+',
        cost: 100,
        description: 'Caneca ou camiseta exclusiva da Inova+.',
        icon: Icons.local_cafe_outlined,
      ),
      RewardTier(
        name: 'Vale-presente',
        cost: 300,
        description: 'Vale de R\$50 para você usar como quiser.',
        icon: Icons.card_giftcard,
      ),
      RewardTier(
        name: 'Kit Eurofarma / Livro',
        cost: 600,
        description: 'Kit especial Eurofarma ou um livro à sua escolha.',
        icon: Icons.science_outlined,
      ),
      RewardTier(
        name: 'Prêmio Premium',
        cost: 1000,
        description: 'Evento exclusivo, almoço com liderança ou 1 dia de folga.',
        icon: Icons.emoji_events_outlined,
      ),
    ];
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    final value = await PointsStorage.getPoints();
    if (!mounted) return;
    setState(() => currentPoints = value);
  }

  void _onTapNav(int idx) {
    switch (idx) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/qr');
        break;
      case 2:
        // já estamos aqui
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/explore');
        break;
    }
  }

  int? _nextTierCost() {
    for (final r in rewards) {
      if (currentPoints < r.cost) return r.cost;
    }
    return null;
  }

  double _progressToNextTier() {
    final next = _nextTierCost();
    if (next == null) return 1.0;
    final prev = rewards
        .where((r) => r.cost <= currentPoints)
        .fold<int>(0, (acc, r) => r.cost > acc ? r.cost : acc);
    final span = (next - prev).clamp(1, 1 << 31);
    final progressed = (currentPoints - prev).clamp(0, span);
    return progressed / span;
  }

  Future<void> _confirmClaim(RewardTier tier) async {
    final canClaim = currentPoints >= tier.cost && !tier.claimed;
    if (!canClaim) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Icon(tier.icon, size: 48, color: const Color(0xFF1877F2)),
              const SizedBox(height: 12),
              Text(
                'Resgatar "${tier.name}"?',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Custo: ${tier.cost} pontos',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              TouchAnimatedButton(
                label: 'CONFIRMAR RESGATE',
                onPressed: () async {
                  Navigator.pop(ctx);
                  setState(() {
                    currentPoints = max(0, currentPoints - tier.cost);
                    tier.claimed = true;
                  });
                  await PointsStorage.setPoints(currentPoints);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Você resgatou: ${tier.name}!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextTierCost();

    return BackgroundScaffold(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              AnimatedLogoImage(height: 48),
              Spacer(),
              LogoutButton(),
              SizedBox(width: 8),
              CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage('assets/images/avatar.png'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          const Text(
            'Pontuação',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Aqui você vê seus pontos acumulados.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),

          _PointsCounterCard(points: currentPoints),
          const SizedBox(height: 16),

          if (next != null)
            _ProgressToNextTier(
              current: currentPoints,
              nextCost: next,
              progress: _progressToNextTier(),
            )
          else
            const _AllTiersCompletedCard(),

          const SizedBox(height: 24),

          const Text(
            'Recompensas disponíveis',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ...rewards.map((tier) {
            final eligible = currentPoints >= tier.cost && !tier.claimed;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RewardCard(
                tier: tier,
                eligible: eligible,
                onClaim: () => _confirmClaim(tier),
              ),
            );
          }).toList(),

          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: _onTapNav,
        backgroundColor: Colors.white.withOpacity(0.9),
        selectedItemColor: const Color(0xFF1877F2),
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb_outline), label: 'Ideias'),
          BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner), label: 'QR code'),
          BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined), label: 'Pontuação'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: 'Explorar'),
        ],
      ),
    );
  }
}

/// -------------------------- Widgets auxiliares -----------------------------

class _PointsCounterCard extends StatelessWidget {
  const _PointsCounterCard({required this.points, Key? key}) : super(key: key);
  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _glass(),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB400),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.stars, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Seus pontos',
                    style: TextStyle(
                        color: Colors.black54, fontWeight: FontWeight.w600)),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: points.toDouble()),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black26),
        ],
      ),
    );
  }
}

class _ProgressToNextTier extends StatelessWidget {
  const _ProgressToNextTier({
    Key? key,
    required this.current,
    required this.nextCost,
    required this.progress,
  }) : super(key: key);

  final int current;
  final int nextCost;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final remaining = (nextCost - current).clamp(0, 1 << 31);

    return Container(
      decoration: _glass(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Próxima recompensa',
              style:
                  TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0, 1),
                    minHeight: 10,
                    backgroundColor: Colors.black12,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF4DB6FF),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('$current/$nextCost'),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            remaining == 0
                ? 'Pronto para resgatar!'
                : 'Faltam $remaining pontos',
            style: TextStyle(
              color:
                  remaining == 0 ? const Color(0xFF1877F2) : Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AllTiersCompletedCard extends StatelessWidget {
  const _AllTiersCompletedCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _glass(),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: const [
          Icon(Icons.emoji_events, color: Color(0xFF1877F2)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Você já alcançou todas as faixas! Continue acumulando para próximos eventos especiais.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardCard extends StatefulWidget {
  const _RewardCard({
    Key? key,
    required this.tier,
    required this.eligible,
    required this.onClaim,
  }) : super(key: key);

  final RewardTier tier;
  final bool eligible;
  final VoidCallback onClaim;

  @override
  State<_RewardCard> createState() => _RewardCardState();
}

class _RewardCardState extends State<_RewardCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tier = widget.tier;

    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (context, child) {
        final t = _glowCtrl.value;
        final glow = widget.eligible ? (2 + sin(t * pi) * 4) : 2.0;
        final color =
            widget.eligible ? const Color(0xFF4DB6FF) : Colors.black12;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color:
                    widget.eligible ? color.withOpacity(0.35) : Colors.black12,
                blurRadius: glow * 2,
                spreadRadius: widget.eligible ? 1.5 : 0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1877F2).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(tier.icon, color: const Color(0xFF1877F2)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tier.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      tier.description,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 6),
                    Text('${tier.cost} pontos',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (tier.claimed)
                _ClaimedBadge()
              else
                SizedBox(
                  width: 140,
                  child: TouchAnimatedButton(
                    label: widget.eligible ? 'RESGATAR' : 'INDISPONÍVEL',
                    onPressed: widget.eligible ? widget.onClaim : () {},
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ClaimedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1ABC9C),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: const [
          Icon(Icons.check_circle, color: Colors.white, size: 18),
          SizedBox(width: 6),
          Text('Resgatado',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

BoxDecoration _glass() {
  return BoxDecoration(
    color: Colors.white.withOpacity(0.92),
    borderRadius: BorderRadius.circular(16),
    boxShadow: const [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  );
}
