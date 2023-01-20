public class userTriggerHandler{
    // after Insert
    public static void afterInsert(List<user> userLst, String randomString){
        List<User> UsrLst = new List<User>();
        for (User usr : userLst){
            if (usr.Profile.Name == 'Quiet Angel Venture Partner User' || usr.Profile.Name == 'Quiet Venture Partner User'){
                asyncSetPassword(usr.Id, randomString);
            }
        }
    }
    // before insert
    /* public afterInsert(){

     } */
    @future
    public static void asyncSetPassword(String usrId, String Password){
        // get user
        User usr = [SELECT ID, ContactId
                    FROM User
                    WHERE Id = :usrId];

        try{
            // Update Partner User Password.
            System.setPassword(usr.Id, Password);

            // Query and update the contact
            Contact userContact = [SELECT Id, isPassSet__c
                                   FROM Contact
                                   WHERE Id = :usr.ContactId
                                   LIMIT 1];
            userContact.isPassSet__c = true;

            update userContact;
        } catch (Exception e){
            System.debug('The following Error has occured :: ' + e);
        }
    }

}