import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:vocattio/models/turma.dart';
import 'package:vocattio/models/user.dart';
import 'package:vocattio/services/auth_service.dart';
import 'package:vocattio/services/locator.dart';
import 'package:vocattio/utils/responsive_helper.dart';
import 'package:vocattio/screens/settings_screen.dart';
import 'package:vocattio/screens/detalhes_turma.dart';
import 'package:vocattio/screens/home_screen.dart';

class AppDrawer extends StatefulWidget {
  final String? uid;
  final User? user;
  final String? currentTurmaId;

  const AppDrawer({
    super.key,
    this.uid,
    this.user,
    this.currentTurmaId,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
   List<Turma> turmas = [];
   User? _currentUser;
   final AuthService _authService = AuthService();
   bool _carregandoUsuario = false;

  @override
  void initState(){
    super.initState();
    _carregarTurmas();
    
    
    if (widget.user != null) {
      _currentUser = widget.user;
    } 
    
    else if (widget.uid != null) {
      _carregarUsuario();
    }
  }

  void _carregarTurmas() {
    if (getIt.isRegistered<List<Turma>>()) {
      final turmasAtualizadas = getIt<List<Turma>>();
      if (turmasAtualizadas.length != turmas.length || 
          !_listasIguais(turmas, turmasAtualizadas)) {
        setState(() {
          turmas = turmasAtualizadas;
        });
        print('Turmas carregadas no drawer: ${turmas.length}');
      }
    } else {
      print('Turmas ainda não registradas no getIt');
      
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _carregarTurmas();
        }
      });
    }
  }

  bool _listasIguais(List<Turma> lista1, List<Turma> lista2) {
    if (lista1.length != lista2.length) return false;
    for (int i = 0; i < lista1.length; i++) {
      if (lista1[i].objectId != lista2[i].objectId) {
        return false;
      }
    }
    return true;
  }

  Future<void> _carregarUsuario() async {
    if (widget.uid == null || _carregandoUsuario) return;
    
    setState(() {
      _carregandoUsuario = true;
    });
    
    try {
      final user = await _authService.getUser(widget.uid!);
      if (mounted) {
        setState(() {
          _currentUser = user;
          _carregandoUsuario = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar usuário no drawer: $e');
      if (mounted) {
        setState(() {
          _carregandoUsuario = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    
    if (getIt.isRegistered<List<Turma>>()) {
      final turmasAtualizadas = getIt<List<Turma>>();
      if (turmasAtualizadas.length != turmas.length || 
          !_listasIguais(turmas, turmasAtualizadas)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              turmas = turmasAtualizadas;
            });
          }
        });
      }
    }
    
    final ThemeData theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = ResponsiveHelper.isDesktop(context)
        ? screenWidth * 0.3
        : ResponsiveHelper.isTablet(context)
            ? screenWidth * 0.4
            : screenWidth * 0.5;

    return Drawer(
      width: drawerWidth,
      backgroundColor: theme.colorScheme.surface,
      child: Column(
        children: [
          Container(
            height: 120,
            width: double.infinity,
            child: Center(
              child: Image.asset(
                'assets/images/logo_vocatio_pequena_transparente.png',
                height: 60,
                width: 60,
                fit: BoxFit.contain,
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.home,
              color: theme.colorScheme.onSurface,
            ),
            title: Text(
              'Início',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            onTap: () async {
              Navigator.pop(context);
              // Aguarda o drawer fechar antes de navegar
              await Future.delayed(const Duration(milliseconds: 100));
              if (mounted) {
                _navegarParaHome(context);
              }
            },
            
          ),
          ListTile(
            leading: Icon(
              Icons.settings,
              color: theme.colorScheme.secondary,
            ),
            title: Text(
              'Configurações',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.pop(context); 

              final bool isSettingsScreen =
                  context.findAncestorWidgetOfExactType<SettingsScreen>() != null;

              if (isSettingsScreen) {
                return; 
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),


          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Turmas',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: turmas.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Nenhuma turma encontrada',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: turmas.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(
                          Icons.class_,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(
                          turmas[index].nome,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        onTap: () {
                          final turmaSelecionada = turmas[index];
                          Navigator.pop(context);

                          void navegarSePossivel() {
                            if (!mounted) return;
                            _abrirTurma(turmaSelecionada);
                          }

                          if (_currentUser == null) {
                            if (widget.uid != null) {
                              _carregarUsuario().then((_) {
                                if (_currentUser != null) {
                                  navegarSePossivel();
                                } else if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Erro: Não foi possível carregar informações do usuário'),
                                    ),
                                  );
                                }
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Erro: Não foi possível carregar informações do usuário'),
                                ),
                              );
                            }
                            return;
                          }

                          navegarSePossivel();
                        },
                      );
                    },
                  ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: theme.colorScheme.error,
            ),
            title: Text(
              'Sair',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Phoenix.rebirth(context);
              print('Usuário deslogado!');
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _navegarParaHome(BuildContext context) {
    
    String? uidParaNavegacao;
    
    if (_currentUser != null) {
      uidParaNavegacao = _currentUser!.uid;
    } else if (widget.uid != null) {
      uidParaNavegacao = widget.uid;
    } else if (widget.user != null) {
      uidParaNavegacao = widget.user!.uid;
    }

    if (uidParaNavegacao == null) {
     
      if (widget.uid != null) {
        _carregarUsuario().then((_) {
          if (_currentUser != null && mounted) {
            _navegarParaHomeAposCarregar(context, _currentUser!.uid);
          }
        });
      }
      return;
    }

   
    _navegarParaHomeAposCarregar(context, uidParaNavegacao);
  }

  void _navegarParaHomeAposCarregar(BuildContext context, String uid) {
   
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => HomeScreen(uid: uid),
      ),
      (route) => false, 
    );
  }

  void _abrirTurma(Turma turma) {
    if (_currentUser == null) {
      print('Erro: Usuário não disponível para navegação');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: Não foi possível carregar informações do usuário'),
        ),
      );
      return;
    }

    if (widget.currentTurmaId == turma.objectId) {
      // Já estamos na turma selecionada, nada a fazer
      return;
    }

    final novaTela = DetalhesTurmaScreen(
      nomeTurma: turma.nome,
      descricao: turma.descricao,
      numeroAlunos: turma.alunos.length,
      codigoTurma: turma.codigo,
      locPadrao: turma.localizacaoPadrao,
      turmaId: turma.objectId,
      user: _currentUser!,
    );

    if (widget.currentTurmaId != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => novaTela),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => novaTela),
      );
    }
  }
}




