import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotaby/core/models/users_model.dart';
import 'package:kotaby/core/services/user_auth_services.dart';
import 'package:kotaby/storage.dart';

class Top10Cubit extends Cubit<Top10State> {
  final UserAuthServices _authServices = UserAuthServices();
  Top10Cubit() : super(Top10Initial());

  void loadUsers() async {
    if (isClosed) return;
    emit(Top10Loading());

    try {
      final users = await _authServices.getUsers();
      if (isClosed) return;

      if (users.isNotEmpty) {
        emit(Top10Loaded(users));
      } else {
        emit(Top10Empty());
      }
    } catch (e) {
      if (!isClosed) emit(Top10Error());
    }
  }

  Color getTextColor(int index) {
    if (index == 0 || index == 1) return Colors.black;
    if (index == 2) return Colors.white;
    return Storage.themeState == 1 ? Colors.white : Colors.black;
  }

  Color getSubTextColor(int index) {
    if (index == 0 || index == 1) return Colors.black.withOpacity(0.5);
    if (index == 2) return Colors.white.withOpacity(0.5);
    return Storage.themeState == 1
        ? Colors.white.withOpacity(0.5)
        : Colors.black.withOpacity(0.5);
  }
}

// States
abstract class Top10State {}

class Top10Initial extends Top10State {}

class Top10Loaded extends Top10State {
  final List<UsersModel> users;
  Top10Loaded(this.users);
}

class Top10Error extends Top10State {}

class Top10Loading extends Top10State {}

class Top10Empty extends Top10State {}
