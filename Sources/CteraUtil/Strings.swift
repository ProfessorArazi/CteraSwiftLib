//
//  File.swift
//  
//
//  Created by Gal Yedidovich on 22/10/2020.
//

import Foundation
public extension String {
	//MARK: - General
//	static let on = "on".localized
//	static let yes = "yes".localized
//	static let off = "off".localized
	static let error = "error".localizedModule
//	static let ok = "ok".localized
//	static let trust = "trust".localized
//
//	//MARK: - Context Menu
//	static let info = "info".localized
//	static let addShortcut = "addShortcut".localized
//	static let share = "share".localized
//	static let makeOffline = "makeOffline".localized
//	static let removeOffline = "removeOffline".localized
//	static let updateOffline = "updateOffline".localized
//	static let leaveShare = "leaveShare".localized
//	static let leave = "leave".localized
//	static let collaboration = "collaboration".localized
//	static let publicLinks = "publicLinks".localized
//	static let versions = "versions".localized
//	static let restore = "restore".localized
//	static let rename = "rename".localized
//	static let copy = "copy".localized
//	static let move = "move".localized
//	static let delete = "delete".localized
//
//	static let select = "select".localized
//	static let copyTo = "copyTo".localized
//	static let moveTo = "moveTo".localized
//	static let uploadTo = "uploadTo".localized
//
//	static let renamePlaceholder = "renamePlaceholder".localized
//	static let deleting = "deleting".localized
//	static let restoring = "restoring".localized
//	static let copying = "copying".localized
//	static let moving = "moving".localized
//	static let loading = "loading".localized
//	static let renaming = "renaming".localized
//	static let downloading = "downloading".localized
//	static let opening = "opening".localized
//	static let verifying = "verifying".localized
//	static let signing = "signing".localized
//	static let cancel = "cancel".localized
//
//	static let conflictTitle = "conflictTitle".localized
//	static let conflictMessage = "conflictMessage".localized
//
//	static let searchResults = "searchResults".localized
//	static let deleteMsg = "deleteMsg".localized
//	static let deleteMsgMulti = "deleteMsgMulti".localized
//
//	//MARK: Home
//	static let locations = "locations".localized
//	static let shortcuts = "shortcuts".localized
//	static let home = "home".localized
//	static let cloudDrive = "cloudDrive".localizedBrand
//	static let sharedWithMe = "sharedWithMe".localized
//	static let sharedByMe = "sharedByMe".localized
//	static let backups = "backups".localized
//	static let users = "users".localized
//	static let availableOffline = "availableOffline".localized
//	static let uploads = "uploads".localized
//	static let settings = "settings".localized
//	static let quotaStorageFormat = "quotaStorageFormat".localized
//	static let signOutMsg = String.localizedStringWithFormat("signOutMsg".localized, displayName)
//	static let signOut = "signOut".localized
//	static let jailbreakTtl = "jailbreakTtl".localized
//	static let jailbreakMsg = String.localizedStringWithFormat("jailbreakMsg".localized, displayName)
//	static let remove = "remove".localized
//	static let update = "update".localized
//
//	static let passcodeSettings = "passcodeSettings".localized
//	static let sharedFolder = "sharedFolder".localized
//	static let addToCtera = "addToCtera".localized
//	static let folder = "folder".localized
//	static let file = "file".localized
//	static let upload = "upload".localized
//	static let uploadFile = "uploadFile".localized
//	static let uploadImage = "uploadImage".localized
//	static let useCamera = "useCamera".localized
//	static let newFolder = "newFolder".localized
//	static let folderName = "folderName".localized
//	static let emptyFolderName = "emptyFolderName".localized
//
//	static let emptyFolderMsg = "emptyFolderMsg".localized
//	static let emptySharedItems = "emptySharedItems".localized
//	static let emptyOfflineFolder = "emptyOfflineFolder".localized
//	static let emptyUploadsFolder = "emptyUploadsFolder".localized
//	static let emptyRootSeachRestults = "emptyRootSeachRestults".localized
//	static let emptySearchResults = String.localizedStringWithFormat("emptySearchResults".localized, cloudDrive)
//
//	static let selectAll = "selectAll".localized
//	static let deselectAll = "deselectAll".localized
//	static let selectItems = "selectItems".localized
//	static let selectedItems = "selectedItems".localized
//
//	static let portalReadOnlyTtl = "portalReadOnlyTtl".localized
//	static let portalReadOnlyMsg = "portalReadOnlyMsg".localized
//	static let menuErrorReadOnly = "menuErrorReadOnly".localized
//
//	//MARK: - Details
//	static let detailsSize = "detailsSize".localized
//	static let createBy = "createBy".localized
//	static let modifiedBy = "modifiedBy".localized
//	static let deletedBy = "deletedBy".localized
//	static let itemType = "itemType".localized

