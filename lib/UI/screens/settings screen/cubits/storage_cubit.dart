import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:disk_space_update/disk_space_update.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotaby/storage.dart';
import 'package:path_provider/path_provider.dart';

class StorageCubit extends Cubit<StorageState> {
  StorageCubit()
      : super(StorageState(
          freeDiskSpace: 0,
          totalDiskSpace: 0,
          directorySpace: {},
          networkType: 'Unknown',
          isAutoDownload: Storage.isAutoDownload,
          internetUsage: 0.0,
        )) {
    initDiskSpace();
    getNetworkType();
  }

  Future<void> initDiskSpace() async {
    try {
      double? free = await DiskSpace.getFreeDiskSpace ?? 0;
      double? total = await DiskSpace.getTotalDiskSpace ?? 0;

      List<Directory> directories = [];
      if (Platform.isIOS) {
        directories = [await getApplicationDocumentsDirectory()];
      } else if (Platform.isAndroid) {
        final Directory root = await getExternalStorageDirectory() ??
            await getApplicationDocumentsDirectory();
        directories = root.listSync().whereType<Directory>().toList();
      }

      Map<Directory, double> dirSpace = {};
      for (var dir in directories) {
        final size = await _getDirectorySize(dir);
        dirSpace[dir] = size / (1024 * 1024); // to MB
      }

      emit(state.copyWith(
        freeDiskSpace: free,
        totalDiskSpace: total,
        directorySpace: dirSpace,
      ));
    } catch (e) {
      debugPrint('initDiskSpace error: $e');
    }
  }

  Future<void> getNetworkType() async {
    try {
      final result = await Connectivity().checkConnectivity();
      String type = switch (result[0]) {
        ConnectivityResult.wifi => 'Wi-Fi',
        ConnectivityResult.mobile => 'Mobile Data',
        _ => 'No Network',
      };
      emit(state.copyWith(networkType: type));
    } catch (e) {
      debugPrint('getNetworkType error: $e');
    }
  }

  void toggleAutoDownload(bool value) {
    Storage.isAutoDownload = value;
    emit(state.copyWith(isAutoDownload: value));
  }

  Future<int> _getDirectorySize(Directory dir) async {
    int size = 0;
    try {
      final files = dir.listSync(recursive: true);
      for (final entity in files) {
        if (entity is File) {
          size += entity.lengthSync();
        }
      }
    } catch (e) {
      debugPrint('Directory size error: $e');
    }
    return size;
  }

  void updateInternetUsage(double bytes) {
    final currentUsage = state.internetUsage;
    final newUsage = currentUsage + (bytes / (1024 * 1024));
    emit(state.copyWith(internetUsage: newUsage));
  }

  void resetInternetUsage() {
    emit(state.copyWith(internetUsage: 0.0));
  }
}

class StorageState {
  final double freeDiskSpace;
  final double totalDiskSpace;
  final Map<Directory, double> directorySpace;
  final String networkType;
  final bool isAutoDownload;
  final double internetUsage;

  StorageState({
    required this.freeDiskSpace,
    required this.totalDiskSpace,
    required this.directorySpace,
    required this.networkType,
    required this.isAutoDownload,
    required this.internetUsage,
  });

  double get usedStorageMB =>
      directorySpace.values.fold(0, (sum, value) => sum + value);

  StorageState copyWith({
    double? freeDiskSpace,
    double? totalDiskSpace,
    Map<Directory, double>? directorySpace,
    String? networkType,
    bool? isAutoDownload,
    double? internetUsage,
  }) {
    return StorageState(
      freeDiskSpace: freeDiskSpace ?? this.freeDiskSpace,
      totalDiskSpace: totalDiskSpace ?? this.totalDiskSpace,
      directorySpace: directorySpace ?? this.directorySpace,
      networkType: networkType ?? this.networkType,
      isAutoDownload: isAutoDownload ?? this.isAutoDownload,
      internetUsage: internetUsage ?? this.internetUsage,
    );
  }
}
