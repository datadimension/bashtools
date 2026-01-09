<?php

namespace App\Http\Controllers;

use App\DD_laravelAp\Controllers\API\google\Gdrive_c;
use App\DD_laravelAp\Controllers\API\google\Gphotos_c;
use App\DD_laravelAp\Controllers\BaseCron_c;
use App\DD_laravelAp\Helpers\CacheHandler;
use App\DD_laravelAp\Helpers\DataB;
use App\DD_laravelAp\Helpers\Date_Time;
use App\DD_laravelAp\Helpers\File_Ops;
use App\DD_laravelAp\Helpers\Image;
use App\DD_laravelAp\Helpers\SFTPHandler;
use Illuminate\Support\Facades\Auth;
use Log;


class Cron_c extends BaseCron_c {

      private $uploadSuccessDir = "/private/storage_download";
      private $storageDownloadFailDir = "/private/storage_download_fail";

      //x20240306_private $_drivephotoprocessqueue = "1t6beba9rAhgXuemmF2gl9DRkyux8E0uA";
      //x20240306_private $_drive_serveroutbox_photos = "1Ju1wrut1M8_c5v5odZ-eCsSQVLzPk8el";
      //x20240306_private $_drive_serveroutbox_videos = "1p_nKzG8-yxuIKqCsMr1jkzpK7LCkH-0Z";
      //x20240306_private $_drive_serveroutbox_json = "1MpfDhY6j3tPbqeLdZElx0IUQWfzvuYsv";
      //x20240306_private $_drive_serveroutbox_exif = "1j_fXIInWyuCSWPfgiehhPQHm5onFioaB";
      //x20240306_private x20240306_$_drive_serveroutbox_nonmedia = "1igLidI1ssGRNqd2OSvz6MxUgJrqX-glP";
      //x20240306_private $_temp_photos_dir = "/private/downloads/temp/gdrive_download_photos";
      //x20240306_private $_temp_videos_dir = "/private/downloads/temp/gdrive_download_videos";
      //x20240306_private $_gdrive_takeout = "/private/gdrive_temp";

      /**
       * transfer photos that have been uploaded to storage server
       * @param $task
       * @return void
       */
      protected function storage_download($task) {
	    $msg = "storage_download";

	    $limit = $task["limit"];//local variable as different process might take longer, so we can for example half the limit where it takes longer
	    $sftp = new SFTPHandler("liveinfo247.com", "datadimension", "/_local/keys/ovh-live.ppk");
	    $cloudstoredir = $sftp->getCloudStoreDir();
	    $diritems = $sftp->sftp_listDirectoryItems("/var/www/html/liveinfo247.com" . $this->uploadSuccessDir);
	    $processed_items = 0;
	    $dir_index = 0;
	    $limit = $task["limit"];//local variable as different process might take longer, so we can for example half the limit where it takes longer
	    // $limit = 1;//debug
	    while ($dir_index < count($diritems) && $processed_items < $limit) {
		  $file = $diritems[$dir_index];
		  $UUID = $file["filename"];//we already changedf file names to UUID in case they have the same textual name
		  $DB_file_record = DataB::selectSingleRow("_photolibrary", ["UUID" => $UUID]);
		  if ($DB_file_record == null) {//if filename does not have extension
			throw new \Exception("no db record in _photolibrary for " . $UUID);
		  }
		  $localfilename = $file["filename"];
		  if ($file["type"] === null) {
			//cross check files against database and if so download them otherwise reject them
			$ext = File_Ops::getFileExtension($DB_file_record["filename"]);
			$localfilename .= "." . $ext;
		  }
		  $success = $sftp->download($file["filename"], $file["directory"], $cloudstoredir, ["rename" => $localfilename]);
		  if ($success) {
			$processed_items++;
			$msg .= $localfilename . ", ";
		  }
		  $dir_index++;
		  ///var/www/html/liveinfo247.com/private/storage_download
	    }
	    return ["resultcount" => $processed_items, "msg" => "Result: " . $msg];

      }

