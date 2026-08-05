import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/saved_place.dart';
import '../providers/saved_places_provider.dart';

class PlacesSection extends ConsumerWidget {
  const PlacesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placesAsync = ref.watch(savedPlacesNotifierProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(
        children: [
          Material(
            color: AppColors.surface,
            child: InkWell(
              onTap: () => _showAddPlaceSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.divider),
                    bottom: BorderSide(color: AppColors.divider),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.location_on_outlined),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Мои места',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Привяжи зал, работу или точку фокуса',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.add),
                  ],
                ),
              ),
            ),
          ),
          placesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 18),
              child: LinearProgressIndicator(
                minHeight: 2,
                color: AppColors.textPrimary,
                backgroundColor: AppColors.divider,
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (places) => Column(
              children: [
                for (final place in places)
                  _SavedPlaceRow(
                    place: place,
                    onDelete: () => ref
                        .read(savedPlacesNotifierProvider.notifier)
                        .removePlace(place.id),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddPlaceSheet(BuildContext context) async {
    var selectedType = SavedPlaceType.training;
    final nameController =
        TextEditingController(text: selectedType.defaultName);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            10,
            20,
            MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: _SheetHandle()),
              const SizedBox(height: 22),
              const Text(
                'Сохранить это место',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 7),
              const Text(
                'LEVL запомнит точку только на этом устройстве.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final type in SavedPlaceType.values)
                    _PlaceTypeButton(
                      type: type,
                      selected: selectedType == type,
                      onTap: () {
                        setSheetState(() => selectedType = type);
                        nameController.text = type.defaultName;
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                maxLength: 40,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Название',
                  counterText: '',
                  prefixIcon: Icon(Icons.edit_outlined),
                ),
              ),
              const SizedBox(height: 18),
              Consumer(
                builder: (context, ref, _) => _SavePlaceButton(
                  isSaving: ref.watch(savedPlacesNotifierProvider).isLoading,
                  onSave: () async {
                    final error = await ref
                        .read(savedPlacesNotifierProvider.notifier)
                        .saveCurrentPlace(
                          type: selectedType,
                          name: nameController.text,
                        );
                    if (!sheetContext.mounted) return;
                    if (error == null) {
                      Navigator.of(sheetContext).pop();
                    } else {
                      ScaffoldMessenger.of(sheetContext)
                          .showSnackBar(SnackBar(content: Text(error)));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    nameController.dispose();
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) => Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(2),
        ),
      );
}

class _SavePlaceButton extends StatelessWidget {
  const _SavePlaceButton({required this.isSaving, required this.onSave});

  final bool isSaving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton.icon(
          onPressed: isSaving ? null : onSave,
          icon: isSaving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.surface,
                  ),
                )
              : const Icon(Icons.my_location),
          label: Text(isSaving ? 'Определяю точку' : 'Сохранить точку'),
        ),
      );
}

class _PlaceTypeButton extends StatelessWidget {
  const _PlaceTypeButton({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final SavedPlaceType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 78,
          height: 66,
          decoration: BoxDecoration(
            color: selected ? AppColors.textPrimary : AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AppColors.textPrimary : AppColors.divider,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                type.icon,
                size: 20,
                color: selected ? AppColors.surface : type.color,
              ),
              const SizedBox(height: 6),
              Text(
                type.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.surface : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
}

class _SavedPlaceRow extends StatelessWidget {
  const _SavedPlaceRow({required this.place, required this.onDelete});

  final SavedPlaceLocal place;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Container(
        height: 58,
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            Icon(place.type.icon, size: 19, color: place.type.color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${place.type.label} · радиус ${place.radiusMeters} м',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Удалить место',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, size: 19),
              color: AppColors.textSecondary,
            ),
          ],
        ),
      );
}
