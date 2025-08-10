import 'package:flow_ai/models/user_preferences.dart';

abstract class AppState {}

class AppInitial extends AppState {}

class AppLoading extends AppState {}

class AppLoaded extends AppState {
  final UserPreferences preferences;
  AppLoaded(this.preferences);
}

class AppError extends AppState {
  final String message;
  AppError(this.message);
}