      /**
       * sorts files from device uploads in gphoto_upload
       * @param $task
       * @return void
       */
      protected function device_upload_sort($task) {
	    $msg = "device_upload_sort";
	    $sourcedirs = ["/private/device_upload/Samsung SM-S908B/Camera", "/private/device_upload/misc_ftp"];
	    $processed_items = 0;
	    $dir_index = 0;
	    $limit = $task["limit"];//local variable as different process might take longer, so we can for example half the limit where it takes longer
	    while ($dir_index < count($sourcedirs) && $processed_items < $limit) {
		  $diritems = File_Ops::listDirectoryItems($sourcedirs[$dir_index]);
		  foreach ($diritems as $item) {
			if ($item["is_writable"]) {
			      File_Ops::moveItemFromTo($item["filename"], $item["directory"], Gphotos_c::$_g_upload_dir);
			      $msg .= Gphotos_c::$_g_upload_dir . "/" . $item["filename"] . ",";
			}
			else {
			      $msg .= " camnot move " . $item["filename"] . " - not permitted.";
			}
			$processed_items++;
		  }
		  $dir_index++;
	    }
	    return ["resultcount" => $processed_items, "msg" => "Processed: " . $msg];
      }

      /**
       * upload photos to google, get a UUID for them, add entry to database
       *
       * testing:
       * the same image is not  duplicated if uploaded twice, instead google returns the existing UUID if a duplicate is detected
       *  google allows duplicate filenames - add the UUID to the filename (as orig is stored in database) ?
       *
       * what to do when its editted on gphotos when its uploaded via app can we detect this and download the changed version
       */
      protected function gphoto_upload($task) {
	    $gphotos = new Gphotos_c();
	    $gphotos->setUploadSuccessDir($this->uploadSuccessDir);
	    $msg = "gphoto upload";
	    $limit = $task["limit"];//local variable as different process might take longer, so we can for example half the limit where it takes longer
	    // uncomment for debug // $limit = 1;
	    $diritems = File_Ops::listDirectoryItems(Gphotos_c::$_g_upload_dir);
	    $dir_index = 0;
	    $newMediaItems = [];
	    if (count($diritems) > 0) {
		  while ($dir_index < count($diritems) && $dir_index < $limit) {
			$item = $diritems[$dir_index];
			$item_data = null;
			$item_exif = Image::getExif($item["fullfilepath"], ["format" => "array"]);
			array_push($newMediaItems, [
			    "filename" => $item["filename"],
			    "fullfilepath" => $item["fullfilepath"],
			    "description" => "appupload",
			    "exif" => $item_exif
			]);
			$dir_index++;
		  }
		  if (count($newMediaItems) > 0) {
			try {
			      $msg .= $gphotos->uploadFromFileArray($newMediaItems);
			} catch (\Exception $ex) {
			      $msg .= $ex->getMessage() . ", ";
			}
		  }
	    }
	    else {
		  $msg = "no items to upload";
	    }
	    return ["resultcount" => $dir_index, "msg" => "Processed: " . $msg];
      }

      /** sorts unzipped takeout files
       */
      protected function x20240306_gtakeout_sort($task) {
	    $msg = "sort";
	    $sourcedir = $this->_gdrive_takeout . "/unzipped";
	    $imagedir = $this->_gdrive_takeout . "/images";
	    $jsondir = $this->_gdrive_takeout . "/json";
	    $miscdir = $this->_gdrive_takeout . "/misc";
	    $processed_items = 0;
	    $limit = $task["limit"];//local variable as different process might take longer, so we can for example half the limit where it takes longer
	    $dirlist = File_Ops::listDescendantDirectories($sourcedir);
	    array_push($dirlist, $sourcedir);//to include any files in parent directory
	    $dir_index = 0;
	    while ($dir_index < count($dirlist) && $processed_items < $limit) {
		  $dir_path = $dirlist[$dir_index];
		  $diritems = File_Ops::listDirectoryItems($dir_path, ["directories" => true]);
		  if (count($diritems) > 0) {
			$file_index = 0;
			do {
			      $item = $diritems[$file_index];
			      switch ($item["type"]) {
				    case "image":
				    case "video":
					  File_Ops::moveItemFromTo($item["filename"], $item["directory"], $imagedir);
					  break;
				    case "json":
					  File_Ops::moveItemFromTo($item["filename"], $item["directory"], $jsondir);
					  break;
				    case "directory":// do nothing, only delete directory when its empty
					  break;
				    default:
					  File_Ops::moveItemFromTo($item["filename"], $item["directory"], $miscdir);
					  break;
			      }
			      $processed_items++;
			      $msg .= $item["filename"] . ", ";
			      $file_index++;
			} while ($file_index < count($diritems) && $processed_items < $limit);
		  }
		  else {
			if ($dir_path != $sourcedir) {
			      File_Ops::deleteDirectory($dir_path, ["permanent" => true]);
			      $msg .= " DELETED EMPTY DIR:" . $dir_path . ",";
			      $processed_items++;
			}
		  }
		  $dir_index++;
	    }
	    return ["resultcount" => $processed_items, "msg" => "Processed: " . $msg];
      }

