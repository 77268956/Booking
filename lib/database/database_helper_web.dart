import 'dart:convert';

import '../model/hotel.dart';
import '../model/user.dart';
import 'hotel_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const _usersKey = 'booking_clone_users';

  Future<List<Hotel>> getHotels({String search = ''}) async {
    final value = search.trim().toLowerCase();
    if (value.isEmpty) return initialHotels;
    return initialHotels
        .where(
          (hotel) => '${hotel.nombre} ${hotel.ubicacion}'
              .toLowerCase()
              .contains(value),
        )
        .toList();
  }

  Future<List<User>> _getUsers() async {
    final preferences = await SharedPreferences.getInstance();
    final savedUsers = preferences.getStringList(_usersKey);
    if (savedUsers == null) {
      return _resetUsers(preferences);
    }
    try {
      return savedUsers
          .map(
            (user) => User.fromMap(
              Map<String, Object?>.from(jsonDecode(user) as Map),
            ),
          )
          .toList();
    } catch (_) {
      return _resetUsers(preferences);
    }
  }

  Future<List<User>> _resetUsers(SharedPreferences preferences) async {
    final users = initialUsers.toList();
    await preferences.setStringList(
      _usersKey,
      users.map((user) => jsonEncode(user.toMap())).toList(),
    );
    return users;
  }

  Future<User?> getUserByEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    final users = await _getUsers();
    for (final user in users) {
      if (user.email == normalizedEmail) return user;
    }
    return null;
  }

  Future<bool> addUser(User user) async {
    final preferences = await SharedPreferences.getInstance();
    final users = await _getUsers();
    if (users.any(
      (savedUser) => savedUser.email == user.email.trim().toLowerCase(),
    )) {
      return false;
    }
    users.add(User.fromMap(user.toMap()));
    await preferences.setStringList(
      _usersKey,
      users.map((savedUser) => jsonEncode(savedUser.toMap())).toList(),
    );
    return true;
  }
}
