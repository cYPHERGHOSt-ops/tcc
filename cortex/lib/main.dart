import 'package:flutter/material.dart';

import '../../services/resposta_storage.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await RespostaStorage().limparTodas();

  runApp(const CortexApp());
}
