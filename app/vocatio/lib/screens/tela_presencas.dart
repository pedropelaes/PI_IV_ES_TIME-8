import 'package:flutter/material.dart';
import 'package:vocattio/widgets/app_header.dart';
import 'package:vocattio/widgets/background_containers.dart';
import 'package:vocattio/widgets/button_design.dart';

class PresencasScreen extends StatefulWidget {
  const PresencasScreen({super.key});

  @override
  State<PresencasScreen> createState() => _PresencasScreenState();
}

class _PresencasScreenState extends State<PresencasScreen> {
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (_, child) {
        return Theme(
          data: Theme.of(context),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _getDateText() {
    if (_selectedDate == null) {
      return 'Selecione a Data';
    }
    return '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppHeader(
        title: 'Presenças',
        onMenuPressed: () {
        },
        hasGoBack: true,
        onGoBack: () {
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
                final bool isLargeScreen = constraints.maxWidth > 700;
                double screenHeight = constraints.maxHeight;
                double scale = (screenHeight / 700).clamp(1.0, 1.5);
                double smallSpacing = (screenHeight * 0.015 * scale).clamp(6, 28);
                double largeSpacing = (screenHeight * 0.03 * scale).clamp(12, 72);

                Widget _listaPresencas = 
                primaryFixedGradientContainer(
                width: double.maxFinite,
                theme: theme,
                child: ListView.builder(
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('Aluno ${index + 1}', style: textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.primaryFixed
                      )),
                      trailing: Icon(Icons.check_circle, color: theme.colorScheme.primaryFixed),
                    );
                  },
                ), 
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Turma 1',
                    style: textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onSurface
                    ),
                  ),
                  SizedBox(height: smallSpacing,),
                  Expanded(
                    child: isLargeScreen ? Center(
                      child: SizedBox(
                        width: 1000,
                        child: _listaPresencas,
                      ),
                    )
                    : _listaPresencas
                  ),
                  SizedBox(height: smallSpacing),
                  onPrimaryStyleButtonDesign(
                    context: context, 
                    label: Text(_getDateText(), style: textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primaryFixedDim)),
                    icon: Icons.calendar_month_outlined, 
                    onTap: () => _selectDate(context),
                    width: 255,
                    height: 55
                  ),
                  SizedBox(height: smallSpacing),
                  primaryButtonDesign(
                    context: context, 
                    label: 'Reabrir chamada', 
                    onTap: (){

                    }, 
                    width: 255, 
                    height: 55
                  ),
                  SizedBox(height: largeSpacing,),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

}
