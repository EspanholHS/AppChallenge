// lib/pages/submit_idea_page.dart

import 'package:flutter/material.dart';
import 'package:my_flutter_app/widgets/logout_button.dart';
import '../widgets/background_scaffold.dart';
import '../widgets/animated_logo_image.dart';
import '../widgets/touch_animated_button.dart';

class SubmitIdeaPage extends StatefulWidget {
  const SubmitIdeaPage({Key? key}) : super(key: key);

  @override
  _SubmitIdeaPageState createState() => _SubmitIdeaPageState();
}

class _SubmitIdeaPageState extends State<SubmitIdeaPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _categories = ['Processos', 'Produtos', 'Sustentabilidade', 'Outros'];

  String? _selectedCategory;
  String? _fileName;

  late FocusNode _titleFocus;
  late FocusNode _descFocus;
  late FocusNode _catFocus;

  @override
  void initState() {
    super.initState();
    _titleFocus = FocusNode()..addListener(() => setState(() {}));
    _descFocus  = FocusNode()..addListener(() => setState(() {}));
    _catFocus   = FocusNode()..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleFocus.dispose();
    _descFocus.dispose();
    _catFocus.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _pickFile() {
    // TODO: implementar file picker real
    setState(() => _fileName = 'documento.pdf');
  }

  // ✅ ALTERADO: agora a tela retorna a ideia criada para quem chamou
  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final newIdea = <String, dynamic>{
      'title'      : _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'category'   : _selectedCategory,
      'fileName'   : _fileName,
      'status'     : 'Em análise',
      'createdAt'  : DateTime.now(), // use como preferir na home
    };

    // Devolve os dados para a página anterior (home) capturar via await
    Navigator.pop(context, newIdea);
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
        Navigator.pushReplacementNamed(context, '/points');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/explore');
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: true,
          actions: const [LogoutButton()],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(child: AnimatedLogoImage(height: 60)),
                    const SizedBox(height: 32),

                    // TÍTULO
                    const Text('TÍTULO',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: _titleFocus.hasFocus ? 12 : 4,
                            offset: Offset(0, _titleFocus.hasFocus ? 6 : 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _titleCtrl,
                        focusNode: _titleFocus,
                        decoration: const InputDecoration(
                          hintText: 'Insira o título',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // DESCRIÇÃO
                    const Text('DESCRIÇÃO',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: _descFocus.hasFocus ? 12 : 4,
                            offset: Offset(0, _descFocus.hasFocus ? 6 : 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _descCtrl,
                        focusNode: _descFocus,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: 'Descreva a sua ideia',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // CATEGORIA
                    const Text('CATEGORIA',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: _catFocus.hasFocus ? 12 : 4,
                            offset: Offset(0, _catFocus.hasFocus ? 6 : 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButtonFormField<String>(
                        focusNode: _catFocus,
                        value: _selectedCategory,
                        items: _categories
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '',
                        ),
                        dropdownColor: Colors.white,
                        elevation: 4,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        onChanged: (v) => setState(() => _selectedCategory = v),
                        validator: (v) => v == null ? 'Selecione uma categoria' : null,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // SELECIONAR ARQUIVO
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.attach_file),
                        label: Text(_fileName ?? 'Selecionar arquivo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ENVIAR IDEIA
                    TouchAnimatedButton(label: 'ENVIAR IDEIA', onPressed: _submit),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0, // você pode ajustar para refletir a aba atual
          onTap: _onTapNav,
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
      ),
    );
  }
}
