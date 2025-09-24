// lib/pages/admin_dashboard_page.dart

import 'package:flutter/material.dart';
import '../widgets/background_scaffold.dart';
import '../widgets/animated_logo_image.dart';
import '../widgets/touch_animated_button.dart';

enum ProjectStatus { aprovado, reprovado, emAnalise }

class AdminProject {
  AdminProject({
    required this.title,
    required this.author,
    required this.points,
    required this.likes,
    required this.createdAt,
    required this.status,
  });

  String title;
  String author;
  int points;
  int likes;
  DateTime createdAt;
  ProjectStatus status;
}

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  // Reproduzidos dos APROVADOS em lib/pages/explore_page.dart
  // (títulos e autores iguais aos cards aprovados)
  final List<AdminProject> _projects = [
    AdminProject(
      title: 'Assistente Robótico para Atendimentos',
      author: 'Carlos Oliveira',
      points: 230,
      likes: 25,
      createdAt: DateTime(2024, 6, 5),
      status: ProjectStatus.aprovado,
    ),
    AdminProject(
      title: 'Laboratório Móvel de Testes',
      author: 'Ana Souza',
      points: 180,
      likes: 18,
      createdAt: DateTime(2024, 8, 11),
      status: ProjectStatus.aprovado,
    ),
    AdminProject(
      title: 'Plataforma de Ideias',
      author: 'Lucas Pereira',
      points: 150,
      likes: 20,
      createdAt: DateTime(2024, 10, 2),
      status: ProjectStatus.aprovado,
    ),
    AdminProject(
      title: 'Linha de Produção Automatizada',
      author: 'Mariana Carvalho',
      points: 260,
      likes: 34,
      createdAt: DateTime(2024, 12, 18),
      status: ProjectStatus.aprovado,
    ),

    // Novos: REPROVADOS
    AdminProject(
      title: 'App de Coffee Break Ilimitado',
      author: 'Rafael Lima',
      points: 40,
      likes: 2,
      createdAt: DateTime(2025, 1, 20),
      status: ProjectStatus.reprovado,
    ),
    AdminProject(
      title: 'Drone para Entrega Interna de Documentos',
      author: 'Bianca Torres',
      points: 70,
      likes: 6,
      createdAt: DateTime(2025, 2, 10),
      status: ProjectStatus.reprovado,
    ),

    // Novos: EM ANÁLISE (em andamento)
    AdminProject(
      title: 'Monitor IA de Qualidade em Produção',
      author: 'Ricardo Almeida',
      points: 120,
      likes: 10,
      createdAt: DateTime(2025, 3, 3),
      status: ProjectStatus.emAnalise,
    ),
    AdminProject(
      title: 'Portal de Treinamentos Gamificado',
      author: 'Joana Martins',
      points: 90,
      likes: 8,
      createdAt: DateTime(2025, 4, 14),
      status: ProjectStatus.emAnalise,
    ),
  ];

  String _query = '';
  ProjectStatus? _statusFilter; // null = todos

  List<AdminProject> get _filtered {
    final q = _query.trim().toLowerCase();
    return _projects.where((p) {
      final matchesQuery = q.isEmpty ||
          p.title.toLowerCase().contains(q) ||
          p.author.toLowerCase().contains(q);
      final matchesStatus =
          _statusFilter == null ? true : p.status == _statusFilter;
      return matchesQuery && matchesStatus;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void _changeStatus(AdminProject p, ProjectStatus newStatus) {
    setState(() => p.status = newStatus);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Status atualizado para ${_statusLabel(newStatus)}'),
      ),
    );
  }

  String _statusLabel(ProjectStatus s) {
    switch (s) {
      case ProjectStatus.aprovado:
        return 'Aprovado';
      case ProjectStatus.reprovado:
        return 'Reprovado';
      case ProjectStatus.emAnalise:
        return 'Em análise';
    }
  }

  Color _statusColor(ProjectStatus s) {
    switch (s) {
      case ProjectStatus.aprovado:
        return const Color(0xFF1ABC9C);
      case ProjectStatus.reprovado:
        return const Color(0xFFE74C3C);
      case ProjectStatus.emAnalise:
        return const Color(0xFFFFB400);
    }
  }

  @override
Widget build(BuildContext context) {
  final items = _filtered;

  return Scaffold(
    extendBodyBehindAppBar: true,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        children: const [
          SizedBox(width: 8),
          AnimatedLogoImage(height: 36),
          SizedBox(width: 12),
          Text('Painel do Administrador'),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Sair',
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
          },
          icon: const Icon(Icons.logout),
        ),
        const SizedBox(width: 8),
      ],
    ),
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F172A), // azul bem escuro
            Color(0xFF111827), // cinza-azulado
          ],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: kToolbarHeight + 8),

          // Barra de busca + filtro de status
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                // Busca
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Pesquisar por título ou autor...',
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.10),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Filtro por status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ProjectStatus?>(
                      dropdownColor: const Color(0xFF1F2937),
                      value: _statusFilter,
                      iconEnabledColor: Colors.white,
                      onChanged: (v) => setState(() => _statusFilter = v),
                      items: [
                        const DropdownMenuItem<ProjectStatus?>(
                          value: null,
                          child: Text('Todos', style: TextStyle(color: Colors.white)),
                        ),
                        DropdownMenuItem<ProjectStatus?>(
                          value: ProjectStatus.aprovado,
                          child: Row(
                            children: const [
                              Icon(Icons.check_circle, color: Color(0xFF1ABC9C)),
                              SizedBox(width: 8),
                              Text('Aprovados', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        DropdownMenuItem<ProjectStatus?>(
                          value: ProjectStatus.emAnalise,
                          child: Row(
                            children: const [
                              Icon(Icons.hourglass_bottom, color: Color(0xFFFFB400)),
                              SizedBox(width: 8),
                              Text('Em análise', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        DropdownMenuItem<ProjectStatus?>(
                          value: ProjectStatus.reprovado,
                          child: Row(
                            children: const [
                              Icon(Icons.cancel, color: Color(0xFFE74C3C)),
                              SizedBox(width: 8),
                              Text('Reprovados', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Contadores rápidos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _QuickCounts(projects: _projects),
          ),

          const SizedBox(height: 12),

          // Lista de projetos
          Expanded(
            child: RepaintBoundary( // ajuda a isolar repaints
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _ProjectAdminCard(
                  project: items[i],
                  statusLabel: _statusLabel,
                  statusColor: _statusColor,
                  onChangeStatus: _changeStatus,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

}

class _ProjectAdminCard extends StatelessWidget {
  const _ProjectAdminCard({
    Key? key,
    required this.project,
    required this.statusLabel,
    required this.statusColor,
    required this.onChangeStatus,
  }) : super(key: key);

  final AdminProject project;
  final String Function(ProjectStatus) statusLabel;
  final Color Function(ProjectStatus) statusColor;
  final void Function(AdminProject, ProjectStatus) onChangeStatus;

  @override
  Widget build(BuildContext context) {
    final dateStr = MaterialLocalizations.of(context).formatMediumDate(project.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Linha superior
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge de status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor(project.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: statusColor(project.status)),
                ),
                child: Text(
                  statusLabel(project.status),
                  style: TextStyle(
                    color: statusColor(project.status),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Título/autor
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project.title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('por ${project.author}',
                        style:
                            const TextStyle(fontSize: 13, color: Colors.black54)),
                  ],
                ),
              ),
              // Pontos/likes/data
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, size: 18, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('${project.points}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.favorite, size: 16, color: Colors.red),
                      const SizedBox(width: 4),
                      Text('${project.likes}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(dateStr, style: const TextStyle(color: Colors.black45)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Ações de moderação
          LayoutBuilder(
            builder: (context, c) {
              final isWide = c.maxWidth > 420;
              final buttons = [
                Expanded(
                  child: TouchAnimatedButton(
                    label: 'APROVAR',
                    onPressed: () => onChangeStatus(project, ProjectStatus.aprovado),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TouchAnimatedButton(
                    label: 'EM ANÁLISE',
                    onPressed: () => onChangeStatus(project, ProjectStatus.emAnalise),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TouchAnimatedButton(
                    label: 'REPROVAR',
                    onPressed: () => onChangeStatus(project, ProjectStatus.reprovado),
                  ),
                ),
              ];

              return isWide
                  ? Row(children: buttons)
                  : Column(
                      children: [
                        buttons[0],
                        const SizedBox(height: 8),
                        buttons[2], // "const SizedBox(width: 8)" vira espaçador vertical
                        const SizedBox(height: 8),
                        buttons[4],
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickCounts extends StatelessWidget {
  const _QuickCounts({Key? key, required this.projects}) : super(key: key);

  final List<AdminProject> projects;

  int _count(ProjectStatus s) =>
      projects.where((p) => p.status == s).length;

  @override
  Widget build(BuildContext context) {
    final total = projects.length;
    final aprov = _count(ProjectStatus.aprovado);
    final anal  = _count(ProjectStatus.emAnalise);
    final repr  = _count(ProjectStatus.reprovado);

    Widget _pill(Color color, IconData icon, String label, String value) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
          ],
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            Text(value, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(child: _pill(const Color(0xFF1877F2), Icons.list_alt, 'Total', '$total')),
        const SizedBox(width: 8),
        Expanded(child: _pill(const Color(0xFF1ABC9C), Icons.check_circle, 'Aprovados', '$aprov')),
        const SizedBox(width: 8),
        Expanded(child: _pill(const Color(0xFFFFB400), Icons.hourglass_bottom, 'Em análise', '$anal')),
        const SizedBox(width: 8),
        Expanded(child: _pill(const Color(0xFFE74C3C), Icons.cancel, 'Reprovados', '$repr')),
      ],
    );
  }
}
