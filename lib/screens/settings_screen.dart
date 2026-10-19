import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool remind7Days = true;
  bool remind3Days = true;
  bool remind1Day = true;

  bool _changed = false; // ✅ NEW

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /* -------------------- STORAGE -------------------- */

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled =
          prefs.getBool('notifications_enabled') ?? true;
      remind7Days = prefs.getBool('remind_7_days') ?? true;
      remind3Days = prefs.getBool('remind_3_days') ?? true;
      remind1Day = prefs.getBool('remind_1_day') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
        'notifications_enabled', notificationsEnabled);
    await prefs.setBool('remind_7_days', remind7Days);
    await prefs.setBool('remind_3_days', remind3Days);
    await prefs.setBool('remind_1_day', remind1Day);
  }

  /* -------------------- UI -------------------- */

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _changed); // ✅ RETURN RESULT
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: ListView(
          children: [
            SwitchListTile(
              title: const Text("Enable notifications"),
              subtitle:
                  const Text("Turn off to disable all reminders"),
              value: notificationsEnabled,
              onChanged: (value) async {
                setState(() {
                  notificationsEnabled = value;
                  _changed = true; // ✅ MARK CHANGE
                });

                if (!value) {
                  await NotificationService.cancelAll();
                }

                await _saveSettings();
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text("Remind 7 days before"),
              value: remind7Days,
              onChanged: notificationsEnabled
                  ? (value) async {
                      setState(() {
                        remind7Days = value;
                        _changed = true;
                      });
                      await _saveSettings();
                    }
                  : null,
            ),
            SwitchListTile(
              title: const Text("Remind 3 days before"),
              value: remind3Days,
              onChanged: notificationsEnabled
                  ? (value) async {
                      setState(() {
                        remind3Days = value;
                        _changed = true;
                      });
                      await _saveSettings();
                    }
                  : null,
            ),
            SwitchListTile(
              title: const Text("Remind 1 day before"),
              value: remind1Day,
              onChanged: notificationsEnabled
                  ? (value) async {
                      setState(() {
                        remind1Day = value;
                        _changed = true;
                      });
                      await _saveSettings();
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}