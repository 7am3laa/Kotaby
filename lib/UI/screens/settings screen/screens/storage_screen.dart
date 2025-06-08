import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotaby/UI/screens/settings%20screen/cubits/storage_cubit.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/ui_components/custom_app_bar.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';

class StorageScreen extends StatelessWidget {
  const StorageScreen({super.key});

  String formatSize(double sizeInMB) {
    if (sizeInMB >= 1024) {
      return '${(sizeInMB / 1024).toStringAsFixed(2)} GB';
    } else {
      return '${sizeInMB.toStringAsFixed(2)} MB';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width >= 500;

    return BlocProvider(
      create: (_) => StorageCubit(),
      child: Scaffold(
        appBar: const CustomAppBar(title: "Storage and Data"),
        backgroundColor: primaryColor,
        body: BlocBuilder<StorageCubit, StorageState>(
          builder: (context, state) {
            final cubit = context.read<StorageCubit>();
            final totalUsed =
                state.directorySpace.values.fold(0.0, (a, b) => a + b);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionTitle("Network Usage", isWideScreen),
                const SizedBox(height: 10),
                _buildInfoContainer([
                  _buildInfoRow("Network Type", state.networkType),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                      "Internet Usage", formatSize(state.internetUsage)),
                ]),
                const SizedBox(height: 30),
                _buildSectionTitle("Storage Information", isWideScreen),
                const SizedBox(height: 10),
                _buildInfoContainer([
                  _buildInfoRow("App Usage", formatSize(totalUsed)),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (state.totalDiskSpace > 0)
                        ? (totalUsed / state.totalDiskSpace).clamp(0.0, 1.0)
                        : 0,
                    backgroundColor: Colors.white24,
                    color: Colors.green,
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: CustomText(
                      text: (state.totalDiskSpace > 0)
                          ? "${((totalUsed / state.totalDiskSpace) * 100).toStringAsFixed(1)}% used"
                          : "Storage info unavailable",
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                      "Free Device Space", formatSize(state.freeDiskSpace)),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                      "Total Device Space", formatSize(state.totalDiskSpace)),
                ]),
                const SizedBox(height: 30),
                _buildSectionTitle("Auto-Download Settings", isWideScreen),
                const SizedBox(height: 10),
                _buildInfoContainer([
                  _buildSwitchItem(
                    "Auto-download Audio",
                    state.isAutoDownload,
                    (value) => cubit.toggleAutoDownload(value),
                  ),
                ]),
                const SizedBox(height: 30),
                _buildSectionTitle("Directory Usage", isWideScreen),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.directorySpace.length,
                  itemBuilder: (context, index) {
                    final dir = state.directorySpace.keys.elementAt(index);
                    final size = state.directorySpace[dir]!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CustomText(
                          text:
                              'Used in Kotaby ${dir.path.split("/files/").last}: ${formatSize(size)}',
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isWideScreen) {
    return CustomText(
      text: title,
      color: Colors.white,
      fontSize: isWideScreen ? 18 : 24,
      fontWeight: FontWeight.bold,
    );
  }

  Widget _buildInfoContainer(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: CustomText(
            text: title,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        CustomText(
          text: value,
          color: Colors.white70,
          fontSize: 14,
        ),
      ],
    );
  }

  Widget _buildSwitchItem(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: CustomText(
            text: title,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.green,
          inactiveThumbColor: Colors.red,
        ),
      ],
    );
  }
}