      /**
       * ---------------------------------------------------
       * zipextract after downloading - *** NOTE this does not check for download completion so has to be manual for now
       * --------------
       * ~www;
       * cd private/gdrive_temp/zipstore;
       * for a in *.zip; do unzip "$a" -d "${a%.zip}"; done
       * sudo chown -R datadimension:www-data private/gdrive_temp;
       * sudo chmod -R 770 private/gdrive_temp;
       * rm private/gdrive_temp/zipstore/*.zip
       * mv private/gdrive_temp/zipstore/* private/gdrive_temp/unzipped
       *
       *
       * downloads and unzips takeoutfiles from drive
       * only unzip if  images dir is empty and unzipped dir is empty  to preserve server memory (as processed images are deleted)
       *
       * the curl extension generated wget expires ?
       *
       * after download:
       * ~www;
       * sudo chown -R datadimension:www-data private/gdrive_temp;
       * sudo chmod -R 770 private/gdrive_temp;
       *
       * @param $task
       * @return string[]
       */
      protected function x20240306_gtakeout_unzip($task) {
	    if (Auth::user()) {
		  $usersubdir = Auth::user()->getAttributes()["oauthid"];
	    }
	    else {
		  $usersubdir = "server";
	    }
	    $msg = "";
	    $zipstore = $this->_gdrive_takeout . "/zipstore";
	    $unzipdir = $this->_gdrive_takeout . "/unzipped";
	    $imagedir = $this->_gdrive_takeout . "/images";
	    if (File_Ops::isEmpty($imagedir) && File_Ops::isEmpty($unzipdir)) {//check images dir is empty to preserve server memory (processed images are deleted)
		  ini_set("memory_limit", -1);
		  ini_set('max_execution_time', 0);
		  $zip = File_Ops::listDirectoryItems($zipstore);
		  if (count($zip) > 0) {
			$zip = $zip[0];
			try {
			      File_Ops::unZip($zip["directory"] . "/" . $zip["filename"], $unzipdir);
			      File_Ops::deleteFile($zip["directory"] . "/" . $zip["filename"]);
			      $msg = "unzipped " . $zip["filename"];
			} catch (\Exception $ex) {
			      $msg = $ex->getMessage();
			}
		  }
		  else {
			$msg = "nothing to unzip";
		  }
	    }
	    else {
		  $msg = "cannot unzip when previous unzipped files are not fully processed";
	    }
	    return ["msg" => $msg];
      }

