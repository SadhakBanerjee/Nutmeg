import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/services/supabase_service.dart';
import '../models/player_model.dart';

/// Repository pattern: Separates data access logic from business logic
/// All player database operations go through this class
class PlayerRepository {
  final SupabaseService _supabaseService = supabaseService;

  /// Fetch all players from database
  /// Returns list of Player objects, sorted by name
  Future<List<Player>> getAllPlayers() async {
    try {
      // Query Supabase: SELECT * FROM players ORDER BY name
      final response = await _supabaseService.client
          .from('players')
          .select()
          .order('name', ascending: true);

      // Convert JSON list to Player objects
      return (response as List).map((json) => Player.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error fetching players: $e');
      throw Exception('Failed to fetch players: $e');
    }
  }

  /// Get a single player by ID
  /// Returns null if player not found
  Future<Player?> getPlayerById(String playerId) async {
    try {
      // Query: SELECT * FROM players WHERE id = playerId LIMIT 1
      final response = await _supabaseService.client
          .from('players')
          .select()
          .eq('id', playerId)
          .single();

      return Player.fromJson(response);
    } catch (e) {
      print('❌ Error fetching player $playerId: $e');
      return null;
    }
  }

  /// Search players by name (case-insensitive)
  Future<List<Player>> searchPlayers(String query) async {
    try {
      final response = await _supabaseService.client
          .from('players')
          .select()
          .ilike('name', '%$query%')
          .order('name', ascending: true);

      return (response as List).map((json) => Player.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error searching players: $e');
      throw Exception('Failed to search players: $e');
    }
  }

  /// Get players by position
  Future<List<Player>> getPlayersByPosition(String position) async {
    try {
      final response = await _supabaseService.client
          .from('players')
          .select()
          .eq('position', position)
          .order('name', ascending: true);

      return (response as List).map((json) => Player.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error fetching players by position: $e');
      throw Exception('Failed to fetch players by position: $e');
    }
  }

  /// Create a new player
  Future<Player> createPlayer(Player player) async {
    try {
      final response = await _supabaseService.client
          .from('players')
          .insert(player.toInsertJson())
          .select()
          .single();

      print('✅ Player created: ${response['name']}');
      return Player.fromJson(response);
    } catch (e) {
      print('❌ Error creating player: $e');
      throw Exception('Failed to create player: $e');
    }
  }

  /// Update existing player
  Future<Player> updatePlayer(Player player) async {
    try {
      print('🔄 Updating player ID: ${player.id}');

      final response = await _supabaseService.client
          .from('players')
          .update({
            'name': player.name,
            'age': player.age,
            'height_cm': player.heightCm,
            'weight_kg': player.weightKg,
            'position': player.position,
          })
          .eq('id', player.id)
          .select(); // ← Remove .single() here

      // Check if any rows were returned
      if (response.isEmpty) {
        print('❌ No player found with ID: ${player.id}');
        throw Exception('Player not found in database');
      }

      print('✅ Player updated: ${response[0]['name']}');
      return Player.fromJson(response[0]); // Get first item from list
    } on PostgrestException catch (e) {
      print('❌ Database error: ${e.message} (${e.code})');
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      print('❌ Error updating player: $e');
      throw Exception('Failed to update player: $e');
    }
  }

  /// Delete a player by ID
  /// Also deletes all associated tests (if CASCADE is set in DB)
  Future<void> deletePlayer(String playerId) async {
    try {
      await _supabaseService.client.from('players').delete().eq('id', playerId);

      print('✅ Player deleted: $playerId');
    } catch (e) {
      print('❌ Error deleting player: $e');
      throw Exception('Failed to delete player: $e');
    }
  }

  /// Get total player count
  /// Useful for dashboard statistics
  Future<int> getPlayerCount() async {
    try {
      final response = await _supabaseService.client
          .from('players')
          .select('id')
          .count(CountOption.exact);

      return response.count ?? 0;
    } catch (e) {
      print('❌ Error counting players: $e');
      return 0;
    }
  }
}
