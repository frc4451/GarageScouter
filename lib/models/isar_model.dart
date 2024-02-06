import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:garagescouter/database/scouting.database.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kSelectedEventKey = "selectedEvent";

const String kDefaultEventName = "DEFAULT";

class IsarModel extends ChangeNotifier {
  final SharedPreferences prefs;
  final Isar isar;

  String _selectedEvent = kDefaultEventName;

  String get selectedEvent => _selectedEvent;

  Event? _currentEvent;
  Event? get currentEvent => _currentEvent;

  IsarModel(this.isar, this.prefs);

  Future<void> initialize() async {
    // Link selected event from SharedPreferences
    _selectedEvent = prefs.getString(kSelectedEventKey) ?? kDefaultEventName;

    // Define a "current event" and put the default value if it doesn't exist.
    Event? currentEvent =
        await isar.writeTxn(() => isar.events.getByName(_selectedEvent));
    _currentEvent = currentEvent ?? await putDefaultEvent();
  }

  void setEvent(String event) async {
    _selectedEvent = event;
    prefs.setString(kSelectedEventKey, event);

    _currentEvent = await isar.writeTxn(() {
      return isar.events.getByName(_selectedEvent);
    });

    notifyListeners();
  }

  Stream<List<ScoutingDataEntry>> getScoutingDrafts(Type? type) {
    switch (type) {
      case PitScoutingEntry:
        return _getPitScoutingDrafts();
      case MatchScoutingEntry:
        return _getMatchScoutingDrafts();
      case SuperScoutingEntry:
        return _getSuperScoutingDrafts();
      default:
        return const Stream.empty();
    }
  }

  Stream<List<ScoutingDataEntry>> getScoutingData(Type? type) {
    switch (type) {
      case PitScoutingEntry:
        return _getPitScoutingData();
      case MatchScoutingEntry:
        return _getMatchScoutingData();
      case SuperScoutingEntry:
        return _getSuperScoutingData();
      default:
        return const Stream.empty();
    }
  }

  Stream<List<PitScoutingEntry>> _getPitScoutingDrafts() async* {
    yield* isar.pitScoutingEntrys
        .filter()
        .isDraftEqualTo(true)
        .event((q) => q.nameEqualTo(_selectedEvent))
        // .event((q) => q.nameIsNotEmpty())
        .sortByTimestampDesc()
        .watch(fireImmediately: true);
  }

  Stream<List<PitScoutingEntry>> _getPitScoutingData() async* {
    yield* isar.pitScoutingEntrys
        .filter()
        .isDraftEqualTo(false)
        // .event((q) => q.nameEqualTo(_selectedEvent))
        .sortByTimestampDesc()
        .watch(fireImmediately: true);
  }

  Stream<List<MatchScoutingEntry>> _getMatchScoutingDrafts() async* {
    yield* isar.matchScoutingEntrys
        .filter()
        .isDraftEqualTo(true)
        .event((q) => q.nameEqualTo(_currentEvent!.name))
        .sortByTimestampDesc()
        .watch(fireImmediately: true);
  }

  Stream<List<MatchScoutingEntry>> _getMatchScoutingData() async* {
    yield* isar.matchScoutingEntrys
        .filter()
        .isDraftEqualTo(false)
        .event((q) => q.nameEqualTo(_currentEvent!.name))
        .sortByTimestampDesc()
        .watch(fireImmediately: true);
  }

  Stream<List<SuperScoutingEntry>> _getSuperScoutingDrafts() async* {
    yield* isar.superScoutingEntrys
        .filter()
        .isDraftEqualTo(true)
        .event((q) => q.nameEqualTo(_selectedEvent))
        .sortByTimestampDesc()
        .watch(fireImmediately: true);
  }

  Stream<List<SuperScoutingEntry>> _getSuperScoutingData() async* {
    yield* isar.superScoutingEntrys
        .filter()
        .isDraftEqualTo(false)
        .event((q) => q.nameEqualTo(_selectedEvent))
        .sortByTimestampDesc()
        .watch(fireImmediately: true);
  }

