public class loginUserProfileCtrl{
  @AuraEnabled
  public static user fetchUserDetail(){
    return [Select id, Name, SmallPhotoUrl, FullPhotoUrl, Photo_Url__c
        From User
        Where Id = :Userinfo.getUserId()];
  }
}