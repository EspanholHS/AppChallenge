// lib/pages/explore_page.dart

import 'package:flutter/material.dart';
import 'package:my_flutter_app/widgets/logout_button.dart';
import '../widgets/background_scaffold.dart';
import '../widgets/animated_logo_image.dart';
import '../services/explore_storage.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class Idea {
  Idea({
    required this.id,
    required this.asset,
    required this.title,
    required this.subtitle,
    required this.description, // <- NOVO
    required this.category,    // <- NOVO
    required this.author,
    required this.points,
    required this.likes,
    List<String>? comments,
    this.isLiked = false,
  }) : comments = comments ?? [];

  final String id;
  final String asset;
  final String title;
  final String subtitle;
  final String description; // <- NOVO
  final String category;    // <- NOVO
  final String author;

  int points;
  int likes;
  bool isLiked;
  final List<String> comments;

  // Persistimos apenas o que muda com a interação do usuário
  Map<String, dynamic> toPersist() => {
        'id': id,
        'likes': likes,
        'points': points,
        'isLiked': isLiked,
        'comments': comments,
      };

  void applyPersist(Map<String, dynamic> m) {
    if (m['likes'] is int) likes = m['likes'] as int;
    if (m['points'] is int) points = m['points'] as int;
    if (m['isLiked'] is bool) isLiked = m['isLiked'] as bool;
    if (m['comments'] is List) {
      comments
        ..clear()
        ..addAll((m['comments'] as List).map((e) => e.toString()));
    }
  }
}

class _ExplorePageState extends State<ExplorePage> {
  late final List<Idea> _ideas;

  @override
  void initState() {
    super.initState();
    // IDEIAS APROVADAS (sementes) — agora com descrição e categoria
    _ideas = [
      Idea(
        id: 'robo1',
        asset: 'assets/images/robo1.png',
        title: 'Assistente Robótico para Atendimentos',
        subtitle: 'Auxiliar colaboradores em tarefas diárias',
        description:
            'Assistente robótico para suporte em atendimentos internos, triagem de dúvidas comuns e integração com sistemas corporativos.',
        category: 'Processos',
        author: 'Carlos Oliveira',
        points: 230,
        likes: 25,
        comments: ['Excelente!', 'Isso economiza tempo.'],
      ),
      Idea(
        id: 'robo2',
        asset: 'assets/images/robo2.png',
        title: 'Laboratório Móvel de Testes',
        subtitle: 'Realizar exames diretamente nas unidades',
        description:
            'Unidade móvel equipada para realização de exames de rotina nas unidades, reduzindo deslocamentos e tempo de espera.',
        category: 'Produtos',
        author: 'Ana Souza',
        points: 180,
        likes: 18,
        comments: ['Muito útil no dia a dia.', 'Top!'],
      ),
      Idea(
        id: 'robo3',
        asset: 'assets/images/robo3.png',
        title: 'Plataforma de Ideias',
        subtitle: 'Enviar e discutir sugestões de inovação',
        description:
            'Portal colaborativo para submissão, discussão e acompanhamento de ideias de inovação por toda a empresa.',
        category: 'Outros',
        author: 'Lucas Pereira',
        points: 150,
        likes: 20,
        comments: ['Engaja a galera!', 'Vai bombar.'],
      ),
      Idea(
        id: 'robo4',
        asset: 'assets/images/robo4.png',
        title: 'Linha de Produção Automatizada',
        subtitle: 'Aumentar a eficiência na fábrica',
        description:
            'Automação de etapas críticas para elevar a eficiência, reduzir erros e ampliar a rastreabilidade do processo.',
        category: 'Sustentabilidade',
        author: 'Mariana Carvalho',
        points: 260,
        likes: 34,
        comments: ['Produtividade vai lá em cima.'],
      ),
    ];

    _loadPersist();
  }

  Future<void> _loadPersist() async {
    final data = await ExploreStorage.load();
    if (!mounted) return;

    final byId = {for (final it in _ideas) it.id: it};
    for (final m in data) {
      final id = m['id']?.toString();
      if (id != null && byId.containsKey(id)) {
        byId[id]!.applyPersist(m);
      }
    }
    setState(() {});
  }

  Future<void> _savePersist() async {
    final list = _ideas.map((e) => e.toPersist()).toList();
    await ExploreStorage.save(list);
  }

  void _onIdeaChanged() {
    setState(() {});
    _savePersist();
  }

