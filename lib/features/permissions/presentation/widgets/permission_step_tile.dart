import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neumorphic.dart';
import '../../domain/entities/permission_type.dart';
import 'permission_disclosure_bottom_sheet.dart';

class PermissionStepTile extends StatelessWidget {
  final PermissionType permissionType;
  final bool isGranted;
  final VoidCallback onRequest;
  final VoidCallback onOpenAppSettings;
  final String? title;
  final String? description;
  final IconData? icon;

  const PermissionStepTile({
    super.key,
    required this.permissionType,
    required this.isGranted,
    required this.onRequest,
    required this.onOpenAppSettings,
    this.title,
    this.description,
    this.icon,
  });

  void _showDisclosure(BuildContext context) {
    PermissionDisclosureBottomSheet.show(
      context: context,
      permissionType: permissionType,
      isGranted: isGranted,
      onAgree: onRequest,
      onOpenAppSettings: onOpenAppSettings,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTitle = title ?? permissionType.title;
    final effectiveDescription = description ?? permissionType.shortDescription;
    final effectiveIcon = icon ?? permissionType.icon;

    return Container(
      decoration: NeuTheme.extrudedDecoration(
        borderRadius: 20,
        distance: 4,
        glowColor: isGranted ? AppTheme.accentGreen : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showDisclosure(context),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: NeuTheme.stampedDecoration(
                        borderRadius: 14,
                        base: isGranted
                            ? AppTheme.accentGreen.withValues(alpha: 0.12)
                            : AppTheme.primaryTeal.withValues(alpha: 0.10),
                      ),
                      child: Icon(
                        effectiveIcon,
                        color: isGranted ? AppTheme.accentGreen : AppTheme.primaryTeal,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            effectiveTitle,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            permissionType.badgeLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'monospace',
                              color: isGranted ? AppTheme.accentGreen : Colors.white38,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isGranted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: NeuTheme.stampedDecoration(
                          borderRadius: 12,
                          base: AppTheme.accentGreen.withValues(alpha: 0.12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded,
                                color: AppTheme.accentGreen, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Active',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentGreen,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryTeal,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _showDisclosure(context),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Review & Enable',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Colors.black),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  effectiveDescription,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 12,
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tap to view Google Play disclosure & privacy details',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
