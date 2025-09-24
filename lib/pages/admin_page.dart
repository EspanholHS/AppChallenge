// lib/pages/admin_page.dart
import 'package:flutter/material.dart';
import 'package:my_flutter_app/widgets/logout_button.dart';
import '../widgets/background_scaffold.dart';
import '../widgets/animated_logo_image.dart';

enum ProjectStatus { emAnalise, reprovado, aprovado }

class Project {
  Project({
    required this.asset,
    required this.title,
    required this.subtitle,
    required this.description, 
    required this.category,    
    required this.author,
    required this.points,
    required this.likes,
    required this.status,
  });

  final String asset;
  final String title;
  final String subtitle;
  final String description; 
  final String category;    
  final String author;
  final int points;
  final int likes;
  final ProjectStatus status;
}

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _searchCtrl = TextEditingController();
  ProjectStatus? _selectedStatus; 

  late final List<Project> _all;

  @override
  void initState() {
    super.initState();

    // ---- APROVADOS (iguais à ExplorePage + descricao/categoria) ----
    final approved = <Project>[
      Project(
        asset: 'assets/images/robo1.png',
        title: 'Assistente Robótico para Atendimentos',
        subtitle: 'Auxiliar colaboradores em tarefas diárias',
        description:
            'Assistente robótico para suporte em atendimentos internos, triagem de dúvidas e integração com sistemas corporativos.',
        category: 'Processos',
        author: 'Carlos Oliveira',
        points: 230,
        likes: 25,
        status: ProjectStatus.aprovado,
      ),
      Project(
        asset: 'assets/images/robo2.png',
        title: 'Laboratório Móvel de Testes',
        subtitle: 'Realizar exames diretamente nas unidades',
        description:
            'Unidade móvel equipada para realização de exames de rotina nas unidades, reduzindo deslocamentos e tempo de espera.',
        category: 'Produtos',
        author: 'Ana Souza',
        points: 180,
        likes: 18,
        status: ProjectStatus.aprovado,
      ),
      Project(
        asset: 'assets/images/robo3.png',
        title: 'Plataforma de Ideias',
        subtitle: 'Enviar e discutir sugestões de inovação',
        description:
            'Portal colaborativo para submissão, discussão e acompanhamento de ideias de inovação por toda a empresa.',
        category: 'Outros',
        author: 'Lucas Pereira',
        points: 150,
        likes: 20,
        status: ProjectStatus.aprovado,
      ),
      Project(
        asset: 'assets/images/robo4.png',
        title: 'Linha de Produção Automatizada',
        subtitle: 'Aumentar a eficiência na fábrica',
        description:
            'Automação de etapas críticas para elevar a eficiência, reduzir erros e ampliar a rastreabilidade do processo.',
        category: 'Sustentabilidade',
        author: 'Mariana Carvalho',
        points: 260,
        likes: 34,
        status: ProjectStatus.aprovado,
      ),
    ];

    // ---- EM ANÁLISE ----
    final inAnalysis = <Project>[
      Project(
        asset: 'assets/images/robo2.png',
        title: 'Roteirização Inteligente de Entregas',
        subtitle: 'Otimizar rotas e reduzir custo logístico',
        description:
            'Algoritmo de roteirização para priorizar entregas, diminuir tempo ocioso e melhorar ocupação de frota.',
        category: 'Processos',
        author: 'Bruno Lima',
        points: 95,
        likes: 9,
        status: ProjectStatus.emAnalise,
      ),
      Project(
        asset: 'assets/images/robo3.png',
        title: 'Portal de Onboarding',
        subtitle: 'Acelerar a integração de novos colaboradores',
        description:
            'Portal unificado com trilhas, checklist e tutoriais para padronizar e acelerar onboarding.',
        category: 'Outros',
        author: 'Juliana Nunes',
        points: 120,
        likes: 13,
        status: ProjectStatus.emAnalise,
      ),
    ];

    // ---- REPROVADOS ----
    final rejected = <Project>[
      Project(
        asset: 'assets/images/robo1.png',
        title: 'Game Interno de Metas',
        subtitle: 'Gamificar metas trimestrais do time',
        description:
            'Sistema de gamificação para metas e recompensas trimestrais em squads de vendas.',
        category: 'Outros',
        author: 'Rafael Martins',
        points: 40,
        likes: 5,
        status: ProjectStatus.reprovado,
      ),
      Project(
        asset: 'assets/images/robo4.png',
        title: 'Robô de Impressões 3D',
        subtitle: 'Prototipagem rápida para todos os setores',
        description:
            'Estação robótica para impressão 3D sob demanda de protótipos internos.',
        category: 'Produtos',
        author: 'Paula Ribeiro',
        points: 30,
        likes: 3,
        status: ProjectStatus.reprovado,
      ),
    ];

    _all = [...approved, ...inAnalysis, ...rejected];

    // Ordena: Aprovados > Em análise > Reprovados; e por pontos desc
    _all.sort((a, b) {
      int statusOrder(ProjectStatus s) {
        switch (s) {
          case ProjectStatus.aprovado:
            return 0;
          case ProjectStatus.emAnalise:
            return 1;
          case ProjectStatus.reprovado:
            return 2;
        }
      }

      final c1 = statusOrder(a.status).compareTo(statusOrder(b.status));
      if (c1 != 0) return c1;
      return b.points.compareTo(a.points);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _statusLabel(ProjectStatus s) {
    switch (s) {
      case ProjectStatus.emAnalise:
        return 'Em análise';
      case ProjectStatus.reprovado:
        return 'Reprovados';
      case ProjectStatus.aprovado:
        return 'Aprovados';
    }
  }

  List<Project> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    return _all.where((p) {
      final statusOk = _selectedStatus == null || p.status == _selectedStatus;
      final textOk = q.isEmpty ||
          p.title.toLowerCase().contains(q) ||
          p.subtitle.toLowerCase().contains(q) ||
          p.author.toLowerCase().contains(q);
      return statusOk && textOk;
    }).toList();
  }

  Future<void> _showDetails(Project p) async {
    // usado apenas para Aprovados
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
                          p.asset,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          p.title,
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
                        label: Text(p.category),
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
                    p.description,
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

  @override
  Widget build(BuildContext context) {
    final results = _filtered;

    return BackgroundScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          // Cabeçalho
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              AnimatedLogoImage(height: 42),
              Spacer(),
              LogoutButton(), // <- novo botão
              SizedBox(width: 8),
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('assets/images/avatar.png'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const Text(
            'Admin • Projetos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Visualize, pesquise e filtre todos os projetos enviados.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 18),

          _SearchField(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),

          // Filtros de status
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusChip(
                label: 'Todos',
                selected: _selectedStatus == null,
                onTap: () => setState(() => _selectedStatus = null),
              ),
              for (final s in ProjectStatus.values)
                _StatusChip(
                  label: _statusLabel(s),
                  selected: _selectedStatus == s,
                  onTap: () => setState(() => _selectedStatus = s),
                ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Text(
                '${results.length} projeto(s)',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const Spacer(),
              const Text(
                'Ordenado por status e pontos',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...results.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ProjectCard(
                  project: p,
                  statusLabel: _statusLabel(p.status),
                  onOpenDetails: p.status == ProjectStatus.aprovado
                      ? () => _showDetails(p)
                      : null, // apenas aprovados
                ),
              )),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    Key? key,
    required this.controller,
    required this.onChanged,
  }) : super(key: key);

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Buscar por título, autor ou descrição…',
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.search, color: Colors.white70),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      textInputAction: TextInputAction.search,
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    Key? key,
    required this.label,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      selectedColor: const Color(0xFF1877F2),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    Key? key,
    required this.project,
    required this.statusLabel,
    this.onOpenDetails, // só para aprovados
  }) : super(key: key);

  final Project project;
  final String statusLabel;
  final VoidCallback? onOpenDetails;

  Color _statusColor() {
    switch (project.status) {
      case ProjectStatus.aprovado:
        return const Color(0xFF1ABC9C);
      case ProjectStatus.emAnalise:
        return const Color(0xFFFFB400);
      case ProjectStatus.reprovado:
        return const Color(0xFFE74C3C);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showMetrics = project.status == ProjectStatus.aprovado;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.96),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(project.asset, width: 64, height: 64, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // título + status pill + (detalhes quando aprovado)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        project.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor().withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: _statusColor().withOpacity(.95),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (onOpenDetails != null) ...[
                      const SizedBox(width: 4),
                      // Botão pequeno de detalhes (NÃO altera cor do ícone)
                      IconButton(
                        tooltip: 'Detalhes do projeto',
                        onPressed: onOpenDetails,
                        icon: const Icon(Icons.info_outline, size: 20),
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints.tightFor(width: 36, height: 36),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(project.subtitle, style: const TextStyle(color: Color(0xFF666666))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.black38),
                    const SizedBox(width: 6),
                    Text(project.author, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    if (showMetrics) const Icon(Icons.star, size: 18, color: Colors.amber),
                    if (showMetrics) ...[
                      const SizedBox(width: 4),
                      Text('${project.points} pts',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(width: 12),
                      const Icon(Icons.favorite, size: 18, color: Colors.redAccent),
                      const SizedBox(width: 4),
                      Text('${project.likes}',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
