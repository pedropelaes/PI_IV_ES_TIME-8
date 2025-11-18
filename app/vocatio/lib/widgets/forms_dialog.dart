import 'package:flutter/material.dart';
import 'package:vocattio/widgets/background_containers.dart';

Future<T?> showFormsDialog<T>(
  BuildContext context,
  List<Widget> Function(StateSetter dialogSetState) content,
){
  final ThemeData theme = Theme.of(context);

  return showDialog<T>(
    context: context, 
    builder: (context){
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 420),
          child: Material(
            color: Colors.transparent,
            child: primaryFixedGradientContainer(
              theme: theme,
              padding: EdgeInsets.all(24.0),
              child: StatefulBuilder(
                builder: (context, dialogSetState) {
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: content(dialogSetState),
                    ),
                  );
                }
              )
            ),
          ),
        ),
      );
    }
  );
}