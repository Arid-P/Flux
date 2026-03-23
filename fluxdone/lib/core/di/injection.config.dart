// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/fluxfoxus_bridge/data/fluxfocus_bridge_service.dart'
    as _i234;
import '../../features/habits/data/habit_repository_impl.dart' as _i498;
import '../../features/habits/domain/i_habit_repository.dart' as _i527;
import '../../features/habits/presentation/bloc/habits_cubit.dart' as _i28;
import '../../features/lists/data/list_repository_impl.dart' as _i640;
import '../../features/lists/domain/i_list_repository.dart' as _i13;
import '../../features/lists/presentation/bloc/lists_cubit.dart' as _i450;
import '../../features/settings/data/preferences_repository.dart' as _i202;
import '../../features/settings/presentation/bloc/settings_cubit.dart' as _i819;
import '../../features/tasks/data/task_repository_impl.dart' as _i382;
import '../../features/tasks/domain/i_task_repository.dart' as _i878;
import '../../features/tasks/presentation/bloc/tasks_cubit.dart' as _i1063;
import '../database/database_helper.dart' as _i64;
import '../notifications/notification_service.dart' as _i229;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i64.DatabaseHelper>(() => _i64.DatabaseHelper());
    gh.lazySingleton<_i229.NotificationService>(
      () => _i229.NotificationService(),
    );
    gh.lazySingleton<_i234.FluxFocusBridgeService>(
      () => _i234.FluxFocusBridgeService(),
    );
    gh.lazySingleton<_i878.ITaskRepository>(
      () => _i382.TaskRepositoryImpl(
        gh<_i64.DatabaseHelper>(),
        gh<_i229.NotificationService>(),
        gh<_i234.FluxFocusBridgeService>(),
      ),
    );
    gh.lazySingleton<_i202.PreferencesRepository>(
      () => _i202.PreferencesRepository(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i13.IListRepository>(
      () => _i640.ListRepositoryImpl(gh<_i64.DatabaseHelper>()),
    );
    gh.lazySingleton<_i527.IHabitRepository>(
      () => _i498.HabitRepositoryImpl(gh<_i64.DatabaseHelper>()),
    );
    gh.factory<_i450.ListsCubit>(
      () => _i450.ListsCubit(gh<_i13.IListRepository>()),
    );
    gh.factory<_i819.SettingsCubit>(
      () => _i819.SettingsCubit(gh<_i202.PreferencesRepository>()),
    );
    gh.factory<_i1063.TasksCubit>(
      () => _i1063.TasksCubit(
        gh<_i878.ITaskRepository>(),
        gh<_i13.IListRepository>(),
      ),
    );
    gh.factory<_i28.HabitsCubit>(
      () => _i28.HabitsCubit(gh<_i527.IHabitRepository>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
