import 'package:arabiya/ui/home_page.dart';
import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: AppBar(title: const Text('التقارير')),
          drawer: drawer(context),
          body: const Placeholder(),
        );
      },
    );
  }
}
