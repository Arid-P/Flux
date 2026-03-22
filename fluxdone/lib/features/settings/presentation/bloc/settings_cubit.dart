import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:fluxdone/features/settings/data/preferences_repository.dart';

class SettingsState extends Equatable {
  final bool notificationsEnabled;
  final int defaultReminderOffset;
  final String notificationSound;
  final bool googleCalendarConnected;

  const SettingsState({
    required this.notificationsEnabled,
    required this.defaultReminderOffset,
    required this.notificationSound,
    required this.googleCalendarConnected,
  });

  SettingsState copyWith({
    bool? notificationsEnabled,
    int? defaultReminderOffset,
    String? notificationSound,
    bool? googleCalendarConnected,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultReminderOffset: defaultReminderOffset ?? this.defaultReminderOffset,
      notificationSound: notificationSound ?? this.notificationSound,
      googleCalendarConnected: googleCalendarConnected ?? this.googleCalendarConnected,
    );
  }

  @override
  List<Object?> get props => [
        notificationsEnabled,
        defaultReminderOffset,
        notificationSound,
        googleCalendarConnected,
      ];
}


@injectable
class SettingsCubit extends Cubit<SettingsState> {
  final PreferencesRepository _prefsRepo;

  SettingsCubit(this._prefsRepo)
      : super(SettingsState(
          notificationsEnabled: _prefsRepo.areNotificationsEnabled(),
          defaultReminderOffset: _prefsRepo.getDefaultReminderOffset(),
          notificationSound: _prefsRepo.getNotificationSound(),
          googleCalendarConnected: _prefsRepo.isGoogleCalendarConnected(),
        ));

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefsRepo.setNotificationsEnabled(enabled);
    emit(state.copyWith(notificationsEnabled: enabled));
  }

  Future<void> setDefaultReminderOffset(int offset) async {
    await _prefsRepo.setDefaultReminderOffset(offset);
    emit(state.copyWith(defaultReminderOffset: offset));
  }

  Future<void> setNotificationSound(String sound) async {
    await _prefsRepo.setNotificationSound(sound);
    emit(state.copyWith(notificationSound: sound));
  }

  Future<void> setGoogleCalendarConnected(bool connected) async {
    await _prefsRepo.setGoogleCalendarConnected(connected);
    emit(state.copyWith(googleCalendarConnected: connected));
  }
}
