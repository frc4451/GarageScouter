import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:robotz_garage_scouting/constants/platform_check.dart';
import 'package:robotz_garage_scouting/utils/dataframe_helpers.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sanitize_filename/sanitize_filename.dart';

/// Helper method to get the extension of a file
String getExtension(File file) => p.extension(file.path);

/// Helper method to get the basename of a file
String getBaseName(File file) => p.basename(file.path);

/// Used as a a way to generate unique file paths for files we want to manage
/// or move within/outside of the application.
///
/// By default it will use `ApplicationSupportDirectory` as the base path. This
/// is typically where Application data that isn't stored between phone boots.
/// If you plan to have the file accessible outside of the app (IE the downloads
/// folder, then please use FilePicker to save the file to a new location.)
///
/// The FilePath returned is OS agnostic and will include the correct file
/// delimeter. IE use `\` for Windows, and `/` for everything else.
///
/// @param extension - The file extension we plan to use IE `.csv`
///
/// @param prefix - Optional string prefix we want to have on the filename
Future<String> generateUniqueFilePath(
    {required String extension,
    String? prefix = "",
    String? timestamp,
    bool? prefixIsFileName = false}) async {
  // Extensions need to start with "." to be recognized correctly. We want to
  // accept both "csv" and ".csv" and not blame the developer.
  if (!extension.startsWith(".")) {
    extension = ".$extension";
  }

  final String currentTime = timestamp ?? DateTime.now().toString();
  final String filePrefix = prefix!.isNotEmpty ? "${prefix}_" : "";
  final String directory = (await getApplicationSupportDirectory()).path;

  // We check if the file prefix is the name of the file. This is a workaround
  // for how we handle file saving on the import manager.
  final String filename = prefixIsFileName != null && prefixIsFileName
      ? prefix
      : "$filePrefix$currentTime$extension";

  // We use sanitizeFilename because specific OS's have specific characters
  // that they don't like. This just helps us avoid edge cases. And then use
  // the setExtension to force the extension to apply
  return p.setExtension(
      p.join(directory, sanitizeFilename(filename, replacement: "_")),
      extension);
}

/// Opens the File Explorer Dialog for Desktop applications and returns
/// either an absolute path to the desired location or a null value indicating
/// that the user aborted the operation. Will open Downloads folder.
///
/// @param File - file that we want to save (used for the initial file name)
///
/// @returns Future<String?> representing async nullable String for file path
Future<String?> getNewFilePath(File file) async {
  return FilePicker.platform.saveFile(
      dialogTitle: "Select where you want to save the file",
      fileName: p.basename(file.path),
      initialDirectory: (await getDownloadsDirectory())!.path,
      type: FileType.custom,
      allowedExtensions: ["csv"]);
}

/// Checks if the newFilePath is null, if not, returns a Future<File>
/// where the developer can listen for where the new file lives
///
/// @param file - File we want to copy
/// @param newFilePath - New file path (probably from getNewFilePath)
///
/// @returns Future<File> representing the file at the final location
Future<File> copyFileToNewPath(File file, String? newFilePath,
    {String extension = ".csv"}) async {
  if (newFilePath == null) {
    throw Exception("User cancelled operation");
  }

  return file.copy(p.setExtension(newFilePath, extension));
}

/// Utilizes the file_picker and path packages to open the file dialogs for
/// desktop applications to be able to copy the output file to a new location.
/// It will start at the Downloads folder for ease of access for users.
///
/// This was broken into two steps because of weird logic on the import page.
///
/// @param file - final written file
///
/// @returns final file location (IE downloads folder)
Future<File> saveFilesForDesktopApplication(File file) async {
  final String? newFilePath = await getNewFilePath(file);
  return await copyFileToNewPath(file, newFilePath);
}

/// Because of the shenanigans of file_picker, we have to resort to _another_
/// library where we pick files, except this one is only for iOS/Android.
///
/// @param finalFile - file that we want to save
///
/// @returns resulting File from final file path
Future<File> saveFilesForMobileApplication(File finalFile) async {
  final DirectoryLocation? pickedDirectory =
      await FlutterFileDialog.pickDirectory();

  if (pickedDirectory == null) {
    throw Exception("User cancelled operation");
  }
  final String? newFilePath = await FlutterFileDialog.saveFileToDirectory(
      directory: pickedDirectory,
      data: finalFile.readAsBytesSync(),
      fileName: p.basename(finalFile.path),
      mimeType: "text");

  if (newFilePath == null) {
    throw Exception("User cancelled operation");
  }

  return File(newFilePath);
}

/// "Agnostic" way of saving files to the device without looking for which
/// platform we're using to begin with. This could probably be made more
/// straight forward in the future
Future<File> saveFileToDevice(File file) async {
  if (isDesktopPlatform()) {
    return saveFilesForDesktopApplication(file);
  } else if (isMobilePlatform()) {
    return saveFilesForMobileApplication(file);
  } else {
    throw Exception("Platform not supported yet");
  }
}

/// Shorthand function to create a CSV from a DataFrame
///
/// @param df - DataFrame we want to write
///
/// @returns File object refernce for where the file ultimately was written
Future<File> createCSVFromDataFrame(DataFrame df,
    {String? prefix = "default", bool? prefixIsFileName}) async {
  return File((await generateUniqueFilePath(
          extension: ".csv",
          prefix: prefix,
          prefixIsFileName: prefixIsFileName)))
      .writeAsString(convertDataFrameToString(df));
}

Future<FilePickerResult?> selectCSVFiles(
    {bool allowMultiple = true,
    List<String> allowedExtensions = const ["csv"]}) async {
  return FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: allowMultiple,
      onFileLoading: (FilePickerStatus status) => print(status),
      allowedExtensions: allowedExtensions);
}