      /**
       * matches files to json and merges with exif, updating database
       **/
      protected function gtakeout_exif($task) {
	    $gphotos = new Gphotos_c();
	    if (Auth::user()) {
		  $usersubdir = Auth::user()->getAttributes()["oauthid"];
	    }
	    else {
		  $usersubdir = "server";
	    }
	    $unzipdir = $this->_gdrive_takeout . "/unzipped";
	    $imagedir = $this->_gdrive_takeout . "/images";
	    $jsondir = $this->_gdrive_takeout . "/json";
	    if (!File_Ops::isEmpty($unzipdir)) {//check images dir is empty to preserve server memory (processed images are deleted)
		  return ["resultcount" => 0, "msg" => "Cannot analyse exif while still sorting files"];
	    }
	    $msg = "";
	    $error_msg = "";

	    $processed_items = 0;
	    $limit = $task["limit"];//local variable as different process might take longer, so we can for example half the limit where it takes longer
	    $diritems = File_Ops::listDirectoryItems($imagedir);
	    $updateArray = [];
	    if (count($diritems) > 0) {
		  $file_index = 0;
		  do {
			try {
			      $item = $diritems[$file_index];
			      $item_data = null;
			      $item_exif = Image::getExif($item["directory"] . "/" . $item["filename"], ["format" => "array"]);
			      $item_json_file = File_Ops::toFullPath($jsondir . "/" . $item["filename"] . ".json");

			      //try existing db date from api eg 154820_10150104473305180_5444664_n.jpg
			      $item_dbphotodata = DataB::select("_photolibrary", "*", ["filename" => $item["filename"]]);
			      if (count($item_dbphotodata) == 1) {
				    $item_data = $item_dbphotodata[0];
			      }
			      else if (count($item_dbphotodata) > 1) {
				    throw new \Exception("multiple matches for " . $item["filename"]);
			      }
			      else {//data for this file is not in database, so need to find it from api
				    if (isset($item_exif["EXIF"])) {
					  $timestamp = $item_exif["EXIF"]["DateTimeOriginal"];
					  $timemin = Date_Time::datestringAddOffset($timestamp, 0, "day", ["rounding" => "down"]);
					  $timemax = Date_Time::datestringAddOffset($timestamp, 1, "day", ["rounding" => "down"]);
					  $item_apidata = $gphotos->searchMediaItems([//api cannot match by file name so need to get minimum matches by files for that day
						//  "pageToken" => $nextPageToken,//commented out to test - reenable
					      "dateMin" => $timemin,
					      "dateMax" => $timemax,
					      "maxpages" => 0
					  ]);
					  if (count($item_apidata["data"]) == 0) {
						throw new \Exception("no google filename match here, deleted from queue");
					  }
					  else {
						$gphotos->updatePhotoLibraryDB($item_apidata["data"]);//update any api data onto database, so reduce future need query api anyway
						foreach ($item_apidata["data"] as $i => $apiitem) {//attempt to get index of matching returned data to server photo file
						      if ($item["filename"] == $apiitem["filename"]) {
							    if ($item_data != null) {
								  throw new \Exception("multiple matches for " . $item["filename"]);
							    }
							    else {
								  $item_data = $apiitem;//set data for next step, but check all results in case file name is not unique
							    }
						      }
						}
						if ($item_data == null) {
						      throw new \Exception("no google filename match here, deleted from queue");
						}
					  }
				    }
			      }
			      //get exif to aooly to database
			      $item_data["exif"] = json_encode($item_exif, JSON_INVALID_UTF8_IGNORE);
			      $gphotos->updatePhotoLibraryDB($item_data);//update any api data onto database, so reduce future need query api anyway
			      File_Ops::deleteFile($item["fullfilepath"]);
			      $processed_items++;
			      $msg .= $item["filename"] . ", ";
			} catch (\Exception $ex) {
			      $error_msg .= $item["filename"] . " error:" . $ex->getMessage() . ", ";
			      switch ($ex->getMessage()) {
				    case "no google filename match here, deleted from queue";
					  File_Ops::deleteFile($item["fullfilepath"]);
					  break;
				    default:
					  File_Ops::moveItemFromTo($item["filename"], $imagedir, $this->_gdrive_takeout . "/failed/images");
			      }
			}
			if (File_Ops::exists($item_json_file)) {
			      File_Ops::deleteFile($item_json_file);//delete json as not needed
			}
			$file_index++;
		  } while ($file_index < count($diritems) && $processed_items < $limit);
	    }
	    $msg = $error_msg . ". " . $msg;
	    return ["resultcount" => $processed_items, "msg" => "Processed: " . $msg];
      }

      /**
       *uploads photos from temp dir to gphotos
       **/
      protected function x20240306_gdrive_tempphoto_to_gphotos($task) {
	    return $this->gdrive_tempitem_to_gphotos($task, $this->_temp_photos_dir);
      }

