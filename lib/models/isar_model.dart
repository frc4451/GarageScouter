import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:robotz_garage_scouting/database/scouting.database.dart';
import 'package:robotz_garage_scouting/utils/notification_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kSelectedEventKey = "selectedEvent";

const String kDefaultEventName = "DEFAULT";

class IsarModel extends ChangeNotifier {
  final SharedPreferences prefs;
  final Isar isar;

  String _selectedEvent = kDefaultEventName;

  IsarModel(this.isar, this.prefs);

  void initialize() {
    _selectedEvent = prefs.getString(kSelectedEventKey) ?? kDefaultEventName;
  }

  String get selectedEvent => _selectedEvent;

  void setEvent(String event) {
    _selectedEvent = event;
    prefs.setString(kSelectedEventKey, _selectedEvent);
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
        .b64StringIsNotNull()
        .isDraftEqualTo(true)
        .sortByTimestampDesc()
        .watch(fireImmediately: true);
  }

  Stream<List<PitScoutingEntry>> _getPitScoutingData() async* {
    yield* isar.pitScoutingEntrys
        .filter()
        .b64StringIsNotNull()
        .isDraftEqualTo(false)
        .sortByTimestampDesc()
        .watch(fireImmediately: true);
  }

  Stream<List<MatchScoutingEntry>> _getMatchScoutingDrafts() async* {
    yield* isar.matchScoutingEntrys
        .filter()
        .b64StringIsNotNull()
        .isDraftEqualTo(true)
        .sortByTimestampDesc()
        .watch(fireImmediately: true);
  }

  Stream<List<MatchScoutingEntry>> _getMatchScoutingData() async* {
    yield* isar.matchScoutingEntrys
        .filter()
        .b64StringIsNotNull()
        .isDraftEqualTo(false)
        .sortByTimestampDesc()
        .watch(fireImmediately: true);
  }

  Stream<List<SuperScoutingEntry>> _getSuperScoutingDrafts() async* {
    yield* isar.superScoutingEntrys
        .filter()
        .b64StringIsNotNull()
        .isDraftEqualTo(true)
        .sortByTimestampDesc()
        .watch(fireImmediately: true);
  }

  Stream<List<SuperScoutingEntry>> _getSuperScoutingData() async* {
    yield* isar.superScoutingEntrys
        .filter()
        .b64StringIsNotNull()
        .isDraftEqualTo(false)
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

  /// Adds all entries without an event to the "default" event.
  ///
  /// This is more for debugging and should only be used if there are missing
  /// forms when debugging.
  Future<Event> putDefaultEvent() async {
    Event? defaultEvent =
        await isar.txn(() => isar.events.getByName(kDefaultEventName));

    if (defaultEvent == null) {
      defaultEvent = Event()
        ..name = kDefaultEventName
        ..description =
            "The DEFAULT event, unmarked entries are assumed DEFAULT.";
      await isar.writeTxn(() => isar.events.put(defaultEvent!));
    }

    List<PitScoutingEntry> pitScoutingEntriesWithoutEvent = await isar
        .txn(() => isar.pitScoutingEntrys.filter().eventIsNull().findAll());

    List<MatchScoutingEntry> matchScoutingEntriesWithoutEvent = await isar
        .txn(() => isar.matchScoutingEntrys.filter().eventIsNull().findAll());

    List<SuperScoutingEntry> superScoutingEntriesWithoutEvent = await isar
        .txn(() => isar.superScoutingEntrys.filter().eventIsNull().findAll());

    await isar.writeTxn(() async {
      for (final entry in pitScoutingEntriesWithoutEvent) {
        entry.event.value = defaultEvent;
      }
      isar.pitScoutingEntrys.putAll(pitScoutingEntriesWithoutEvent);

      for (final entry in matchScoutingEntriesWithoutEvent) {
        entry.event.value = defaultEvent;
      }
      isar.matchScoutingEntrys.putAll(matchScoutingEntriesWithoutEvent);

      for (final entry in superScoutingEntriesWithoutEvent) {
        entry.event.value = defaultEvent;
      }
      isar.superScoutingEntrys.putAll(superScoutingEntriesWithoutEvent);
    });

    return defaultEvent;
  }

  Future<bool> addEventByName(String name) async {
    Event? event = await isar.txn(() => isar.events.getByName(name));

    if (event != null) {
      return false;
    }

    Event? newEvent = Event()..name = name;

    isar.writeTxn(() => isar.events.put(newEvent));
    return true;
  }

  Future<int> putScoutingData(ScoutingDataEntry entry) async {
    entry.timestamp = DateTime.now().toUtc();

    if (entry is PitScoutingEntry) {
      return isar.writeTxn(() => isar.pitScoutingEntrys.put(entry));
    } else if (entry is MatchScoutingEntry) {
      return isar.writeTxn(() => isar.matchScoutingEntrys.put(entry));
    } else if (entry is SuperScoutingEntry) {
      return isar.writeTxn(() => isar.superScoutingEntrys.put(entry));
    }
    return -1;
  }

  Future<List<int>> putAllScoutingData(List<ScoutingDataEntry> entries) async {
    final timestamp = DateTime.now().toUtc();

    for (final entry in entries) {
      entry.timestamp = timestamp;
    }

    if (entries is List<PitScoutingEntry>) {
      return isar.writeTxn(() => isar.pitScoutingEntrys.putAll(entries));
    } else if (entries is List<MatchScoutingEntry>) {
      return isar.writeTxn(() => isar.matchScoutingEntrys.putAll(entries));
    } else if (entries is List<SuperScoutingEntry>) {
      return isar.writeTxn(() => isar.superScoutingEntrys.putAll(entries));
    }
    return [-1];
  }

  Future<Event> getCurrentEvent() async => getEventByName(_selectedEvent);

  Stream<Event?> getCurrentEventStream() async* {
    yield* isar.events.getByName(_selectedEvent).asStream();
  }

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
