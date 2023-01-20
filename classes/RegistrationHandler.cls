global class RegistrationHandler {
    
    public static User createPortalUser(Auth.UserData data){
        Account a = [SELECT Id FROM account WHERE name='Bugendai Tech LLC'];
        Contact c = new Contact();
        c.accountId = a.Id;
        c.email = data.email;
        c.firstName = data.firstName;
        c.lastName = data.lastName;
        insert(c);
        
        system.debug('&&&& data \n' + data);
        system.debug(c.email);
        system.debug(c);
        
        
        User u = new User();
        System.debug('17');
        Profile p = [SELECT Id FROM profile WHERE name = 'Quiet Venture Partner User'];
        u.username = data.email.subStringBefore('@') + '@quiet.com.experience';
        
        System.debug(u.username);
        u.email = data.email;
        u.lastName = data.lastName;
        u.firstName = data.firstName;
        //u.MediumPhotoUrl = data.picture;
       u.Photo_Url__c = data.attributeMap.get('picture');
        
        //String alias = data.username;
        //Alias must be 8 characters or less
        //Alias must be 8 characters or less
        String alias = data.email.subStringBefore('@');
        if(alias.length() > 8) {
            alias = alias.substring(0, 8);
        }
        u.alias = alias;
        system.debug(u.alias);
        u.languagelocalekey = UserInfo.getLocale();
        u.localesidkey = UserInfo.getLocale();
        u.emailEncodingKey = 'UTF-8';
        u.timeZoneSidKey = 'America/Los_Angeles';
        u.profileId = p.Id;
        system.debug(u.profileId);
        u.contactId = c.Id;
        system.debug(u.contactId);
        system.debug( u.username);
        return u;
    }
    
    public static User createUser(Auth.UserData data){
        User u = new User();
        Profile p = [SELECT Id FROM profile WHERE name='System Administration'];
        u.username = data.email.subStringBefore('@') + '@quiet.com.admin';
        u.email = data.email;
        u.lastName = data.lastName;
        u.firstName = data.firstName;
        String alias = data.username;
        //Alias must be 8 characters or less
        if(alias.length() > 8) {
            alias = alias.substring(0, 8);
        }
        u.alias = alias;
        u.languagelocalekey = UserInfo.getLocale();
        u.localesidkey = UserInfo.getLocale();
        u.emailEncodingKey = 'UTF-8';
        u.timeZoneSidKey = 'America/Los_Angeles';
        u.profileId = p.Id;
       // u.contactId = c.Id;
        return u;
    }
    

}