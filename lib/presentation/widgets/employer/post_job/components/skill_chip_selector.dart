import 'package:flutter/material.dart';

import 'package:jobgo/data/repositories/skill_repository.dart';
import 'package:jobgo/core/localization/app_localizations.dart';
import 'package:jobgo/core/configs/theme/app_colors.dart';

class SkillChipSelector extends StatefulWidget {
  final List<String> selectedSkills;
  final ValueChanged<List<String>> onChanged;

  const SkillChipSelector({
    super.key,
    required this.selectedSkills,
    required this.onChanged,
  });

  @override
  State<SkillChipSelector> createState() => _SkillChipSelectorState();
}

class _SkillChipSelectorState extends State<SkillChipSelector> {
  static const List<String> _fallbackSuggestedSkills = [
    'Figma',
    'UI Design',
    'Flutter',
    'React',
    'Communication',
    'Leadership',
  ];

  final SkillRepository _skillRepository = SkillRepository();

  bool _isLoadingCatalog = true;
  bool _isCreatingCustomSkill = false;
  String? _loadError;
  final TextEditingController _skillDropdownController =
      TextEditingController();
  List<String> _catalogSkills = const [];

  @override
  void initState() {
    super.initState();
    _loadCatalogSkills();
  }

  @override
  void dispose() {
    _skillDropdownController.dispose();
    super.dispose();
  }

  Future<void> _loadCatalogSkills() async {
    setState(() {
      _isLoadingCatalog = true;
      _loadError = null;
    });

    try {
      final dbSkills = await _skillRepository.fetchSkills();
      final fromDb = dbSkills
          .map((skill) => SkillRepository.normalizeSkillName(skill.skName))
          .where((name) => name.isNotEmpty)
          .toList();

      if (!mounted) return;
      setState(() {
        _catalogSkills = _dedupeSkills([
          ...fromDb,
          ..._fallbackSuggestedSkills,
        ]);
        _isLoadingCatalog = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _catalogSkills = _dedupeSkills(_fallbackSuggestedSkills);
        _isLoadingCatalog = false;
        _loadError = 'failed';
      });
    }
  }

  Set<String> get _selectedNormalized => widget.selectedSkills
      .map((skill) => _skillKey(skill))
      .where((key) => key.isNotEmpty)
      .toSet();

  List<String> _dedupeSkills(Iterable<String> skills) {
    final seen = <String>{};
    final unique = <String>[];

    for (final raw in skills) {
      final cleaned = SkillRepository.normalizeSkillName(raw);
      final key = _skillKey(cleaned);
      if (cleaned.isEmpty || key.isEmpty || seen.contains(key)) continue;
      seen.add(key);
      unique.add(cleaned);
    }

    return unique;
  }

  String _skillKey(String skill) {
    return SkillRepository.normalizeSkillName(skill).toLowerCase();
  }

  void _addSkill(String skill) {
    final cleaned = SkillRepository.normalizeSkillName(skill);
    final key = _skillKey(cleaned);
    if (cleaned.isEmpty || key.isEmpty) return;
    if (_selectedNormalized.contains(key)) return;

    final newList = _dedupeSkills([...widget.selectedSkills, cleaned]);
    widget.onChanged(newList);
  }

  void _removeSkill(String skill) {
    final removeKey = _skillKey(skill);
    final newList = widget.selectedSkills
        .where((item) => _skillKey(item) != removeKey)
        .toList();
    widget.onChanged(newList);
  }

  Future<void> _addCustomSkill() async {
    final loc = AppLocalizations.of(context);
    final dialogResult = await showDialog<_CustomSkillInput>(
      context: context,
      builder: (_) => _CustomSkillDialog(
        isSaving: _isCreatingCustomSkill,
        title: loc.customSkillDialogTitle,
        nameLabel: loc.skillLabel,
        nameHint: loc.skillSearchHint,
        descriptionLabel: loc.description,
        descriptionHint: loc.customSkillDescriptionHint,
        saveLabel: loc.customSkillSaveAction,
        cancelLabel: loc.cancel,
      ),
    );

    if (dialogResult == null) return;

    final validationError = _validateCustomSkillName(
      loc: loc,
      rawName: dialogResult.name,
    );
    if (validationError != null) {
      _showSnackBar(validationError);
      return;
    }

    final skillName = SkillRepository.normalizeSkillName(dialogResult.name);
    if (_selectedNormalized.contains(_skillKey(skillName))) {
      _showSnackBar(loc.customSkillAlreadySelected);
      return;
    }

    final existingCatalogSkill = _findCatalogSkill(skillName);
    if (existingCatalogSkill != null) {
      _addSkill(existingCatalogSkill);
      _showSnackBar(loc.customSkillAddedSuccess);
      return;
    }

    setState(() => _isCreatingCustomSkill = true);
    try {
      final skill = await _skillRepository.getOrCreateSkill(
        skillName: skillName,
        description: dialogResult.description,
      );
      final createdName = SkillRepository.normalizeSkillName(skill.skName);
      _upsertCatalogSkill(createdName);
      _addSkill(createdName);
      if (mounted) {
        _showSnackBar(loc.customSkillAddedSuccess);
      }
    } catch (_) {
      // Fallback: keep post-job flow working even if writing to master list fails.
      _upsertCatalogSkill(skillName);
      _addSkill(skillName);
      if (mounted) {
        _showSnackBar(loc.customSkillAddedLocalOnly);
      }
    } finally {
      if (mounted) {
        setState(() => _isCreatingCustomSkill = false);
      }
    }
  }

