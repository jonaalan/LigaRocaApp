import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Para kIsWeb

class WebContainer extends StatelessWidget {
  final Widget child;

  const WebContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Si es Web, centramos y limitamos el ancho. Si es móvil, dejamos que ocupe todo.
    if (kIsWeb) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: child,
        ),
      );
    }
    return child;
  }
}
