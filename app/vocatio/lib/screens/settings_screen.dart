import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vocattio/widgets/app_drawer.dart';
import 'package:vocattio/widgets/app_header.dart';
import 'package:vocattio/theme/theme_notifier.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedTheme = 'system';
  String _version = '...';
  String _buildNumber = '...';

  @override
  void initState() {
    super.initState();
    _getAppVersion();
    _loadSavedTheme();
  }

  Future<void> _getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = info.version;
      _buildNumber = info.buildNumber;
    });
  }

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('selected_theme') ?? 'system';
    setState(() {
      _selectedTheme = savedTheme;
    });

    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    switch (savedTheme) {
      case 'light':
        themeNotifier.setTheme(ThemeMode.light);
        break;
      case 'dark':
        themeNotifier.setTheme(ThemeMode.dark);
        break;
      default:
        themeNotifier.setTheme(ThemeMode.system);
    }
  }

  Future<void> _selectTheme(String theme) async {
    setState(() {
      _selectedTheme = theme;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_theme', theme);

    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    switch (theme) {
      case 'light':
        themeNotifier.setTheme(ThemeMode.light);
        break;
      case 'dark':
        themeNotifier.setTheme(ThemeMode.dark);
        break;
      default:
        themeNotifier.setTheme(ThemeMode.system);
    }
  }

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'vocattioltda@gmail.com',
      query: Uri.encodeFull('subject=Suporte - Vocattio'),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.colorScheme.surface,
      appBar: AppHeader(
        title: 'Configurações',
        hasGoBack: true,
        onGoBack: () => Navigator.pop(context),
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      //Passa o estado atual da lista de nomes para o AppDrawer
      drawer: const AppDrawer(), 
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 400),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        "Versão do App: v$_version",
                        style: textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 400),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Tema do aplicativo",
                          style: textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Column(
                          children: [
                            _TemaOpcao(
                              texto: "Sistema",
                              selecionado: _selectedTheme == "system",
                              onTap: () => _selectTheme("system"),
                              theme: theme,
                            ),
                            Divider(
                              color: theme.colorScheme.onSecondaryContainer,
                              thickness: 2,
                            ),
                            _TemaOpcao(
                              texto: "Claro",
                              selecionado: _selectedTheme == "light",
                              onTap: () => _selectTheme("light"),
                              theme: theme,
                            ),
                            Divider(
                              color: theme.colorScheme.onSecondaryContainer,
                              thickness: 2,
                            ),
                            _TemaOpcao(
                              texto: "Escuro",
                              selecionado: _selectedTheme == "dark",
                              onTap: () => _selectTheme("dark"),
                              theme: theme,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 400),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Suporte",
                          style: textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Caso tenha algum problema, envie uma mensagem para esse email:",
                          style: textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _launchEmail,
                          child: Text(
                            "vocattioltda@gmail.com",
                            style: textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TemaOpcao extends StatelessWidget {
  final String texto;
  final bool selecionado;
  final VoidCallback onTap;
  final ThemeData theme;

  const _TemaOpcao({
    required this.texto,
    required this.onTap,
    required this.theme,
    this.selecionado = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              texto,
              style: TextStyle(
                color: selecionado
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSecondaryContainer,
                fontWeight: selecionado ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.start,
            ),
            if (selecionado) ...[
              const SizedBox(width: 8),
              Icon(Icons.check, color: theme.colorScheme.primary, size: 18),
            ]
          ],
        ),
      ),
    );
  }
}
