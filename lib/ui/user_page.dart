import 'package:arabiya/db/db.dart';
import 'package:arabiya/models/user.dart';
import 'package:arabiya/ui/home_page.dart';
import 'package:arabiya/ui/widgets/custom_indicator.dart';
import 'package:arabiya/ui/widgets/user_view.dart';
import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  final String? id;
  final User? user;

  const UserPage({
    super.key,
    this.id,
    this.user,
  }) : assert(id != null || user != null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المستخدم ()')),
      drawer: drawer(context),
      body: Builder(
        builder: (context) {
          if(user != null) return UserView(user: user!);

          return Center(
            child: FutureBuilder<User?>(
              future: Database.getUser(id!),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    return UserView(user: snapshot.requireData!);
                  }
                } else if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CustomIndicator();
                }
                return Text('Error!! ${snapshot.error}');
              },
            ),
          );

        },
      ),
    );
  }
}
