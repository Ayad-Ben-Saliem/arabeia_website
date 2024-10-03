import 'package:arabiya/db/db.dart';
import 'package:arabiya/models/user.dart';
import 'package:arabiya/ui/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UsersManagement extends StatefulWidget {
  const UsersManagement({super.key});

  @override
  UsersManagementState createState() => UsersManagementState();
}

class UsersManagementState extends State<UsersManagement> {
  List<User> _users = []; // List of users to display

  @override
  void initState() {
    super.initState();

    _fetchUsers(); // Fetch users when the page is initialized
  }

  // Function to fetch users from Firebase Firestore
  Future<void> _fetchUsers() async {
    final users = await Database.getUsers();
    setState(() => _users = users.toList());
  }

  // Function to display the form to add/edit users
  void _showUserForm({User? user}) {
    showDialog<User>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(user == null ? 'إضافة مستخدم جديد' : 'تعديل المستخدم ${user.username} - ${user.email}'),
          content: UserForm(user: user),
        );
      },
    ).then((newUser) {
      if (newUser != null) {
        if (user == null) {
          _users.add(newUser);
        } else {
          final index = _users.indexWhere((user) => user.id == newUser.id);
          _users[index] = newUser;
        }
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة المستخدمين')),
      drawer: drawer(context),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return ListTile(
            title: Text(user.username),
            subtitle: Text(user.email),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showUserForm(user: user), // Edit user
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteUser(user), // Delete user
                ),
              ],
            ),
            onTap: () {
              // Optionally show user details in a dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('تفاصيل المستخدم'),
                    content: Row(
                      children: [
                        const Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('اسم المستخدم'),
                            Text('البريد الإلكتروني'),
                            Text('الدور'),
                          ],
                        ),
                        const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('  |  '),
                            Text('  |  '),
                            Text('  |  '),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.username),
                            Text(user.email),
                            Text('${user.role}'),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        child: const Text('إغلاق'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserForm(), // Add user
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Function to delete a user from Firestore
  void _deleteUser(User user) async {
    await Database.deleteUser(user);
    setState(() {
      _users.removeWhere((u) => u.id == user.id);
    });
  }
}

class UserForm extends StatefulWidget {
  final User? user;

  const UserForm({super.key, this.user});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final formKey = GlobalKey<FormState>();

  late final StateProvider<User> userProvider;

  @override
  void initState() {
    super.initState();

    userProvider = StateProvider((_) {
      return widget.user ??
          const User(
            username: '',
            email: '',
            password: '',
            role: Role.customer,
          );
    });
  }

  @override
  Widget build(context) {
    return Consumer(
      builder: (context, ref, child) {
        final user = ref.read(userProvider);
        return Form(
          key: formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        initialValue: user.username,
                        decoration: const InputDecoration(labelText: 'اسم المستخدم'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال اسم المستخدم';
                          }
                          return null;
                        },
                        onSaved: (value) => _updateUser(ref, username: value),
                      ),
                      TextFormField(
                        initialValue: user.email,
                        decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                        validator: (value) {
                          if (value == null || value.isEmpty || !value.contains('@')) {
                            return 'الرجاء إدخال البريد الإلكتروني';
                          }
                          return null;
                        },
                        onSaved: (value) => _updateUser(ref, email: value),
                      ),
                      if (widget.user != null)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('كلمة السر تتغير فقط إذا قمت بتغير كلمة السر هنا'),
                        ),
                      Consumer(
                        builder: (context, ref, child) {
                          return TextFormField(
                            decoration: const InputDecoration(labelText: 'كلمة المرور'),
                            obscureText: true,
                            validator: (value) {
                              if(widget.user != null ) return null;
                              if (value?.isEmpty == true) {
                                return 'الرجاء إدخال كلمة المرور';
                              }
                              return null;
                            },
                            onChanged: (value) => _updateUser(ref, password: value),
                            onSaved: (value) => _updateUser(ref, password: value),
                          );
                        },
                      ),
                      Consumer(builder: (context, ref, child) {
                        return TextFormField(
                          decoration: const InputDecoration(labelText: 'تأكيد كلمة المرور'),
                          obscureText: true,
                          validator: (value) {
                            if (widget.user != null && value?.isEmpty == true) {
                              return 'الرجاء إدخال تأكيد كلمة المرور';
                            }
                            if (value != ref.read(userProvider).password) {
                              return 'كلمة المرور غير متطابقة';
                            }
                            return null;
                          },
                        );
                      }),
                      DropdownButtonFormField<Role>(
                        value: user.role,
                        decoration: const InputDecoration(labelText: 'دور المستخدم'),
                        onChanged: (value) => _updateUser(ref, role: value),
                        items: [
                          for (final role in Role.values) DropdownMenuItem(value: role, child: Text('$role')),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Text('المستخدم نشط'),
                          Consumer(
                            builder: (context, ref, child) {
                              return Switch(
                                value: ref.watch(userProvider.select((user) => user.active)),
                                onChanged: (value) => _updateUser(ref, active: value),
                              );
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: const Text('إلغاء'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  ElevatedButton(
                    child: Text(widget.user == null ? 'إضافة' : 'حفظ'),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();

                        _saveUser(ref.read(userProvider)).then((user) {
                          if (context.mounted) Navigator.pop(context, user);
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateUser(
    WidgetRef ref, {
    String? id,
    String? username,
    String? email,
    String? password,
    Role? role,
    bool? active,
  }) {
    ref.read(userProvider.notifier).state = ref.read(userProvider).copyWith(
          id: id,
          username: username,
          email: email,
          password: password,
          role: role,
          active: active,
        );
  }

  // Function to edit a user in Firestore
  Future<User> _saveUser(User user) async {
    if (user.id == null) {
      return await Database.addUser(user);
    } else {
      await Database.updateUser(user);
      return user;
    }
  }
}
