import 'package:flutter/material.dart';

import 'package:jobgo/presentation/widgets/common/adaptive_button_label.dart';
import 'package:jobgo/core/localization/app_localizations.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';

class PreviewBottomActions extends StatelessWidget {
  final Future<void> Function() onSaveDraft;
  final Future<void> Function() onConfirm;
  final VoidCallback onBackToEdit;
  final bool isBusy;
  final String saveDraftLabel;
  final String confirmLabel;
  final Future<void> Function()? onAddAnotherJob;

  const PreviewBottomActions({
    super.key,
    required this.onSaveDraft,
    required this.onConfirm,
    required this.onBackToEdit,
    required this.isBusy,
    this.saveDraftLabel = '',
    this.confirmLabel = '',
    this.onAddAnotherJob,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          if (onAddAnotherJob != null) ...[
            OutlinedButton.icon(
              onPressed: isBusy ? null : () => onAddAnotherJob!(),
              icon: const Icon(Icons.add, size: 20),
              label: AdaptiveButtonLabel(text: loc.addAnotherJob),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isBusy ? null : onBackToEdit,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: AdaptiveButtonLabel(text: loc.backToEdit),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: isBusy ? null : () => onConfirm(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: isBusy
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : AdaptiveButtonLabel(
                          text: confirmLabel.isEmpty
                              ? loc.confirmAndPost
                              : confirmLabel,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: isBusy ? null : () => onSaveDraft(),
              child: AdaptiveButtonLabel(
                text: saveDraftLabel.isEmpty ? loc.saveDraft : saveDraftLabel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
