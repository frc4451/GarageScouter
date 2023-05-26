import 'dart:io';

import 'package:collection/collection.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

/// Accepts a DataFrame (with a header) and converts it from a DataFrame object
/// to a String object that can be written with Dart's native IO package.
///
/// @param df - DataFrame that includes a header
///
/// @returns converted string using the CSV package
String convertDataFrameToString(DataFrame df) =>
    const ListToCsvConverter().convert([
      df.header.toList(growable: false),
      ...df.rows.map((e) => e.toList(growable: false)),
    ]);

/// Shorthand function for taking a FormBuilderState object and converting it
/// to a DataFrame to be used for analysis/organization.
///
/// @param state - FormBuilderState returned from _formBuilderKey
///
/// @returns DataFrame containing the form names as headers and the form values
/// as the row data.
DataFrame convertFormStateToDataFrame(FormBuilderState state) {
  Iterable<String> headers = state.fields.keys;
  Iterable<dynamic> row = headers.map((key) => state.value[key]);
  return DataFrame([headers, row]);
}

/// Helper function to print out the data from a dataframe. Useful for debugging
///
/// @param path - path to CSV
Future<DataFrame> listDataFromCSV(String path) async {
  final DataFrame csvdata = await fromCsv(path, headerExists: true);
  print("csv data shape :: ${csvdata.shape}");
  print("csv headers :: ${csvdata.header}");
  for (final element in csvdata.rows) {
    print("csv row data :: $element");
  }

  return csvdata;
}

/// Accepts a list of DataFrame objects and returns a list of unique headers
/// that can be assigned to a new DataFrame
List<String> joinDataFrameHeaders(List<DataFrame> dfs) {
  final List<String> headers = [];
  for (final element in dfs) {
    headers.addAll(element.header.toList());
  }
  return <String>{...headers}.toList();
}

bool hasMatchingHeaders(DataFrame df1, DataFrame df2) {
  return const DeepCollectionEquality()
      .equals(df1.header.toList(), df2.header.toList());
}

Future<List<FileSystemEntity>> convertDirectoryToListOfFiles(
    String directory) async {
  List<FileSystemEntity> files = await Directory(directory).list().toList();
  files.removeWhere((element) => p.extension(element.path) != ".csv");
  return files;
}

/// Accepts a directory of files, filters for CSV inputs, and joins any number
/// of DataFrames from the CSVs in the directory.
Future<DataFrame> joinDataFramesFromDirectory(String directory) async {
  List<FileSystemEntity> files = await convertDirectoryToListOfFiles(directory);
  // print("joinDataFramesFromDirectory :: ${files.length.toString()}")
  return await joinContentOfFilesToDataFrame(files);
}

Future<DataFrame> joinDataFramesFromListOfPaths(
    List<PlatformFile> paths) async {
  // List<FileSystemEntity> files =
  List<FileSystemEntity> files = paths.map((e) => File(e.path!)).toList();
  return await joinContentOfFilesToDataFrame(files);
}

/// This function attempts to make a "join" on DataFrames in a very crude way.
/// This assumes that all rows have the same headers. Eventually I'll find a way
/// to add Series to a dataframe and avoid most of the issues I've had with
/// joining DataFrame objects. I miss Pandas and Spark.
///
/// Because ml_dataframes does not have a native "join" method like Pandas,
/// we have to first join the list of headers from each DataFrame and form
/// a shared basis for the resulting DataFrame. From there, we can just append
/// new rows to the resultant DataFrame.
Future<DataFrame> joinContentOfFilesToDataFrame(
    List<FileSystemEntity> files) async {
  // Future can be used to collect results from an Iterable applied with a map
  // function, asychronously, to collect data from all CSV files.
  DataFrame finaldata = DataFrame([]);

  List<DataFrame> results = await Future.wait(files.map((e) async {
    DataFrame csvData = await fromCsv(e.path, headerExists: true);
    return csvData;
  }));

  // This is crude, and will not work when we scale up and change the data
  // between versions of CSVs. Please be wary of this and adjust when we get
  // to that point.
  for (final csvData in results) {
    if (finaldata.header.toList().isEmpty) {
      finaldata = csvData;
    } else {
      finaldata = DataFrame([
        finaldata.header.toList(),
        ...finaldata.rows.toList(),
        ...csvData.rows.toList(),
      ]);
    }

    //  else if (!hasMatchingHeaders(finaldata, csvData)) {
    //   List<String> newHeaders = joinDataFrameHeaders([finaldata, csvData]);
    //   List<String> missingColumns = newHeaders
    //       .where((element) => !finaldata.header.toList().contains(element))
    //       .toList();
    //   print("missing columns :: $missingColumns");

    //   missingColumns.forEach((missingColumn) {
    //     finaldata.addSeries(Series(missingColumn,
    //         List<dynamic>.filled(finaldata.rows.length, "null")));
    //   });
    //   // finaldata = DataFrame(
    //   //     [newHeaders, ...finaldata.rows.toList(), ...csvData.rows.toList()]);
    // }
  }

  return finaldata;
}