  Stream<List<Event>> getEvents() async* {
    yield* isar.events
        .filter()
        .nameIsNotEmpty()
        .sortByName()
        .watch(fireImmediately: true);
  }

  Stream<Event?> getCurrentEventStream() async* {
    yield* isar.events.getByName(_currentEvent!.name).asStream();
  }

  Stream<List<Event>> getEventChanged() async* {
    yield* isar.events
        .filter()
        .nameEqualTo(_currentEvent!.name)
        .watch(fireImmediately: true);
  }

  /// Adds all entries without an event to the "default" event.
  ///
  /// This is more for debugging and should only be used if there are missing
  /// forms when debugging.
  Future<Event> putDefaultEvent() async {
    Event? maybeDefaultEvent =
        await isar.txn(() => isar.events.getByName(kDefaultEventName));

    if (maybeDefaultEvent == null) {
      int id = await isar.writeTxn(() => isar.events.put(Event()
        ..name = kDefaultEventName
        ..description =
            "The DEFAULT event, unmarked entries are assumed DEFAULT."));
      maybeDefaultEvent = await isar.txn(() => isar.events.get(id));
    }

    Event defaultEvent = maybeDefaultEvent!;

    List<PitScoutingEntry> pitScoutingEntriesWithoutEvent = await isar
        .txn(() => isar.pitScoutingEntrys.filter().eventIsNull().findAll());

    List<MatchScoutingEntry> matchScoutingEntriesWithoutEvent = await isar
        .txn(() => isar.matchScoutingEntrys.filter().eventIsNull().findAll());

    List<SuperScoutingEntry> superScoutingEntriesWithoutEvent = await isar
        .txn(() => isar.superScoutingEntrys.filter().eventIsNull().findAll());

    await isar.writeTxn(() async {
      for (final entry in pitScoutingEntriesWithoutEvent) {
        entry.event.value = defaultEvent;
        await entry.event.save();
      }
      isar.pitScoutingEntrys.putAll(pitScoutingEntriesWithoutEvent);

      for (final entry in matchScoutingEntriesWithoutEvent) {
        entry.event.value = defaultEvent;
        await entry.event.save();
      }
      isar.matchScoutingEntrys.putAll(matchScoutingEntriesWithoutEvent);

      for (final entry in superScoutingEntriesWithoutEvent) {
        entry.event.value = defaultEvent;
        await entry.event.save();
      }
      isar.superScoutingEntrys.putAll(superScoutingEntriesWithoutEvent);
    });

    return defaultEvent;
  }

  Future<bool> addEventByName(String name, {String? description}) async {
    Event? event = await isar.txn(() => isar.events.getByName(name));

    if (event != null) {
      return false;
    }

    Event? newEvent = Event()
      ..name = name
      ..description = description;

    isar.writeTxn(() => isar.events.put(newEvent));
    return true;
  }

  Future<int> putEvent(Event newEvent) {
    return isar.writeTxn(() => isar.events.put(newEvent));
  }

  Future<int> updateEvent(Event event) {
    return isar.writeTxn(() => isar.events.put(event));
  }

  Future<void> deleteEvent(Event event) {
    return isar.writeTxn(() {
      isar.pitScoutingEntrys
          .filter()
          .event((q) => q.idEqualTo(event.id))
          .deleteAll();
      isar.matchScoutingEntrys
          .filter()
          .event((q) => q.idEqualTo(event.id))
          .deleteAll();
      isar.superScoutingEntrys
          .filter()
          .event((q) => q.idEqualTo(event.id))
          .deleteAll();
      return isar.events.delete(event.id);
    });
  }

