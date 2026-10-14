import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:service_hub_ai/core/service/service_locator.dart';
import 'package:service_hub_ai/core/theme/app_colors.dart';
import 'package:service_hub_ai/features/ai/data/datasources/ai_remote_datasource.dart';
import 'package:service_hub_ai/features/staff/domain/entities/staff_service.dart';
import 'package:service_hub_ai/features/staff/presentation/bloc/staff_service_bloc.dart';
import 'package:service_hub_ai/features/staff/presentation/bloc/staff_service_event.dart';
import 'package:service_hub_ai/features/staff/presentation/bloc/staff_service_state.dart';

import 'service_suggestion_tile.dart';

class AddStaffServiceDialog extends StatefulWidget {
  final String staffUid;

  const AddStaffServiceDialog({
    super.key,
    required this.staffUid,
  });

  @override
  State<AddStaffServiceDialog> createState() =>
      _AddStaffServiceDialogState();
}

class _AddStaffServiceDialogState
    extends State<AddStaffServiceDialog> {
  final _categoryController = TextEditingController();
  final _customController = TextEditingController();
  final _descriptionController = TextEditingController();

  final AiRemoteDatasource _aiDatasource = sl<AiRemoteDatasource>();

  final Set<String> _selectedServices = {};
  List<String> _suggestions = [];

  bool _loadingSuggestions = false;
  bool _saving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _categoryController.dispose();
    _customController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchSuggestions() async {
    final query = _categoryController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _errorMessage = 'Enter a service category first.';
        _suggestions = [];
      });
      return;
    }

    setState(() {
      _loadingSuggestions = true;
      _errorMessage = null;
      _suggestions = [];
      _selectedServices.clear();
    });

    try {
      final results = await _aiDatasource.getServiceSuggestions(
        serviceText: query,
      );

      if (!mounted) return;

      setState(() {
        _suggestions = results;
        _loadingSuggestions = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingSuggestions = false;
        _errorMessage = 'Unable to load suggestions. Please try again.';
      });
    }
  }

  void _toggleService(String service, bool selected) {
    setState(() {
      if (selected) {
        _selectedServices.add(service);
      } else {
        _selectedServices.remove(service);
      }
    });
  }

  Future<void> _saveServices() async {
    final customNames = _customController.text
        .split(RegExp(r'[,;\n]'))
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty);

    final uniqueNames = <String, String>{};

    for (final name in [
      ..._selectedServices,
      ...customNames,
    ]) {
      uniqueNames.putIfAbsent(name.toLowerCase(), () => name);
    }

    if (uniqueNames.isEmpty) {
      setState(() {
        _errorMessage =
            'Select an AI suggestion or enter a custom service.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    final services = uniqueNames.values.map((name) {
      return StaffService(
        id: '${DateTime.now().microsecondsSinceEpoch}_${servicesIdSuffix(name)}',
        name: name,
        description: _descriptionController.text.trim(),
      );
    }).toList();

    context.read<StaffServiceBloc>().add(
          AddMultipleStaffServicesRequested(
            staffUid: widget.staffUid,
            services: services,
          ),
        );
  }

  String servicesIdSuffix(String name) {
    return name.hashCode.abs().toString();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StaffServiceBloc, StaffServiceState>(
      listener: (context, state) {
        if (state is StaffServicesBatchSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${state.services.length} services are now registered.',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop();
        } else if (state is StaffServiceError) {
          setState(() {
            _saving = false;
            _errorMessage = state.message;
          });
        }
      },
      child: AlertDialog(
        backgroundColor: AppColors.surface,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 24,
        ),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.primary),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Add Services',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('1. Search a category'),
                const SizedBox(height: 8),
                TextField(
                  controller: _categoryController,
                  onSubmitted: (_) => _fetchSuggestions(),
                  style: const TextStyle(color: AppColors.textLight),
                  decoration: const InputDecoration(
                    hintText: 'e.g. AC, Plumbing, Electrical',
                    hintStyle: TextStyle(
                      color: AppColors.textLightSecondary,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        _loadingSuggestions ? null : _fetchSuggestions,
                    icon: _loadingSuggestions
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(
                      _loadingSuggestions
                          ? 'Loading suggestions...'
                          : 'Get AI Suggestions',
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _sectionTitle('2. Select services you offer'),
                if (_suggestions.isEmpty && !_loadingSuggestions)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Your suggestions will appear here.',
                      style: TextStyle(
                        color: AppColors.textLightSecondary,
                      ),
                    ),
                  ),
                ..._suggestions.map(
                  (service) => ServiceSuggestionTile(
                    serviceName: service,
                    selected: _selectedServices.contains(service),
                    onChanged: (selected) =>
                        _toggleService(service, selected),
                  ),
                ),
                const SizedBox(height: 16),
                _sectionTitle('3. Add custom services'),
                const SizedBox(height: 8),
                TextField(
                  controller: _customController,
                  minLines: 1,
                  maxLines: 3,
                  style: const TextStyle(color: AppColors.textLight),
                  decoration: const InputDecoration(
                    hintText:
                        'AC Filter Replacement, AC Duct Repair',
                    helperText:
                        'Separate multiple service names with commas or new lines.',
                    hintStyle: TextStyle(
                      color: AppColors.textLightSecondary,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                _sectionTitle('4. Description (optional)'),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  minLines: 1,
                  maxLines: 3,
                  style: const TextStyle(color: AppColors.textLight),
                  decoration: const InputDecoration(
                    hintText: 'Describe the services you provide',
                    hintStyle: TextStyle(
                      color: AppColors.textLightSecondary,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed:
                _saving ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: _saving ? null : _saveServices,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_rounded),
            label: Text(_saving ? 'Saving...' : 'Save Services'),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textLight,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
    );
  }
}