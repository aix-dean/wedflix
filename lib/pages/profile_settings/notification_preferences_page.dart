import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as my_auth;

class NotificationPreferencesPage extends StatefulWidget {
  const NotificationPreferencesPage({super.key});

  @override
  State<NotificationPreferencesPage> createState() => _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState extends State<NotificationPreferencesPage> {
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _smsAlerts = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreferences();
  }

  Future<void> _loadNotificationPreferences() async {
    final user = context.read<my_auth.AuthProvider>().currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _emailNotifications = data['emailNotifications'] ?? true;
          _pushNotifications = data['pushNotifications'] ?? true;
          _smsAlerts = data['smsAlerts'] ?? false;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveNotificationPreferences() async {
    setState(() => _isLoading = true);

    try {
      final user = context.read<my_auth.AuthProvider>().currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'emailNotifications': _emailNotifications,
          'pushNotifications': _pushNotifications,
          'smsAlerts': _smsAlerts,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification preferences updated')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating preferences: $e')),
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
          title: const Text('Notification Preferences'),
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
        title: const Text('Notification Preferences'),
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
              'Notification Preferences',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Email Notifications'),
              subtitle: const Text('Receive notifications via email'),
              value: _emailNotifications,
              onChanged: (value) {
                setState(() => _emailNotifications = value);
                _saveNotificationPreferences();
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive push notifications on your device'),
              value: _pushNotifications,
              onChanged: (value) {
                setState(() => _pushNotifications = value);
                _saveNotificationPreferences();
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('SMS Alerts'),
              subtitle: const Text('Receive alerts via SMS'),
              value: _smsAlerts,
              onChanged: (value) {
                setState(() => _smsAlerts = value);
                _saveNotificationPreferences();
              },
            ),
          ],
        ),
      ),
    );
  }
}