      /**
       * gdrivemap maps google drive meta to database
       *
       * same as other sync meta, its output to the database is the whole
       * google record.
       * This allows non conflicting updates to the local database where
       * new additions are added, but also any changes that google records are
       * also put as upsert records.
       * Basically if a record is not present its added, a change is also added as a whole record
       * so an update or an addition are the same thing as we always retrieve the meta record
       * as it is in google at the time
       *
       * of note if the g_driveAddIndex or gdriveupdate index is null we will auto generatie from standard epoch 1970-01-01
       */
      protected function gdrive_tempitem_to_gphotos($task, $sourcedir) {
	    $gphotos = new Gphotos_c();
	    if (Auth::user()) {
		  $usersubdir = Auth::user()->getAttributes()["oauthid"];
	    }
	    else {
		  $usersubdir = "server";
	    }
	    $dir = File_Ops::getFullPath($sourcedir);
	    $msg = "Uploading from " . $dir . " - ";
	    $files = File_Ops::deprecated_getDirectoryFiles($dir, ["format" => "name"]);
	    $newMediaItems = [];
	    $filenametag = "_gdrivename_";
	    $processed_files = 0;
	    $limit = $task["limit"];
	    foreach ($files as $file) {
		  if ($processed_files > $limit) {
			break;
		  }
		  $filenameindex = strpos($file, $filenametag);
		  $origfilename = substr($file, $filenameindex + strlen($filenametag));
		  $fullfilepath = $dir . "/" . $file;
		  array_push($newMediaItems, [
		      "filename" => $origfilename,
		      "fullfilepath" => $fullfilepath,
		      "description" => "transfered from google drive",
		      "exif" => Image::getExif($fullfilepath)
		  ]);
		  $processed_files++;
	    }
	    if (count($newMediaItems) > 0) {
		  $msg .= $gphotos->uploadFromFileArray($newMediaItems);
	    }
	    else {
		  $msg = "Nothing to upload to GPhotos";
	    }
	    return ["resultcount" => $processed_files, "msg" => "Processed: " . $msg];
      }

      /**
       * downloads the photos from drive folder $this->_drive_serveroutbox_photos
       **/
      protected function x20240306_gdrive_tempvideo_to_gphotos($task) {
	    return $this->gdrive_tempitem_to_gphotos($task, $this->_temp_videos_dir);
      }

      /**
       *  extract photos from the parent directory folder subdirectories so another process can index and move them to google photos
       * @param $task
       * @return void
       */
      protected function x20240306_gdrive_processqueue($task) {
	    $this->gdrive_dirextract($this->_drivephotoprocessqueue, $task["limit"]);
      }

      /**
       * downloads the photos from drive folder $this->_drive_serveroutbox_photos
       * so we can upload to photos
       **/
      protected function x20240306_gdrive_getoutbox_photos($task) {
	    return $this->gdrive_getoutbox_items($task, "photos");
      }

      /**
       * downloads the videos from drive folder $this->_drive_serveroutbox_photos
       * so we can upload to photos
       **/
      protected function x20240306_gdrive_getoutbox_videos($task) {
	    return $this->gdrive_getoutbox_items($task, "videos");
      }

      /**
       * downloads the items from drive folder $this->_drive_serveroutbox_photos
       * so we can upload to photos
       **/
      protected function x20240306_gdrive_getoutbox_items($task, $type) {
	    $msg = "";
	    $drive = new Gdrive_c();
	    switch ($type) {
		  case "photos":
			$sourcedir = $this->_drive_serveroutbox_photos;
			$targetdir = $this->_temp_photos_dir;
			break;
		  case "videos":
			$sourcedir = $this->_drive_serveroutbox_videos;
			$targetdir = $this->_temp_videos_dir;
			break;
	    }
	    $diritems = $drive->listDirectoryItems($sourcedir);
	    $processed_files = 0;
	    $limit = $task["limit"];
	    while ($processed_files < $limit && $processed_files < count($diritems)) {
		  echo $diritems[$processed_files]["name"] . ", ";
		  $msg .= $diritems[$processed_files]["name"] . ", ";
		  $file_id = $diritems[$processed_files]["UUID"];
		  $drive->download($file_id, ["download_dir" => $targetdir]);
		  $drive->deleteItem($file_id, ["permanent" => true]);
		  $processed_files++;
	    }
	    return ["resultcount" => $processed_files, "msg" => "Processed: " . $msg];
      }

      /**
       * maps google photos meta data to _photolibrary
       * @param $task
       * @return string[]
       */
      protected function gphotos_DBmap($task) {
	    $gphotos = new Gphotos_c();
	    $meta = $gphotos->syncNext([
		"limit" => $task["limit"]
	    ]);
	    return ["resultcount" => $meta["itemcount"], "msg" => $meta["msg"]];;
      }

      /**
       * updates google photos meta data to _photolibrary, removing deleted
       * @param $task
       * @return string[]
       */
      protected function gphotos_DBmapUpdate($task) {
	    $gphotos = new Gphotos_c();
	    //$gphotos->createAlbum("test");
	    $albs = $gphotos->listAlbums();
	    var_dump($albs);
	    die("check exif is not overwritten if bad");
	    $task["limit"] = 3;//test - comment out after
	    $meta = $gphotos->updateNext(["limit" => $task["limit"]]);
	    return ["resultcount" => $meta["itemcount"], "msg" => $meta["msg"]];;
      }

