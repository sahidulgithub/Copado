public without sharing class UpdatePasswordCtrl{  
  @AuraEnabled(cacheable = true)
  public static string changePassword(String newPassword, String verifyNewPassword, String oldpassword){
    String result = '';
    try{
      PageReference passwordUpdate = Site.changePassword(newPassword, verifyNewPassword, oldpassword);
      result = 'Success!';
    } catch (Exception e){
      system.debug('Error' + e.getMessage());
      result = e.getMessage();
    }


    /* try{
     System.debug('Change Password');
     result = updatePassword.setPassword(userName, Password);
     } catch (Exception e){
     system.debug('Error' + e.getMessage());
     result = e.getMessage();
     } */
    return result;
  }

  @AuraEnabled
  public static String setUserPhoto(String contentVersionId, String userId){
  String result = '';
  try{
    ContentVersion contentVersion = [SELECT Id, VersionData, FileType, Title 
                                     FROM ContentVersion  
                                     WHERE Id =: contentVersionId 
                                     LIMIT 1  ];

    String lowerCaseFileType = contentVersion.FileType.toLowerCase();
    ConnectApi.UserProfiles.setPhoto(null,userId , new ConnectApi.BinaryInput(contentVersion.VersionData,'image/' + lowerCaseFileType , contentVersion.Title + '.' + lowerCaseFileType));
    result = 'success';
  }catch (Exception e){
    system.debug('Error' + e.getMessage());
    result = e.getMessage();
  }
  return result;
  }

}