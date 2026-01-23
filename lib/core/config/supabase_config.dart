import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://vqanbxitfgsyajnhfgaf.supabase.co';
  static const String anonKey = 'sb_publishable_z9nYXjEd9k6f7qxKE_w_IA_iVt-v7Rc';

  static SupabaseClient get client => Supabase.instance.client;
}
