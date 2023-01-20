@isTest(SeeAllData = true)
public without sharing class updatePassword{

    // User & New Passowrd
    public static String getUsername;
    public static String getPassword;

    // Test method that has access to all data.
    @isTest(SeeAllData = true)
    public static string testMethod1(){

        String result = '';
        String username = updatePassword.getUsername;
        String Password = updatePassword.getPassword;

        // Can query all data in the organization.
        Id profileId = [SELECT Id
                        FROM Profile
                        WHERE Name = 'System Administrator'
                        LIMIT 1].Id;
        User u = [SELECT Id, UserName, Email
                 FROM User
                 WHERE ProfileId = :profileId
                 LIMIT 1];
        System.debug('UserName: ' + u.UserName);
        System.debug('Email: ' + u.Email);

        system.runAs(u){
            try{
                System.debug('Change Password');
                List<User> users = new List<User>();
                
                Users = Database.Query('SELECT Id, Name FROM User WHERE Id  =: username');
                //  User adimin = [select Id from UserProfile where Name = 'System Administrator' ];
                System.resetPassword(Users[0].Id, true);
                for(User user : users){
                //For reset User password
                // System.resetPassword(u.Id, true);

                //For set User password
                System.setPassword(user.Id, Password);

                }
                result = 'Success';
                system.debug('result' + result);
            } catch (Exception e){
                system.debug('Error' + e.getMessage());
                result = e.getMessage();
            }
        }

        return result;
    }

    public static string setPassword(String un, String pw){
        updatePassword.getUsername = un;
        updatePassword.getPassword = pw;

        return testMethod1();
    }
}