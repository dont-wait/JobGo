import 'package:flutter/material.dart';
import 'package:jobgo/core/localization/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';
import '../../../core/configs/theme/app_colors.dart';

class LanguageSelectorButton extends StatelessWidget {
  final bool isCompact;

  const LanguageSelectorButton({super.key, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        final currentLanguage = localeProvider.locale.languageCode;
        final isVietnamese = currentLanguage == 'vi';

        if (isCompact) {
          // Nút nhỏ gọn cho AppBar
          return PopupMenuButton<String>(
            onSelected: (String lang) {
              localeProvider.setLocale(Locale(lang));
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'vi',
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Text(
                      '🇻🇳 Tiếng Việt',
                      style: TextStyle(
                        fontSize: 14,
                        color: isVietnamese
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight: isVietnamese
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'en',
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Text(
                      '🇺🇸 English',
                      style: TextStyle(
                        fontSize: 14,
                        color: !isVietnamese
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight: !isVietnamese
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.language),
            tooltip: loc.selectLanguage,
          );
        } else {
          // Nút lớn cho trang settings
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.language,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.textHint),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          localeProvider.setLocale(const Locale('vi'));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isVietnamese
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(11),
                              bottomLeft: Radius.circular(11),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '🇻🇳 Tiếng Việt',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isVietnamese
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 1),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          localeProvider.setLocale(const Locale('en'));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isVietnamese
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(11),
                              bottomRight: Radius.circular(11),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '🇺🇸 English',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: !isVietnamese
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