	//MARK: - Sizes
	static let zeroBytes = "zeroBytes".localizedModule
	static let oneByte = "oneByte".localizedModule
	static let bytes = "bytes".localizedModule
	static let kb = "kb".localizedModule
	static let mb = "mb".localizedModule
	static let gb = "gb".localizedModule
	static let tb = "tb".localizedModule
	static let pb = "pb".localizedModule

	//MARK: - Pretty Time
	static let lessThanMinuteAgo = "lessThanMinuteAgo".localizedModule
	static let oneMinuteAgo = "oneMinuteAgo".localizedModule
	static let minutesAgo = "minutesAgo".localizedModule
	static let todayAt = "todayAt".localizedModule
	static let yesterdayAt = "yesterdayAt".localizedModule
//
//	static let setPasscode = "setPasscode".localized
//	static let enterPasscode = "enterPasscode".localized
//	static let confirmPasscode = "confirmPasscode".localized
//	static let passcodeConfirmError = "passcodeConfirmError".localized
//
//	static let passcode = "passcode".localized
//	static let remainingAttempts = "remainingAttempts".localized
//
//	//MARK: - Settings
//	static let account = "account".localized
//	static let portal = "portal".localized
//	static let security = "security".localized
//	static let manage = "manage".localized
//	static let feedback = "feedback".localized
//	static let about = "about".localized
//
//	static let viewSettings = "viewSettings".localized
//	static let itemView = "itemView".localized
//	static let sortOrder = "sortOrder".localized
//	static let sortBy = "sortBy".localized
//	static let deletedItems = "deletedItems".localized
//
//	//MARK: - Activity
//	static let activity = "activity".localized
//	static let noActivity = "noActivity".localized
//	static let deleted = "deleted".localized
//	static let renamed = "renamed".localized
//	static let moved = "moved".localized
//	static let copied = "copied".localized
//	static let restored = "restored".localized
//	static let uploaded = "uploaded".localized
//
//	static let actionFrom = "actionFrom".localized
//	static let actionIn = "actionIn".localized
//	static let actionTo = "actionTo".localized
//
//	static let today = "today".localized
//	static let yesterday = "yesterday".localized
//	static let lastWeek = "lastWeek".localized
//	static let lastTwoWeeks = "lastTwoWeeks".localized
//	static let lastThreeWeeks = "lastThreeWeeks".localized
//	static let older = "older".localized
//
	//MARK: - Permissions
	static let permissionPreviewOnly = "permissionPreviewOnly".localizedModule
	static let permissionReadOnly = "permissionReadOnly".localizedModule
	static let permissionReadWrite = "permissionReadWrite".localizedModule
	static let permissionDenied = "permissionDenied".localizedModule
//
//	//MARK: - Public Link
//	static let createLink = "createLink".localized
//	static let editLink = "editLink".localized
//	static let permission = "permission".localized
//	static let expiration = "expiration".localized
//	static let actions = "actions".localized
//	static let saving = "saving".localized
//
//	static let deletePublicLink = "deletePublicLink".localized
//	static let deletePublicLinkMsg = "deletePublicLinkMsg".localized
//
//	//MARK: - Collaboration
//	static let owner = "owner".localized
//	static let addCollaborator = "addCollaborator".localized
//	static let addExternalCollaborator = "addExternalCollaborator".localized
//	static let add = "add".localized
//	static let collaborators = "collaborators".localized
//	static let newCollaborators = "newCollaborators".localized
//	static let teamProject = "teamProject".localized
//	static let allowReshare = "allowReshare".localized
//	static let allowSync = "allowSync".localized
//
//	static let teamProjectDesc = "teamProjectDesc".localized
//	static let allowReshareDesc = "allowReshareDesc".localized
//	static let allowSyncDesc = "allowSyncDesc".localized
//
//	static let stopCollaboration = "stopCollaboration".localized
//	static let stopCollaborationDesc = "stopCollaborationDesc".localized
//	static let leaveShareDesc = "leaveShareDesc".localized
//	static let leaveShareDescMultiple = "leaveShareDescMultiple".localized
//	static let discard = "discard".localized
//	static let discardTitle = "discardTitle".localized
//	static let discardMsg = "discardMsg".localized
//
//	static let addExtCollTitle = "addExtCollTitle".localized
//	static let addExtCollMsg = "addExtCollMsg".localized
//	static let addExtCollPlaceholder = "addExtCollPlaceholder".localized
//	static let extCollaboratorExists = "extCollaboratorExists".localized
//
//	static let editCollaborator = "editCollaborator".localized
//
//	static let email = "email".localized
//	static let sms = "sms".localized
//	static let smsOption = "smsOption".localized
//	static let invalidPhoneTtl = "invalidPhoneTtl".localized
//	static let invalidPhoneMsg = "invalidPhoneMsg".localized
//
//	static let searchCollaborator = "searchCollaborator".localized
//	static let recentlyUsed = "recentlyUsed".localized
//	static let seacrhUsers = "seacrhUsers".localized
//	static let searchGroups = "searchGroups".localized
//	static let groups = "groups".localized
//	static let validatingCollaborator = "validatingCollaborator".localized
//	static let hasMoreCollMsg = "hasMoreCollMsg".localized
//
//	static let bioFaceId = "bioFaceId".localized
//	static let bioTouchId = "bioTouchId".localized
//	static let disabledBioMsg = "disabledBioMsg".localized
//
//	//MARK: - Versions
//	static let previousVersions = "previousVersions".localized
//	static let current = "current".localized
//
//	//MARK: - Offline Access
//	static let deviceStorage = "deviceStorage".localized
//	static let bandwidth = "bandwidth".localized
//	static let offlineSync = "offlineSync".localized
//	static let batterySaving = "batterySaving".localized
//	static let offlineAccess = "settingsOffline".localized
//	static let syncInterval = "syncInterval".localized
//	static let minimumBattery = "minimumBattery".localized
//	static let clearStorage = "clearStorage".localized
//	static let clearStorageMsg = "clearStorageMsg".localized
//	static let keepSyncedFiles = "keepSyncedFiles".localized
//	static let clearAll = "clearAll".localized
//
//	static let interval15 = "interval15".localized
//	static let interval30 = "interval30".localized
//	static let interval45 = "interval45".localized
//	static let interval60 = "interval60".localized
//	static let interval120 = "interval120".localized
//
//	static let syncOverCellMsg = "syncOverCellMsg".localized
//	static let syncOverCellMsgOff = "syncOverCellMsgOff".localized
//	static let selectInterval = "selectInterval".localized
//	static let selectMinimumBattery = "selectMinimumBattery".localized
//
//	//MARK: - Uploads
//	static let uploading = "uploading".localized
//	static let recent = "recent".localized
//	static let uploadingPerc = "uploadingPerc".localized
//	static let inQueue = "inQueue".localized
//	static let `in` = "in".localized
//	static let openParent = "openParent".localized
//
//	//MARK: - Conflicts
//	static let stop = "stop".localized
//	static let keepBoth = "keepBoth".localized
//	static let replace = "replace".localized
//
//	//MARK: - Error Messages
//	static let invalidUrl = "invalidUrl".localized
//	static let noConnectionMsg = "noConnectionMsg".localized
//	static let folderNotFoundMsg = "folderNotFoundMsg".localized
//	static let fileNotFoundErrorMsg = "fileNotFoundErrorMsg".localized
//	static let couldNotUploadImage = "couldNotUploadImage".localized
//	static let libraryPermissionDenied = "libraryPermissionDenied".localized
//	static let certificateErrorTtl = "certificateErrorTtl".localized
//	static let certificateErrorMsg = "certificateErrorMsg".localized
//	static let couldNotFetchAttachmentsError = "couldNotFetchAttachmentsError".localized
//	static let notLoggedInError = "notLoggedInError".localized
//	static let notLoggedInErrorMsg =  String.localizedStringWithFormat("notLoggedInErrorMsg".localized, displayName)
//	static let emptyFileNameErrorMsg = "emptyFileNameErrorMsg".localized
//	static let illegalNameErrorMsg = "illegalNameErrorMsg".localized
//	static let identicalNamesErrorMsg = "identicalNamesErrorMsg".localized
//	static let tooManyAttempts = "tooManyAttempts".localized
//	static let tooManyAttemptsMsg = "tooManyAttemptsMsg".localized
//	static let previewOnlyError = "previewOnlyError".localized
//	static let cannotDownloadFileError = "cannotDownloadFileError".localized
//	static let previewDisabledByVendor = "previewDisabledByVendor".localized
//	static let uploadsDisabledByVendor = "uploadsDisabledByVendor".localized
//	static let errorFileDeleted = "errorFileDeleted".localized
//	static let errorPreviewUnavailable = "errorPreviewUnavailable".localized
//
//	//MARK: - Keyboard
//	static let clearSelection = "clearSelection".localized
//	static let backPress = "backPress".localized
//	static let openFolder = "openFolder".localized
//	static let rigthItem = "rigthItem".localized
//	static let leftItem = "leftItem".localized
//	static let upItem = "upItem".localized
//	static let downItem = "downItem".localized
//	static let renameItem = "renameItem".localized
//
//	//MARK: - Toast
//	static let uploadStartedToast = "uploadStartedToast".localized
	
	//	static let  = "".localized

	internal var localizedModule: String {
		NSLocalizedString(self, bundle: Bundle.module, comment: self)
	}
}
