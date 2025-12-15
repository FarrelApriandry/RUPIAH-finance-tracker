import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/firestore_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Pengaturan")),
      body: ListView(
        children: [
          // 1. PROFILE SECTION
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _showAvatarSelector(context, ref, user),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(
                          user?.photoURL ??
                              "https://ui-avatars.com/api/?name=User",
                        ),
                      ),
                      const Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 16,
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user?.displayName ?? "User",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_note, color: Colors.grey),
                      onPressed: () =>
                          _showNameEditor(context, ref, user?.displayName),
                    ),
                  ],
                ),
                Text(
                  user?.email ?? "",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const Divider(),

          // 2. APPEARANCE
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              "Tampilan",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text("Mode Gelap"),
            subtitle: Text(
              themeMode == ThemeMode.system
                  ? "Mengikuti Sistem"
                  : (themeMode == ThemeMode.dark ? "Aktif" : "Nonaktif"),
            ),
            trailing: Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: (val) {
                // UPDATE DISINI: Panggil method setTheme dari Notifier
                ref
                    .read(themeModeProvider.notifier)
                    .setTheme(val ? ThemeMode.dark : ThemeMode.light);
              },
            ),
          ),

          const Divider(),

          // 3. DANGEROUS ZONE
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              "Zona Bahaya",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              "Reset Data Aplikasi",
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text("Hapus semua dompet & transaksi"),
            onTap: () => _confirmReset(context, ref),
          ),

          const Divider(),

          // 4. LOGOUT
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Keluar"),
            onTap: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted)
                Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }

  void _showNameEditor(
    BuildContext context,
    WidgetRef ref,
    String? currentName,
  ) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ganti Nama"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Nama Lengkap"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref
                    .read(authControllerProvider.notifier)
                    .updateProfile(displayName: controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _showAvatarSelector(BuildContext context, WidgetRef ref, User? user) {
    final List<String> avatars = List.generate(
      6,
      (index) => "https://api.multiavatar.com/${user?.uid ?? 'user'}$index.png",
    );

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: 200,
        child: Column(
          children: [
            const Text(
              "Pilih Avatar",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: avatars.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(authControllerProvider.notifier)
                          .updateProfile(photoURL: avatars[index]);
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(avatars[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Data?"),
        content: const Text(
          "SEMUA data dompet dan transaksi akan dihapus permanen. Tindakan ini tidak bisa dibatalkan.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(firestoreServiceProvider).deleteAllData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Data berhasil direset bersih!"),
                  ),
                );
              }
            },
            child: const Text("YA, HAPUS SEMUA"),
          ),
        ],
      ),
    );
  }
}