      protected function x20231231gdrive_deviceSourceDirSync($task) {
	    $drive = new Gdrive_a();
	    $dirRoot = CacheHandler::getAppSetting("g_driveSyncSourceId");
	    $mirrorResult = $drive->mirrorDirectoriesOnlyToDB($dirRoot, ["limit" => $task["limit"]]);
	    //$dirRoot="1b7hK6Pcx1HdfS88R590pK7axgyNN_OjP";//debug to _testDirA
	    $dirRoot = "1RaMQucAB_40p9YtvlVW58UbYgpoat6Jd";//debug to _devicesync/_source
	    //$recycleresult=$drive->recycleFiles();
	    return $mirrorResult;//+$recycleresult;
      }

      /**take files from uploaded device sources and sort them
       *
       */
      protected function x20231231gdrive_deviceSourceFileSync($task) {
	    $drive = new Gdrive_a();
	    $dirRoot = CacheHandler::getAppSetting("g_driveSyncSourceId");
	    $db_dirItems = DataB::queryByName("gdrive_dirwithdescendants", [
		"runtags" => [
		    "<UUID />" => $dirRoot,
		    "<directoriesFilter />" => "="
		],
		"orderBy" => "synced_at",
		"indexBy" => "UUID"
	    ]);
	    $processed = 0;
	    foreach ($db_dirItems as $dir) {
		  //match actual drive and DB records
		  $mirrored = $drive->mirrorDirectoryItemsToDB($dir["UUID"]);
		  $processed += $mirrored["totalitems"];
		  if ($processed > $task["limit"]) {
			break;
		  }
		  DataB::update("appDB", "gdrive_meta", ["synced_at" => DateTime_m::now()], ["UUID" => $dir["UUID"]]);
	    }
	    return ["result" => $processed];//+$recycleresult;
      }

      protected function x20231218drivetophototransfer($task) {
	    $gphotos = new Gphotos_c();
	    $task["limit"] = 50;//overidden as not allowed to change amount with a pagetoken ????? !!!!!! " When using a page token, you must use the same parameters as the previous request "
	    $meta = $gphotos->syncNext($task["limit"]);
	    return ["msg" => $meta["count"] . " " . $meta["nextToken"]];
      }

      private function local_temp_photo_process($sourcedir, $limit, $targetdirs = []) {
	    $targetdirs = array_defaults($targetdirs, [
		"photos" => $this->_drive_serveroutbox_photos,
		"videos" => $this->_drive_serveroutbox_videos,
		"json" => $this->_drive_serveroutbox_json,
		"exif" => $this->_drive_serveroutbox_exif,
		"other" => $this->_drive_serveroutbox_nonmedia
	    ]);
	    $drive = new Gdrive_c();
	    $msg = "";
	    $dirlist = $drive->listDescendantDirectories($sourcedir, [
		"maxtopleveldirs" => 1
	    ]);
	    array_push($dirlist, $sourcedir);//to include any files in parent directory
	    $dir_index = 0;
	    $processed_files = 0;
	    while ($dir_index < count($dirlist) && $processed_files < $limit) {
		  $dir_id = $dirlist[$dir_index];
		  $diritems = $drive->listDirectoryItems($dir_id, ["withmeta" => true, "directories" => null]);
		  if (count($diritems) > 0) {
			$file_index = 0;
			do {
			      //$item_id = $diritems[$file_index]["UUID"];
			      $item = $diritems[$file_index];
			      if ($item["mime"] != "application/vnd.google-apps.folder") {//ignore and don't move directories, as we dont want contents to be moved with them - we will just delete them when empty as flatening directories
				    $type = Gdrive_c::getFileType($item);
				    if ($type == "image") {
					  $drive->moveFileFromTo($item["UUID"], $targetdirs["photos"]);
				    }
				    else if ($type == "video") {
					  $drive->moveFileFromTo($item["UUID"], $targetdirs["videos"]);
				    }
				    else if ($type == "json") {
					  $drive->moveFileFromTo($item["UUID"], $targetdirs["json"]);
				    }
				    else {
					  $drive->moveFileFromTo($item["UUID"], $targetdirs["other"]);
				    }
				    $processed_files++;
			      }
			      $msg .= $item["name"] . ", ";
			      $file_index++;
			} while ($file_index < count($diritems) && $processed_files < $limit);
		  }
		  else {
			if ($dir_id != $sourcedir) {
			      $drive->deleteItem($dir_id, ["permanent" => true]);
			      $msg .= " DELETED EMPTY DIR:" . $dir_id . ",";
			}
		  }
		  $dir_index++;
	    }
	    return ["resultcount" => $processed_files, "msg" => "Processed: " . $msg];
      }

