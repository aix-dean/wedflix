import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as my_auth;

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  bool _isProfilePrivate = false;
  bool _allowSearchByEmail = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
  }

  Future<void> _loadPrivacySettings() async {
    final user = context.read<my_auth.AuthProvider>().currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _isProfilePrivate = data['isProfilePrivate'] ?? false;
          _allowSearchByEmail = data['allowSearchByEmail'] ?? true;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _savePrivacySettings() async {
    setState(() => _isLoading = true);

    try {
      final user = context.read<my_auth.AuthProvider>().currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'isProfilePrivate': _isProfilePrivate,
          'allowSearchByEmail': _allowSearchByEmail,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Privacy settings updated')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating settings: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Privacy Settings'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Make Profile Private'),
              subtitle: const Text('Hide your profile from public view'),
              value: _isProfilePrivate,
              onChanged: (value) {
                setState(() => _isProfilePrivate = value);
                _savePrivacySettings();
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Allow Search by Email'),
              subtitle: const Text('Let others find you by email address'),
              value: _allowSearchByEmail,
              onChanged: (value) {
                setState(() => _allowSearchByEmail = value);
                _savePrivacySettings();
              },
            ),
          ],
        ),
      ),
    );
  }
}