  Future<int> putScoutingData(ScoutingDataEntry entry) async {
    entry.timestamp = DateTime.now().toUtc();
    entry.event.value = _currentEvent;

    if (entry is PitScoutingEntry) {
      return isar.writeTxn(() async {
        int id = await isar.pitScoutingEntrys.put(entry);
        await entry.event.save();
        return id;
      });
    } else if (entry is MatchScoutingEntry) {
      return isar.writeTxn(() async {
        int id = await isar.matchScoutingEntrys.put(entry);
        await entry.event.save();
        return id;
      });
    } else if (entry is SuperScoutingEntry) {
      return isar.writeTxn(() async {
        int id = await isar.superScoutingEntrys.put(entry);
        await entry.event.save();
        return id;
      });
    }
    return -1;
  }

  Future<List<int>> putAllScoutingData(List<ScoutingDataEntry> entries) async {
    final timestamp = DateTime.now().toUtc();

    for (final entry in entries) {
      entry.timestamp = timestamp;
      entry.event.value = _currentEvent;
    }

    if (entries is List<PitScoutingEntry>) {
      return isar.writeTxn(() => isar.pitScoutingEntrys.putAll(entries));
    } else if (entries is List<MatchScoutingEntry>) {
      return isar.writeTxn(() async {
        List<int> ids = await isar.matchScoutingEntrys.putAll(entries);
        for (final element in entries) {
          await element.event.save();
        }
        return ids;
      });
    } else if (entries is List<SuperScoutingEntry>) {
      return isar.writeTxn(() => isar.superScoutingEntrys.putAll(entries));
    }
    return [-1];
  }

  Future<Event> getCurrentEvent() async => getEventByName(_selectedEvent);

  Future<Event> getEventByName(String name) async {
    Event? event = await isar.events.getByName(name);

    return event!;
  }

  Future<List<Event>> getAllEvents() async {
    List<Event> events = await isar.events.where().findAll();
    return events;
  }

  Future<PitScoutingEntry> getPitDataByUUID(String uuid) async {
    PitScoutingEntry? entry =
        await isar.txn(() => isar.pitScoutingEntrys.getByUuid(uuid));
    return entry ?? PitScoutingEntry();
  }

  Future<MatchScoutingEntry> getMatchDataByUUID(String uuid) async {
    MatchScoutingEntry? entry =
        await isar.txn(() => isar.matchScoutingEntrys.getByUuid(uuid));
    return entry ?? MatchScoutingEntry();
  }

  Future<SuperScoutingEntry> getSuperDataByUUID(String uuid) async {
    SuperScoutingEntry? entry =
        await isar.txn(() => isar.superScoutingEntrys.getByUuid(uuid));
    return entry ?? SuperScoutingEntry();
  }

  PitScoutingEntry getPitDataByUUIDSync(String uuid) {
    return isar.pitScoutingEntrys.getByUuidSync(uuid) ?? PitScoutingEntry();
  }

  MatchScoutingEntry getMatchDataByUUIDSync(String uuid) {
    return isar.matchScoutingEntrys.getByUuidSync(uuid) ?? MatchScoutingEntry();
  }

  SuperScoutingEntry getSuperDataByUUIDSync(String uuid) {
    return isar.superScoutingEntrys.getByUuidSync(uuid) ?? SuperScoutingEntry();
  }

  Future<bool> deletePitScoutingByID(int id) {
    return isar.writeTxn(() => isar.pitScoutingEntrys.delete(id));
  }

  Future<bool> deleteMatchScoutingByID(int id) {
    return isar.writeTxn(() => isar.matchScoutingEntrys.delete(id));
  }

  Future<bool> deleteSuperScoutingByID(int id) {
    return isar.writeTxn(() => isar.superScoutingEntrys.delete(id));
  }

  Future<int> deletePitScoutingByIDs(List<int> ids) {
    return isar.writeTxn(() => isar.pitScoutingEntrys.deleteAll(ids));
  }

  Future<int> deleteMatchScoutingByIDs(List<int> ids) {
    return isar.writeTxn(() => isar.matchScoutingEntrys.deleteAll(ids));
  }

  Future<int> deleteSuperScoutingByIDs(List<int> ids) {
    return isar.writeTxn(() => isar.superScoutingEntrys.deleteAll(ids));
  }
}
