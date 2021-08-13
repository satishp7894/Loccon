
class Connection {

  static String secretKey = "loccon_@12_34!";
  static String url = "https://loccon.in/Loccon/api/Loccon/";
  static String imageUrl = "https://loccon.in/Loccon/uploads/";

  // ImagePaths
  static String profilePicPath = imageUrl + "User/Image/";
  static String feedImagePath = imageUrl + "Feed/Image/";
  static String feedIconPath = imageUrl + "Feed Type/Image/";

  // Login
  static String login = url + "login";
  static String emailLogin = url + 'checkEmlLogin';
  static String phoneLogin = url + 'checkPhnLogin';
  static String signUp = url + "registration";

  // Feed
  static String feedTypeList = url + "feedType";
  static String forYouFeed = url + "forYouFeed";
  static String locconFeed = url + "locconFeed";
  static String viewFeed = url + "feedDetails";
  static String uploadFeed = url + "feedUpload";
  static String deleteFeed = url + "feedDelete";
  static String updateFeed = url + "feedUpdate";
  static String likeFeed = url + "feedLike";
  static String saveFeed = url + "feedSave";
  static String getSavedFeed = url + "userFeedsSaved";
  static String userFeed = url + "userFeedUpload";

  // Feed Comments
  static String feedCommentsList = url + "feedAllComment";
  static String addComment = url + "addComment";
  static String updateComment = url + "updateComment";
  static String deleteComment = url + "deleteComment";
  static String addCommentReply = url + "addCommentReply";
  static String updateCommentRep = url + "updateCommentReply";
  static String deleteCommentRep = url + "deleteCommentReply";
  static String reportFeed = url + 'addReport';

  // Chats
  static String sendOfflineMessage = url + 'unsentMsg';
  static String getOfflineMessages = url + 'getunsentMsg';

  // Profile
  static String userProfile = url + "userProfile";
  static String updateProfilePhoto = url + "updateProfilePhoto"; // user_id,  photo
  static String updateProfile = url + "updateProfile";
  static String viewUserProfile = url + "viewUserProfile";
  static String editProfile = url + 'updateProfile';

  static String category = url + "category";
  static String state = url + "state";
  static String city = url + "city";

  // User interests
  static String updateInterests = url + "interest";
  static String interests = url + 'userInterest';
  //static String updateInterestNotifications = url + 'notifyInterest';
  static String interestNotifications = url + 'userNotifyInterest';
  static String updateInterestNotifications = url + 'notifyNewIntrest';

  // Notifications
  static String sendChatNotification = url + 'unSentMsges';


}