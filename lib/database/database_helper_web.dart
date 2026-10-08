import 'dart:convert';

import '../model/hotel.dart';
import '../model/reserva.dart';
import '../model/user.dart';
import 'hotel_data.dart';
import 'hotel_search.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const _usersKey = 'booking_clone_users';
  static const _reservationsKey = 'booking_clone_reservations';

  Future<List<Hotel>> getHotels({String search = ''}) async {
    return filtrarHoteles(initialHotels, search);
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
    final newId = users.isEmpty ? 1 : (users.last.id ?? 0) + 1;
    users.add(User.fromMap({...user.toMap(), 'id': newId}));
    await preferences.setStringList(
      _usersKey,
      users.map((savedUser) => jsonEncode(savedUser.toMap())).toList(),
    );
    return true;
  }

  Future<bool> updateUser(User user) async {
    if (user.id == null) return false;
    final preferences = await SharedPreferences.getInstance();
    final users = await _getUsers();
    if (users.any(
      (savedUser) =>
          savedUser.id != user.id &&
          savedUser.email == user.email.trim().toLowerCase(),
    )) {
      return false;
    }
    final indice = users.indexWhere((savedUser) => savedUser.id == user.id);
    if (indice == -1) return false;
    users[indice] = user;
    await preferences.setStringList(
      _usersKey,
      users.map((savedUser) => jsonEncode(savedUser.toMap())).toList(),
    );
    return true;
  }

  Future<int> addReservation(Reserva reservation) async {
    final preferences = await SharedPreferences.getInstance();
    final reservations = await _getReservations(preferences);
    final newId = reservations.isEmpty
        ? 1
        : (reservations.last.id ?? 0) + 1;
    reservations.add(Reserva.fromMap({...reservation.toMap(), 'id': newId}));
    await preferences.setStringList(
      _reservationsKey,
      reservations.map((item) => jsonEncode(item.toMap())).toList(),
    );
    return newId;
  }

  Future<List<Reserva>> _getReservations(
    SharedPreferences preferences,
  ) async {
    final saved = preferences.getStringList(_reservationsKey) ?? [];
    return saved.map((item) {
      return Reserva.fromMap(
        Map<String, Object?>.from(jsonDecode(item) as Map),
      );
    }).toList();
  }

  Future<List<Reserva>> getReservationsForUser(int userId) async {
    final preferences = await SharedPreferences.getInstance();
    final reservations = await _getReservations(preferences);
    return reservations.where((item) => item.usuarioId == userId).toList();
  }
}