  void _upsertCatalogSkill(String skillName) {
    final merged = _dedupeSkills([..._catalogSkills, skillName]);
    if (mounted) {
      setState(() => _catalogSkills = merged);
    } else {
      _catalogSkills = merged;
    }
  }

  String? _validateCustomSkillName({
    required AppLocalizations loc,
    required String rawName,
  }) {
    final name = SkillRepository.normalizeSkillName(rawName);
    if (name.isEmpty) return loc.customSkillNameRequired;
    if (name.length < 2) return loc.customSkillNameTooShort;
    if (name.length > 50) return loc.customSkillNameTooLong;
    if (!RegExp(r"^[A-Za-z0-9À-ỹà-ỹ\s\+\#\.\-\/&]+$").hasMatch(name)) {
      return loc.customSkillNameInvalid;
    }

    return null;
  }

  String? _findCatalogSkill(String skillName) {
    final targetKey = _skillKey(skillName);
    for (final skill in _catalogSkills) {
      if (_skillKey(skill) == targetKey) {
        return skill;
      }
    }
    return null;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final selectedKeys = _selectedNormalized;
    final availableSkills = _catalogSkills
        .where((skill) => !selectedKeys.contains(_skillKey(skill)))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.addSkills,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (_isLoadingCatalog)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: LinearProgressIndicator(minHeight: 2),
          ),
        if (_loadError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              loc.customSkillCatalogFallback,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        LayoutBuilder(
          builder: (context, constraints) {
            return DropdownMenu<String>(
              controller: _skillDropdownController,
              width: constraints.maxWidth,
              label: Text(loc.skillLabel),
              hintText: loc.skillSearchHint,
              leadingIcon: const Icon(Icons.search),
              enableFilter: true,
              enableSearch: true,
              requestFocusOnTap: true,
              menuHeight: 320,
              enabled: !_isLoadingCatalog && availableSkills.isNotEmpty,
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              dropdownMenuEntries: availableSkills
                  .map(
                    (skill) => DropdownMenuEntry<String>(
                      value: skill,
                      label: _skillLabel(loc, skill),
                    ),
                  )
                  .toList(),
              onSelected: (skill) {
                if (skill == null) return;
                _addSkill(skill);
                _skillDropdownController.clear();
                FocusScope.of(context).unfocus();
                setState(() {});
              },
            );
          },
        ),
        if (!_isLoadingCatalog && availableSkills.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              loc.noSkillsListed,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...widget.selectedSkills.map(
              (skill) => Chip(
                label: Text(_skillLabel(loc, skill)),
                deleteIconColor: AppColors.error,
                onDeleted: () => _removeSkill(skill),
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _isCreatingCustomSkill ? null : _addCustomSkill,
            icon: const Icon(Icons.add_circle_outline),
            label: Text(_isCreatingCustomSkill ? loc.loading : loc.addCustom),
          ),
        ),
      ],
    );
  }

  String _skillLabel(AppLocalizations loc, String skill) {
    switch (skill) {
      case 'Figma':
        return loc.figma;
      case 'UI Design':
        return loc.uiDesign;
      case 'Flutter':
        return loc.flutter;
      case 'React':
        return loc.react;
      case 'Communication':
        return loc.communication;
      case 'Leadership':
        return loc.leadership;
      default:
        return skill;
    }
  }
}

class _CustomSkillInput {
  final String name;
  final String description;

  const _CustomSkillInput({required this.name, required this.description});
}

class _CustomSkillDialog extends StatefulWidget {
  final bool isSaving;
  final String title;
  final String nameLabel;
  final String nameHint;
  final String descriptionLabel;
  final String descriptionHint;
  final String saveLabel;
  final String cancelLabel;

  const _CustomSkillDialog({
    required this.isSaving,
    required this.title,
    required this.nameLabel,
    required this.nameHint,
    required this.descriptionLabel,
    required this.descriptionHint,
    required this.saveLabel,
    required this.cancelLabel,
  });

  @override
  State<_CustomSkillDialog> createState() => _CustomSkillDialogState();
}

class _CustomSkillDialogState extends State<_CustomSkillDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: widget.nameLabel,
              hintText: widget.nameHint,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 2,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: widget.descriptionLabel,
              hintText: widget.descriptionHint,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.isSaving ? null : () => Navigator.pop(context),
          child: Text(widget.cancelLabel),
        ),
        ElevatedButton(
          onPressed: widget.isSaving
              ? null
              : () => Navigator.pop(
                  context,
                  _CustomSkillInput(
                    name: _nameController.text,
                    description: _descriptionController.text,
                  ),
                ),
          child: Text(widget.saveLabel),
        ),
      ],
    );
  }
}
