import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_provider.dart';

class AppearanceSettingsScreen extends ConsumerStatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  ConsumerState<AppearanceSettingsScreen> createState() => _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState extends ConsumerState<AppearanceSettingsScreen> {
  // We'll apply it immediately using the provider, so we don't necessarily need a separate save step
  // But if the user expects one, we can track _selectedThemeMode.
  // The requirement says: "If theme changes are applied immediately, keep the behavior consistent with that design and avoid a redundant save flow."
  // Since we use Riverpod and `themeModeProvider.notifier.setThemeMode` will persist it and apply it instantly, we don't need a Save button.

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFEAE4F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF0F0F11)),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text('Appearance Settings', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F0F11), fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Make GovPrep AI comfortable for your eyes.', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 12)),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _buildBody(currentThemeMode, isDark),
      ),
    );
  }

  Widget _buildBody(ThemeMode currentThemeMode, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCurrentAppearanceCard(currentThemeMode, isDark),
                  const SizedBox(height: 32),
                  
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildThemeSelectionList(currentThemeMode, isDark)),
                        const SizedBox(width: 24),
                        Expanded(flex: 2, child: _buildThemePreviewPanel(isDark)),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildThemeSelectionList(currentThemeMode, isDark),
                        const SizedBox(height: 32),
                        _buildThemePreviewPanel(isDark),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentAppearanceCard(ThemeMode mode, bool isDark) {
    String modeName = 'Light Mode';
    IconData modeIcon = Icons.light_mode;
    String description = 'A bright interface for daytime use.';

    if (mode == ThemeMode.dark) {
      modeName = 'Dark Mode';
      modeIcon = Icons.dark_mode;
      description = 'A darker interface for reduced ambient light.';
    } else if (mode == ThemeMode.system) {
      modeName = 'System Default';
      modeIcon = Icons.brightness_auto;
      description = 'Follows the device or browser\'s preferred appearance.';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE4DBF6), width: 2),
        boxShadow: [
          if (!isDark) BoxShadow(color: const Color(0xFF0F0F11).withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF9F8FD),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(modeIcon, size: 32, color: const Color(0xFF5A31F4)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Appearance', style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  modeName,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F0F11)),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelectionList(ThemeMode currentMode, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Theme Mode', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
        const SizedBox(height: 16),
        _buildThemeOptionCard(
          mode: ThemeMode.light,
          currentMode: currentMode,
          title: 'Light',
          description: 'A bright interface for daytime use.',
          icon: Icons.light_mode,
          isDarkTheme: isDark,
        ),
        const SizedBox(height: 16),
        _buildThemeOptionCard(
          mode: ThemeMode.dark,
          currentMode: currentMode,
          title: 'Dark',
          description: 'A darker interface for reduced ambient light.',
          icon: Icons.dark_mode,
          isDarkTheme: isDark,
        ),
        const SizedBox(height: 16),
        _buildThemeOptionCard(
          mode: ThemeMode.system,
          currentMode: currentMode,
          title: 'System Default',
          description: 'Follow the device or browser\'s preferred appearance.',
          icon: Icons.brightness_auto,
          isDarkTheme: isDark,
        ),
      ],
    );
  }

  Widget _buildThemeOptionCard({
    required ThemeMode mode,
    required ThemeMode currentMode,
    required String title,
    required String description,
    required IconData icon,
    required bool isDarkTheme,
  }) {
    final isSelected = currentMode == mode;

    return InkWell(
      onTap: () {
        ref.read(themeModeProvider.notifier).setThemeMode(mode);
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDarkTheme ? const Color(0xFF2C2C2E) : const Color(0xFFF9F8FD)) 
              : (isDarkTheme ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF5A31F4) 
                : (isDarkTheme ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected && !isDarkTheme
              ? [BoxShadow(color: const Color(0xFF5A31F4).withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF5A31F4) : (isDarkTheme ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: isSelected ? Colors.white : (isDarkTheme ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected 
                          ? const Color(0xFF5A31F4) 
                          : (isDarkTheme ? Colors.white : const Color(0xFF0F0F11)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 13, color: isDarkTheme ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFF5A31F4) : (isDarkTheme ? Colors.grey[600] : Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemePreviewPanel(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6))),
            ),
            child: Row(
              children: [
                const Icon(Icons.palette_outlined, size: 20, color: Color(0xFF5A31F4)),
                const SizedBox(width: 12),
                Text('Live Preview', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.grey[800])),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF9F8FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.widgets_outlined, size: 20, color: isDark ? Colors.grey[400] : Colors.grey[700]),
                      const SizedBox(width: 16),
                      Text('Sample Component', style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : const Color(0xFF0F0F11))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5A31F4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text('Primary Button'),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3B3B1F) : const Color(0xFFFDF0D5).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? const Color(0xFF3B3B1F) : const Color(0xFFFDF0D5)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: isDark ? const Color(0xFFFFD700) : const Color(0xFFB8860B)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'The theme applies instantly across the app.',
                          style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
