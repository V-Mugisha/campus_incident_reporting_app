import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/incident.dart';
import '../../models/incident_category.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/snackbar.dart';
import '../../utils/validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/category_selector.dart';
import '../../widgets/form_section_label.dart';
import '../../widgets/location_dropdown.dart';
import '../../widgets/photo_picker_field.dart';
import '../../widgets/primary_button.dart';

class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({super.key, this.editing});

  /// When set, the screen edits this report instead of creating a new one.
  final Incident? editing;

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _specifyLocationController = TextEditingController();

  final _titleFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _specifyLocationFocus = FocusNode();
  final _scrollController = ScrollController();

  IncidentCategory? _category;
  String? _location;
  File? _photo;
  bool _autovalidate = false;

  String _initialTitle = '';
  String _initialDescription = '';
  IncidentCategory? _initialCategory;
  String? _initialLocation;
  String _initialSpecify = '';

  @override
  void initState() {
    super.initState();
    final editing = widget.editing;
    if (editing == null) return;

    _category = editing.category;
    _titleController.text = editing.title;
    _descriptionController.text = editing.description;

    final location = editing.location;
    if (location != null && location.isNotEmpty) {
      if (campusLocations.contains(location) && location != 'Other') {
        _location = location;
      } else {
        _location = 'Other';
        if (location != 'Other') {
          _specifyLocationController.text = location;
        }
      }
    }

    _initialTitle = _titleController.text.trim();
    _initialDescription = _descriptionController.text.trim();
    _initialCategory = _category;
    _initialLocation = _location;
    _initialSpecify = _specifyLocationController.text.trim();
  }

  bool get _isDirty {
    if (widget.editing != null) {
      return _titleController.text.trim() != _initialTitle ||
          _descriptionController.text.trim() != _initialDescription ||
          _category != _initialCategory ||
          _location != _initialLocation ||
          _specifyLocationController.text.trim() != _initialSpecify ||
          _photo != null;
    }
    return _category != null ||
        _titleController.text.trim().isNotEmpty ||
        _descriptionController.text.trim().isNotEmpty ||
        _location != null ||
        _specifyLocationController.text.trim().isNotEmpty ||
        _photo != null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _specifyLocationController.dispose();
    _titleFocus.dispose();
    _descriptionFocus.dispose();
    _specifyLocationFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<bool> _confirmDiscard() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Discard report?'),
        content: const Text('Your changes will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _handlePop() async {
    final discard = await _confirmDiscard();
    if (discard && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _scrollToFirstInvalid() {
    if (_category == null) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else if (validateTitle(_titleController.text) != null) {
      _titleFocus.requestFocus();
    } else if (validateDescription(_descriptionController.text) != null) {
      _descriptionFocus.requestFocus();
    } else if (_location == 'Other' &&
        validateSpecifyLocation(_specifyLocationController.text) != null) {
      _specifyLocationFocus.requestFocus();
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _autovalidate = true);

    if (!_formKey.currentState!.validate()) {
      _scrollToFirstInvalid();
      return;
    }

    final reporter = context.read<AuthProvider>().currentUser;
    if (reporter == null) return;

    final String? location;
    if (_location == 'Other') {
      location = _specifyLocationController.text.trim();
    } else {
      location = _location;
    }

    final incidents = context.read<IncidentProvider>();
    final editing = widget.editing;
    final ok = editing != null
        ? await incidents.updateIncident(
            id: editing.id,
            category: _category!,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            location: location,
          )
        : await incidents.submitIncident(
            category: _category!,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            location: location,
            reporter: reporter,
          );

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      showErrorSnackBar(
        context,
        incidents.submitError ??
            (editing != null
                ? "Couldn't update your report. Please try again."
                : "Couldn't submit your report. Please try again."),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.watch<IncidentProvider>().isSubmitting;

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handlePop();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 8,
              bottom: 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TopBar(
                      onBack: () => Navigator.maybePop(context),
                      title: widget.editing != null
                          ? 'Edit Report'
                          : 'Report an Incident',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.editing != null
                          ? 'Update the details of your report.'
                          : 'Tell us what happened so campus staff can act quickly.',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Form(
                      key: _formKey,
                      autovalidateMode: _autovalidate
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AnimatedOpacity(
                            opacity: isSubmitting ? 0.6 : 1,
                            duration: const Duration(milliseconds: 200),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const FormSectionLabel(
                                  label: 'Select a category',
                                ),
                                const SizedBox(height: 8),
                                CategorySelector(
                                  initialValue: _category?.key,
                                  onChanged: (key) => setState(
                                    () => _category =
                                        IncidentCategory.fromKey(key),
                                  ),
                                  validator: validateCategory,
                                  enabled: !isSubmitting,
                                ),
                                const SizedBox(height: 24),
                                AppTextField(
                                  label: 'Title',
                                  hint: 'Briefly describe the issue...',
                                  controller: _titleController,
                                  focusNode: _titleFocus,
                                  validator: validateTitle,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  textInputAction: TextInputAction.next,
                                  maxLength: 80,
                                  enabled: !isSubmitting,
                                ),
                                const SizedBox(height: 24),
                                AppTextField(
                                  label: 'Description',
                                  hint:
                                      'Provide more details about the issue... '
                                      'e.g. what happened, when, impact, etc.',
                                  controller: _descriptionController,
                                  focusNode: _descriptionFocus,
                                  validator: validateDescription,
                                  keyboardType: TextInputType.multiline,
                                  textInputAction: TextInputAction.newline,
                                  minLines: 4,
                                  maxLines: 8,
                                  maxLength: 500,
                                  enabled: !isSubmitting,
                                ),
                                const SizedBox(height: 24),
                                const FormSectionLabel(label: 'Location'),
                                const SizedBox(height: 8),
                                LocationDropdown(
                                  initialValue: _location,
                                  onChanged: (v) =>
                                      setState(() => _location = v),
                                  validator: validateLocation,
                                  enabled: !isSubmitting,
                                ),
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 200),
                                  alignment: Alignment.topCenter,
                                  child: _location == 'Other'
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                            top: 12,
                                          ),
                                          child: AppTextField(
                                            label: 'Specify location',
                                            hint: 'Enter the location',
                                            controller:
                                                _specifyLocationController,
                                            focusNode: _specifyLocationFocus,
                                            validator: validateSpecifyLocation,
                                            enabled: !isSubmitting,
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                                const SizedBox(height: 24),
                                const FormSectionLabel(
                                  label: 'Add a photo',
                                  suffix: '(optional)',
                                ),
                                const SizedBox(height: 8),
                                PhotoPickerField(
                                  value: _photo,
                                  onChanged: (f) => setState(() => _photo = f),
                                  enabled: !isSubmitting,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          PrimaryButton(
                            label: widget.editing != null
                                ? 'Save Changes'
                                : 'Submit Report',
                            isLoading: isSubmitting,
                            onPressed: _submit,
                          ),
                          const SizedBox(height: 12),
                          const Center(
                            child: Text(
                              'Your report will be visible to campus staff.',
                              style: TextStyle(
                                color: AppColors.textHint,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack, required this.title});

  final VoidCallback onBack;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 44),
      ],
    );
  }
}
