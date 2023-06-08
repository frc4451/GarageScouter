import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:robotz_garage_scouting/database/scouting.database.dart';

class IsarModel extends ChangeNotifier {
  final Isar isar;

  IsarModel(this.isar);

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

  dynamic deletePitScoutingByIDs(List<int> ids) {
    return isar.writeTxn(() => isar.pitScoutingEntrys.deleteAll(ids));
  }

  dynamic deleteMatchScoutingByIDs(List<int> ids) {
    return isar.writeTxn(() => isar.matchScoutingEntrys.deleteAll(ids));
  }

  dynamic deleteSuperScoutingByIDs(List<int> ids) {
    return isar.writeTxn(() => isar.superScoutingEntrys.deleteAll(ids));
  }
}
