import 'package:dartbasics/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showErrorDialog(BuildContext context, String text) async {
  return showGenericDialog(
    context: context,
    title: 'An error has occured',
    content: text,
    optionsBuilder: () => {'OK': null},
  );
}