      /**
       * sorts filetypes into destination folders, deleting empty source folders
       * @param $task
       * @return string[]
       */
      private function x20240306_gdrive_dirextract($sourcedir, $limit, $targetdirs = []) {
	    $targetdirs = array_defaults($targetdirs, [
		"photos" => $this->_drive_serveroutbox_photos,
		"videos" => $this->_drive_serveroutbox_videos,
		"json" => $this->_drive_serveroutbox_json,
		"exif" => $this->_drive_serveroutbox_exif,
		"other" => $this->_drive_serveroutbox_nonmedia
	    ]);
	    $drive = new Gdrive_c();
	    $msg = "";
	    $dirlist = $drive->listDescendantDirectories($sourcedir, [
		"maxtopleveldirs" => 1
	    ]);
	    array_push($dirlist, $sourcedir);//to include any files in parent directory
	    $dir_index = 0;
	    $processed_files = 0;
	    while ($dir_index < count($dirlist) && $processed_files < $limit) {
		  $dir_id = $dirlist[$dir_index];
		  $diritems = $drive->listDirectoryItems($dir_id, ["withmeta" => true, "directories" => null]);
		  if (count($diritems) > 0) {
			$file_index = 0;
			do {
			      //$item_id = $diritems[$file_index]["UUID"];
			      $item = $diritems[$file_index];
			      if ($item["mime"] != "application/vnd.google-apps.folder") {//ignore and don't move directories, as we dont want contents to be moved with them - we will just delete them when empty as flatening directories
				    $type = Gdrive_c::getFileType($item);
				    if ($type == "image") {
					  $drive->moveFileFromTo($item["UUID"], $targetdirs["photos"]);
				    }
				    else if ($type == "video") {
					  $drive->moveFileFromTo($item["UUID"], $targetdirs["videos"]);
				    }
				    else if ($type == "json") {
					  $drive->moveFileFromTo($item["UUID"], $targetdirs["json"]);
				    }
				    else {
					  $drive->moveFileFromTo($item["UUID"], $targetdirs["other"]);
				    }
				    $processed_files++;
			      }
			      $msg .= $item["name"] . ", ";
			      $file_index++;
			} while ($file_index < count($diritems) && $processed_files < $limit);
		  }
		  else {
			if ($dir_id != $sourcedir) {
			      $drive->deleteItem($dir_id, ["permanent" => true]);
			      $msg .= " DELETED EMPTY DIR:" . $dir_id . ",";
			}
		  }
		  $dir_index++;
	    }
	    return ["resultcount" => $processed_files, "msg" => "Processed: " . $msg];
      }
}
/**legacy 20210830
 * protected function makeThumbnails($task) {
 * $torefresh = DataB::selectOldest("appDB", "g_images", ["where" => ["hasThumbnail" => 0], "limit" => $task["limit"]]);
 * foreach ($torefresh as &$file) {
 * try {
 * $origpath = public_path() . '/g_drive/images';
 * if (!file_exists($origpath . "/thumbnails/" . $file["id"] . "." . $file["fileExtension"])) {
 * $filename = $file["id"] . "." . $file["fileExtension"];
 * //need to rename file before this $file["fileExtension"]=strtolower($file["fileExtension"]);
 * Img::makeThumbnail($origpath . "/" . $filename);
 * }
 * $file["updated_at"] = DateTime_m::now();
 * } catch (\Exception $ex) {
 * self::handleException($ex, [
 * "ref" => "fileid: " . $file["id"] . " filename: " . $file["name"] . "\n",
 * "log" => "cronerror",
 * //"message"=>$ex->getErrors()[0]["message"],
 * "continue" => true
 * ]);
 * }
 * }
 * DataB::updateArray("appDB", "g_images", "id", $torefresh);
 * }
 *
 * protected function g_imagedirsupdate($task) {
 * $torefresh = DataB::selectOldest("appDB", "g_imagedirs", ["limit" => $task["limit"]]);
 * $this->drive = new Gdrive_a();
 * foreach ($torefresh as &$dir) {
 * try {
 * $dirdata = $this->drive->getFileMeta($dir["id"]);
 * $dir["created_at"] = $dirdata->createdTime;
 * $dir["created_at"] = substr(str_replace("T", " ", $dir["created_at"]), 0, 19);
 * $dir["start_at"] = DataB::selectMinValue("appDB", "g_images", "created_at", ["parentid" => $dir["id"]]);
 * $dir["finish_at"] = DataB::selectMaxValue("appDB", "g_images", "created_at", ["parentid" => $dir["id"]]);
 * $dir["updated_at"] = DateTime_m::now();
 * } catch (\Exception $ex) {
 * self::handleException($ex, [
 * "ref" => "fileid=" . $dir["id"],
 * "log" => "cronerror",
 * "continue" => true
 * ]);
 * }
 * }
 * DataB::updateArray("appDB", "g_imagedirs", "id", $torefresh);
 * }
 *
 * protected function g_imagesupdate($task) {
 * $this->drive = new Gdrive_a();
 * $torefresh = DataB::selectOldest("appDB", "g_images", [
 * "limit" => $task["limit"]
 * ]);
 *
 * //uncomment to debug a single
 * //$torefresh = DataB::select("appDB", "g_images", "*", ["id" =>"1--Ei25lzgxivpfLpQbH9GLQN6KJ9CCYB"]);
 * set_time_limit(600);//5 mins - to accomodate temp long cron jobs
 * ini_set('memory_limit', '1024M');
 * foreach ($torefresh as &$file) {
 * try {
 * $filedata = $this->drive->getFileMeta($file["id"]);
 * $file["webViewLink"] = $filedata->webViewLink;
 * $file["type"] = $filedata->mimeType;
 * $file["size"] = $filedata->size;
 * $file["fileExtension"] = $filedata->fileExtension;
 * if ($filedata->imageMediaMetadata) {
 * $g_mediameta = $filedata->imageMediaMetadata;
 * $mediameta = Model_m::array_defaults($g_mediameta, [
 * "rotation" => null,
 * "width" => null,
 * "height" => null,
 * "time" => null,
 * "location" => null
 * ]);
 * $file["width"] = $mediameta["width"];
 * $file["height"] = $mediameta["height"];
 * $file["rotation"] = $mediameta["rotation"];
 * if ($mediameta["time"]) {
 * $file["created_at"] = preg_replace("/:/", "-", $mediameta["time"], 2);
 * }
 * else {
 * $file["created_at"] = substr(str_replace("T", " ", $filedata->createdTime), 0, 19);
 * }
 * if ($mediameta["location"]) {
 * $file["lat"] = $mediameta["location"]->latitude;
 * $file["lng"] = $mediameta["location"]->longitude;
 * $file["alt"] = $mediameta["location"]->altitude;
 * }
 * }
 * else if ($filedata->videoMediaMetadata) {
 * $g_mediameta = $filedata->videoMediaMetadata;
 * $mediameta = Model_m::array_defaults($g_mediameta, [
 * "width" => null,
 * "height" => null,
 * "duration" => null
 * ]);
 * $file["width"] = $mediameta["width"];
 * $file["height"] = $mediameta["height"];
 * $file["duration"] = $mediameta["duration"];
 * }
 * else {
 * $file["created_at"] = substr(str_replace("T", " ", $filedata->createdTime), 0, 19);
 * }
 * $filename = $file["id"] . "." . $file["fileExtension"];
 * $path = public_path() . '/g_drive/images';
 * if ($file["localPath"] === null && $file["fileExtension"] != "mp4") {
 * //Log::channel('cronlog')->info($task["name"] . " attempting downloading filename: ".$file["name"]." id: ".$file["id"]);
 * $this->drive->download($file["id"], $filename, ["path" => $path]);
 * $file["localPath"] = $path . "/" . $filename;
 * }
 * } catch (\Exception $ex) {
 * //ditch direct log for exception handler logger
 * Log::channel('cronlog')->info($task["name"] . " download error - filename: ");//.$file["name"]." id: ".$file["id"]);
 * //throw new \Exception("Cron_c download error\nFile id: ". $file["id"]);
 * }
 * $file["updated_at"] = DateTime_m::now();
 * }
 * DataB::updateArray("appDB", "g_images", "id", $torefresh);
 * }
 *
 * */


