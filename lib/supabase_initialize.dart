import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: 'https://mesxkddjgnmmlwsxzxgo.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1lc3hrZGRqZ25tbWx3c3h6eGdvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ3NTgzODQsImV4cCI6MjA3MDMzNDM4NH0.sitPOrrlf6KiIuSDjwz4wezrkm2nR65_Mts4op5Os-c',
  );
}
