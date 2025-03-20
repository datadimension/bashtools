<?php

namespace app\Http\Controllers;

use App\DD_laravelAp\API\x20231023google\Gdrive_a;
use App\DD_laravelAp\Controllers\BaseController_Ajax;
use App\DD_laravelAp\Helpers\DataB;
use App\DD_laravelAp\Models\DateTime_m;
use app\Http\Models\Model_m;
use Cache;
use Illuminate\Support\Facades\Session;

@session_start();

class Ajax_c extends BaseController_Ajax {

      function get_metar() {
	    $ICAO = $this->ajaxpacket["ICAO"];

      }

      protected function getDuplicates() {
	    return ["data" => DataB::queryByName("g_image_dups", ["runtags" => ["<limit />" => 10]])];
      }

      /**setMainBucketTarget
       * stores a main bucket target to empty into
       * @return array|void
       * @throws \Exception
       */
      protected function storeMainBucketTarget() {
	    $dirId = $this->ajaxpacket["dirId"];
	    Model_m::setAppSetting("appDB", "bucketDirID", $dirId);
      }

      protected function setImageDir() {
	    $syncMode = false;//forces full sync between gdrive and DB before returning meta
	    $drive = new Gdrive_a();
	    switch ($this->ajaxpacket["action"]) {
		  case "moveup":
			$dirID = DataB::selectSingleValue("appDB", "gdrive_meta", "parents", ["UUID" => $this->ajaxpacket["dirid"]]);
			break;
		  case "setbyid":
			$dirID = $this->ajaxpacket["dirid"];
			break;
		  default:
			die("unsupportedaction");
	    }
	    $dirRow = DataB::selectSingleRow("gdrive_meta", ["UUID" => $dirID]);
	    $dirID = $dirRow["UUID"];
	    if ($syncMode) {
		  $drive->mirrorDirectoryItemsToDB($dirID);
	    }
	    Model_m::setAppSetting("appDB", "gimagedir_currentid", $dirID);
	    $dirlist = DataB::queryByName("gdrive_diritems", [
		"runtags" => [
		    "<parentId />" => $dirID,
		    "<directoriesFilter />" => "="
		],
		"orderBy" => "name desc"
	    ]);
	    $dirItems = DataB::queryByName("gdrive_diritems", [
		"runtags" => [
		    "<parentId />" => $dirID,
		    "<directoriesFilter />" => "<>"
		],
		"orderBy" => "created_at"
	    ]);
	    $imagelist = [];
	    foreach ($dirItems as $item) {
		  switch ($item["extension"]) {
			case "gif":
			case "png":
			case "JPG":
			case "jpg":
			      array_push($imagelist, $item);
			      break;
			default:
			      switch ($item["mime"]) {
				    case "application/vnd.google-apps.folder":
					  array_push($dirlist, $item);
					  break;
			      }
		  }
	    }
	    //currently adding to image bucket creates an object so here translate it back to an array for javascript
	    $imageBucketObj = Session::get("imagebucket");
	    //$imageBucketTarget = DataB::selectSingleValue("appDB", "_appsettings", "parents", ["UUID" => $this->ajaxpacket["dirid"]]);
	    $imageBucketTargetUUID = CacheHandler::getAppSetting("bucketDirID");
	    $imageBucketTargetName = DataB::selectSingleValue("appDB", "gdrive_meta", "name", ["UUID" => $imageBucketTargetUUID]);

	    $imageBucket = [];
	    if ($imageBucketObj) {
		  foreach ($imageBucketObj as $k => $v) {
			array_push($imageBucket, $v);
		  }
	    }
	    return [
		"data" => [
		    "directoryname" => $dirRow["name"],
		    "dirID" => $dirID,
		    "dirlist" => $dirlist,
		    "imagelist" => $imagelist,
		    "imageBucket" => $imageBucket,
		    "imageBucketTargetName" => $imageBucketTargetName
		],
		"clientCallback" => "ctrl.updateContent"
	    ];
      }

      protected function bucketSelectedAddTo() {
	    $imageUUIDs = explode(",", $this->ajaxpacket["imageUUIDs"]);
	    $imageBucket = Session::get("imagebucket");
	    if (!$imageBucket) {
		  $imageBucket = [];
	    }
	    $imageBucket = array_unique(array_merge($imageBucket, $imageUUIDs));
	    $imageBucket = array_filter($imageBucket, function ($value) {
		  return ($value !== NULL && $value !== FALSE && $value !== "");
	    });
	    Session::put("imagebucket", $imageBucket);
	    return [
		"data" => [
		    "imageBucket" => $imageBucket
		]
	    ];
      }

      private function emptyBucket($targetDir) {
	    //$bucketIds = $this->ajaxpacket["bucketIds"];
	    $imageBucketObj = Session::get("imagebucket");
	    $drive = new Gdrive_a();
	    foreach ($imageBucketObj as $k => $bucketUUID) {
		  $drive->moveFileFromTo($bucketUUID, $targetDir);
	    }
	    $drive->mirrorDirectoryItemsToDB($targetDir);
	    Session::put("imagebucket", []);
      }

      protected function bucketEmptyInTarget() {
	    $this->emptyBucket(CacheHandler::getAppSetting("bucketDirID"));
	    return ["trigger" => "reload"];
      }

      protected function bucketEmptyToDir() {
	    $this->emptyBucket($this->ajaxpacket["dirId"]);
	    return ["trigger" => "reload"];
      }

      protected function deleteImages() {
	    $drive = new Gdrive_a();
	    $imageUUIDs = explode(",", $this->ajaxpacket["imageUUIDs"]);
	    foreach ($imageUUIDs as $imageUUID) {
		  $drive->deleteItem($imageUUID, ["permanent" => false]);
	    }
	    return ["trigger" => "reload"];
      }
}