  Future<void> _showDetails(Idea idea) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final bottom = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          idea.asset,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          idea.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(idea.category),
                        backgroundColor: Colors.black12,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Descrição',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    idea.description,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onTapNav(BuildContext context, int idx) {
    switch (idx) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/qr');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/points');
        break;
      case 3:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (ModalRoute.of(context)?.settings.name != '/home') {
          Navigator.pushReplacementNamed(context, '/home');
          return false;
        }
        return true;
      },
      child: BackgroundScaffold(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          itemCount: _ideas.length + 2,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, idx) {
            if (idx == 0) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  AnimatedLogoImage(height: 40),
                  Spacer(),
                  LogoutButton(), 
                  SizedBox(width: 8),
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage('assets/images/avatar.png'),
                  ),
                ],
              );
            } else if (idx == 1) {
              return const Text(
                'Explorar Ideias',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              );
            }

            final idea = _ideas[idx - 2];
            return IdeaTile(
              idea: idea,
              onChanged: _onIdeaChanged,
              onOpenDetails: () => _showDetails(idea), // <- NOVO
              pointsPerLike: 5,
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 3,
          onTap: (i) => _onTapNav(context, i),
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
      ),
    );
  }
}

/// Card com like, comentários, pontos e botão de detalhes
class IdeaTile extends StatefulWidget {
  const IdeaTile({
    Key? key,
    required this.idea,
    required this.onChanged,
    required this.onOpenDetails, // <- NOVO
    this.pointsPerLike = 5,
  }) : super(key: key);

  final Idea idea;
  final VoidCallback onChanged;
  final VoidCallback onOpenDetails; // <- NOVO
  final int pointsPerLike;

  @override
  State<IdeaTile> createState() => _IdeaTileState();
}

class _IdeaTileState extends State<IdeaTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _likeCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _likeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _likeCtrl, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _likeCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    setState(() {
      widget.idea.isLiked = !widget.idea.isLiked;
      if (widget.idea.isLiked) {
        widget.idea.likes += 1;
        widget.idea.points += widget.pointsPerLike;
      } else {
        widget.idea.likes = (widget.idea.likes - 1).clamp(0, 1 << 31);
        widget.idea.points =
            (widget.idea.points - widget.pointsPerLike).clamp(0, 1 << 31);
      }
    });

    await _likeCtrl.forward(from: 0);
    await _likeCtrl.reverse();

    widget.onChanged();
  }

  Future<void> _openComments() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CommentsSheet(idea: widget.idea),
    );
    setState(() {});
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final idea = widget.idea;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  idea.asset,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  idea.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // Coluna de pontos
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(height: 4),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, anim) =>
                        FadeTransition(opacity: anim, child: child),
                    child: Text(
                      '${idea.points} pts',
                      key: ValueKey(idea.points),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              // Botão pequeno de detalhes (abre modal com Título/Descrição/Categoria)
              IconButton(
                tooltip: 'Detalhes do projeto',
                onPressed: widget.onOpenDetails,
                icon: const Icon(Icons.info_outline, size: 20),
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints.tightFor(width: 36, height: 36),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              idea.subtitle,
              style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                idea.author,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),

              // Like
              GestureDetector(
                onTap: _toggleLike,
                child: Row(
                  children: [
                    ScaleTransition(
                      scale: _scaleAnim,
                      child: Icon(
                        idea.isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: idea.isLiked ? Colors.red : Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 6),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      transitionBuilder: (c, a) =>
                          FadeTransition(opacity: a, child: c),
                      child: Text(
                        '${idea.likes}',
                        key: ValueKey(idea.likes),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Comentários
              InkWell(
                onTap: _openComments,
                borderRadius: BorderRadius.circular(6),
                child: Row(
                  children: [
                    const Icon(Icons.comment, size: 18, color: Colors.black54),
                    const SizedBox(width: 6),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      transitionBuilder: (c, a) =>
                          FadeTransition(opacity: a, child: c),
                      child: Text(
                        '${idea.comments.length}',
                        key: ValueKey(idea.comments.length),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ---------- BottomSheet de comentários ----------
class _CommentsSheet extends StatefulWidget {
  const _CommentsSheet({Key? key, required this.idea}) : super(key: key);
  final Idea idea;

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _addComment() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      widget.idea.comments.add(text);
    });
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.65,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Comentários',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: widget.idea.comments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final c = widget.idea.comments[i];
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 14,
                          backgroundImage:
                              AssetImage('assets/images/avatar.png'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            c,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      decoration: InputDecoration(
                        hintText: 'Escreva um comentário...',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _addComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    heroTag: null,
                    mini: true,
                    backgroundColor: const Color(0xFF1877F2),
                    onPressed: _addComment,
                    child: const Icon(Icons.send, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
