import 'dart:convert';
import '../../../core/services/local_storage_service.dart';
import '../models/agent_memory.dart';

abstract class FitnessMemoryService {
  List<AgentMemory> getAllMemories();
  Future<void> remember(AgentMemory memory);
  List<AgentMemory> retrieveRelevantMemory(String categoryOrKeyword);
  Future<void> updateMemory(String id, String newValue);
  Future<void> forgetMemory(String id);
  String summarizeMemory();
}

class LocalFitnessMemoryService implements FitnessMemoryService {
  static const String _keyAgentMemories = 'fe_agent_memories_list';

  final LocalStorageService _storage;

  LocalFitnessMemoryService(this._storage);

  @override
  List<AgentMemory> getAllMemories() {
    final data = _storage.getString(_keyAgentMemories);
    if (data != null && data.isNotEmpty) {
      try {
        final List<dynamic> jsonList = json.decode(data) as List<dynamic>;
        return jsonList
            .map((e) => AgentMemory.fromMap(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    return [];
  }

  @override
  Future<void> remember(AgentMemory memory) async {
    final memories = getAllMemories();
    // Prevent duplicates for same value
    memories.removeWhere((m) => m.category == memory.category && m.value == memory.value);
    memories.add(memory);
    await _save(memories);
  }

  @override
  List<AgentMemory> retrieveRelevantMemory(String categoryOrKeyword) {
    final lower = categoryOrKeyword.toLowerCase();
    return getAllMemories().where((m) {
      return m.category.toLowerCase().contains(lower) ||
          m.value.toLowerCase().contains(lower);
    }).toList();
  }

  @override
  Future<void> updateMemory(String id, String newValue) async {
    final memories = getAllMemories();
    final index = memories.indexWhere((m) => m.id == id);
    if (index != -1) {
      memories[index] = AgentMemory(
        id: memories[index].id,
        category: memories[index].category,
        value: newValue,
        confidence: memories[index].confidence,
        source: memories[index].source,
        createdAt: DateTime.now(),
      );
      await _save(memories);
    }
  }

  @override
  Future<void> forgetMemory(String id) async {
    final memories = getAllMemories();
    memories.removeWhere((m) => m.id == id);
    await _save(memories);
  }

  @override
  String summarizeMemory() {
    final memories = getAllMemories();
    if (memories.isEmpty) return 'No personalized agent memories stored yet.';

    return memories.map((m) => '${m.category}: ${m.value}').join(' • ');
  }

  Future<void> _save(List<AgentMemory> memories) async {
    final jsonStr = json.encode(memories.map((e) => e.toMap()).toList());
    await _storage.setString(_keyAgentMemories, jsonStr);
  }
}
