import 'package:flutter/material.dart';
import 'package:ev_charging/shared_preferences/shared_preferences_helper.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String selectedLanguage = "English";
  String selectedTheme = "Light";
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load saved settings
  _loadSettings() async {
    String? savedTheme = await SharedPreferencesHelper.getTheme();
    String? savedLanguage = await SharedPreferencesHelper.getLanguage();

    setState(() {
      selectedTheme = savedTheme ?? "Light";
      selectedLanguage = savedLanguage ?? "English";
      _themeMode = selectedTheme == "Dark" ? ThemeMode.dark : ThemeMode.light;
    });
  }

  // Show Theme Dialog
  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Select Theme",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption("Light", Icons.light_mode),
              Divider(height: 1),
              _buildThemeOption("Dark", Icons.dark_mode),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(String theme, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(
        "$theme Theme",
        style: GoogleFonts.poppins(),
      ),
      trailing: selectedTheme == theme
          ? Icon(Icons.check, color: Theme.of(context).primaryColor)
          : null,
      onTap: () async {
        await SharedPreferencesHelper.saveTheme(theme);
        setState(() {
          selectedTheme = theme;
          _themeMode = theme == "Dark" ? ThemeMode.dark : ThemeMode.light;
        });
        Navigator.pop(context);
      },
    );
  }

  // Show Language Dialog
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Select Language",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption("English", "🇬🇧"),
              Divider(height: 1),
              _buildLanguageOption("Spanish", "🇪🇸"),
              Divider(height: 1),
              _buildLanguageOption("French", "🇫🇷"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String language, String flag) {
    return ListTile(
      leading: Text(flag, style: TextStyle(fontSize: 24)),
      title: Text(
        language,
        style: GoogleFonts.poppins(),
      ),
      trailing: selectedLanguage == language
          ? Icon(Icons.check, color: Theme.of(context).primaryColor)
          : null,
      onTap: () async {
        await SharedPreferencesHelper.saveLanguage(language);
        setState(() {
          selectedLanguage = language;
        });
        Navigator.pop(context);
      },
    );
  }

  // Show About Dialog
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "About EV Charging",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Icon(
                  Icons.ev_station,
                  size: 50,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "EV Charging Station App",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Version: 1.0.0",
                style: GoogleFonts.poppins(),
              ),
              SizedBox(height: 16),
              Text(
                "Manage your charging station efficiently with this app.",
                style: GoogleFonts.poppins(),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                "OK",
                style: GoogleFonts.poppins(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _themeMode == ThemeMode.dark
          ? ThemeData.dark().copyWith(
        primaryColor: Colors.blueAccent,
        colorScheme: ColorScheme.dark(primary: Colors.blueAccent),
      )
          : ThemeData.light().copyWith(
        primaryColor: Colors.blue.shade800,
        colorScheme: ColorScheme.light(primary: Colors.blue.shade800),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Settings",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue.shade900,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // Theme Setting
              _buildSettingCard(
                icon: Icons.color_lens,
                title: "App Theme",
                subtitle: selectedTheme,
                onTap: () => _showThemeDialog(context),
              ),
              SizedBox(height: 16),

              // Language Setting
              _buildSettingCard(
                icon: Icons.language,
                title: "Language",
                subtitle: selectedLanguage,
                onTap: () => _showLanguageDialog(context),
              ),
              SizedBox(height: 16),

              // About
              _buildSettingCard(
                icon: Icons.info,
                title: "About",
                subtitle: "App version & information",
                onTap: () => _showAboutDialog(context),
              ),
              SizedBox(height: 16),

              // Help
              _buildSettingCard(
                icon: Icons.help,
                title: "Help & Support",
                subtitle: "Get help with the app",
                onTap: () {
                  // Show Help information
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.blue.shade900,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}