public with sharing class ReportCtrl {
    public ReportCtrl() {

    }

    @AuraEnabled(cacheable=true)
    public static String getusername(string userId){
        try{
            User user=[Select ContactId,Contact.FirstName,Id from User where Id =:userId WITH SECURITY_ENFORCED];
            return JSON.serialize(user.Contact.FirstName);
        }
        catch(Exception e){
            System.debug(e);
            return 'error';
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getGoogleSheetLink(string userId){
            User user=[Select ContactId,Contact.Name,Id from User where Id =:userId WITH SECURITY_ENFORCED];
            List<Contact> con = [SELECT Sheet_Url__c FROM Contact WHERE Id = :user.ContactId WITH SECURITY_ENFORCED];
          String url = con[0].Sheet_Url__c;
        return url;
    }

    @AuraEnabled(cacheable=true)
    public static String getdocumentLink(string userId){
            User user=[Select ContactId,Contact.Name,Id from User where Id =:userId WITH SECURITY_ENFORCED];
            List<Contact> con = [SELECT Google_Drive_link__c FROM Contact WHERE Id = :user.ContactId WITH SECURITY_ENFORCED];
          String url = con[0].Google_Drive_link__c;
        return url;
    }

    @AuraEnabled(cacheable=true)
    public static List<Essentials__c>  getEssentialsdata(){
            
            List<Essentials__c> essdata = [SELECT Id,Name,Title__c ,Description__c,Link__c, Contact__c FROM Essentials__c WITH SECURITY_ENFORCED];
          
        return essdata;
    }


   
    @AuraEnabled
    public static String updatePicklistValue(string userId, String value){
        String result;
        List<Contact> conList = new List<Contact> ();
            User user=[Select ContactId,Contact.Name,Id from User where Id =:userId];
           Contact con = [SELECT Id,Onboarding_Stages__c FROM Contact WHERE Id = :user.ContactId];
           
            try{
              
                 con.Onboarding_Stages__c  = value;
                 conList.add(con);
                  update conList;
                  result = 'Success';
            
                system.debug('Success'+result);
            }catch(Exception e){
                result = e.getMessage();
                system.debug('Error IN APEX'+result);
            }
            system.debug(+result);
            return result;
    }

    @AuraEnabled(cacheable=true)
    public static String getonbordingStage(string userId){
        try{
            String stage;
            User user=[Select ContactId,Contact.Name,Id from User where Id =:userId];
            Contact con = [ SELECT Onboarding_Stages__c FROM Contact WHERE Id = :user.ContactId];
            stage = con.Onboarding_Stages__c;
           return stage; 
        }
        catch(Exception e){
            System.debug(e);
            return 'error';
        }
    }



    @AuraEnabled(cacheable=true)
    public static String getAllCounts(string userId){
        try{
            User user=[Select ContactId,Id from User where Id =:userId];
            Integer wonCount             = [SELECT count() FROM Opportunity WHERE StageName='Closed Won' AND Venture_Partner__c = :user.ContactId];
            Integer triagingCount        = [SELECT count() FROM Opportunity WHERE StageName='Triaging' AND Venture_Partner__c = :user.ContactId];
            Integer executingCount       = [SELECT count() FROM Opportunity WHERE StageName='Executing' AND Venture_Partner__c = :user.ContactId];
            Integer diligencyCount       = [SELECT count() FROM Opportunity WHERE StageName='Diligencing' AND Venture_Partner__c = :user.ContactId];
            
            List<Integer> listOfOpportunity  = new  List<Integer>{wonCount,triagingCount,executingCount,diligencyCount};

            return JSON.serialize(listOfOpportunity);
        }
        catch(Exception e){
            System.debug(e);
            return 'error';
        }
    }


    @AuraEnabled(cacheable=true)
    public static String getCountsForSnapshot(string userId){
        try{
            User user=[Select ContactId,Id from User where Id =:userId];
            Integer wonCount             = [SELECT count() FROM Opportunity WHERE StageName='Closed Won' AND Venture_Partner__c = :user.ContactId];
            Integer triagingCount        = [SELECT count() FROM Opportunity WHERE StageName='Triaging' AND Venture_Partner__c = :user.ContactId];
            Integer lostCount            = [SELECT count() FROM Opportunity WHERE StageName='Closed Lost' AND Venture_Partner__c = :user.ContactId];
            
            List<Integer> listOfOpportunity  = new  List<Integer>{wonCount,triagingCount,lostCount};

            return JSON.serialize(listOfOpportunity);
        }
        catch(Exception e){
            System.debug(e);
            return 'error';
        }
    }



    @AuraEnabled(cacheable=true)
    public static String getWonCount(string userId){
        try{
            User u=[Select ContactId,Id from User where Id =:userId];
            Integer wonCount=[SELECT count() FROM Opportunity WHERE StageName='Closed Won' AND Venture_Partner__c = :u.ContactId];
            system.debug('Won Count ::'+wonCount);
            return JSON.serialize(wonCount);
        }
        catch(Exception e){
            System.debug(e);
            return '0';
        }
    }
        @AuraEnabled(cacheable=true)
        public static String getSumAmount(string userId){
            User userObj=[SELECT ContactId,Id FROM User WHERE Id =:userId];
            List<Vehicle__c> vehList   = [Select Id, Name FROM Vehicle__c WHERE Venture_Partner__c =:userObj.ContactId /* AND Vehicle_type__c 
            = 'VP-Angel'*/];
            try{
                AggregateResult wonsum=[SELECT Sum(Amount) FROM Opportunity WHERE StageName='Closed Won' AND Venture_Partner__c= : userObj.ContactId AND Vehicle__c IN : vehList];
                system.debug('Won Count ::'+wonsum);
                return JSON.serialize(wonsum.get('expr0'));
            }
            catch(Exception e){
                System.debug(e);
                return '0';
            }
       
           
    }
    @AuraEnabled(cacheable=true)
    public static String getLostCount(string userId){
        try{
            User u=[Select ContactId,Id from User where Id =:userId];
            Integer loseCount=[SELECT count() FROM Opportunity WHERE StageName='Closed Lost' AND Venture_Partner__c = :u.ContactId];
            system.debug('loseCount ::'+loseCount);
            return JSON.serialize(loseCount);
        }
        catch(Exception e){
            System.debug(e);
            return '0';
        }
       
           
    }
    @AuraEnabled(cacheable=true)
    public static String getTriageCount(string userId){
        try{
            User u=[Select ContactId,Id from User where Id =:userId];
            Integer triageCount=[SELECT count() FROM Opportunity WHERE StageName='Triaging' AND Venture_Partner__c = :u.ContactId];
            system.debug('triageCount  ::'+triageCount);
            return JSON.serialize(triageCount);
        }
        catch(Exception e){
            System.debug(e);
            return '0';
        }
       
           
    }


    @AuraEnabled
    public static String getDataByFilter(String searchKey , String currentUserId) {
        List<mainWrapper> mainwrapList=new List<mainWrapper>();
        User u=[Select ContactId,Id from User where Id =:currentUserId];
        List<Vehicle__c> vehList = [Select Id, Name FROM Vehicle__c WHERE Venture_Partner__c =:u.ContactId  AND Vehicle_type__c ='Personal'];


        List<Opportunity> allRec = new  List<Opportunity>(); 
        if(searchKey != null && searchKey !=''){
            String key = searchKey +'%';  
            String datekey=searchKey;
            String amount=searchKey;
            // Date datesearch=Date.valueOf(searchKey);
            // Date key = '%'+ searchKey +'%';  
            //Date searchdate=date.parse(searchKey);OR CloseDate =:searchdate
          //  Decimal amt=Decimal.valueOf(String.valueOf(searchKey)); OR CloseDate =:searchdate  
           // system.debug(searchdate);
             allRec = [ SELECT  Account.Name  , Round_Stage__c, Amount,FiscalQuarter, FiscalYear,
             CloseDate, Fiscal,  Venture_Partner__r.Name ,  Vehicle__r.Name,CloseDate__c	   FROM Opportunity  WHERE (Account.Name  LIKE : key 
             OR  Round_Stage__c LIKE : key OR CloseDate__c  LIKE : key OR AmountField__c LIKE: key OR Fiscal_period__c LIKE: key) AND /* Venture_Partner__r.Id = '003Ei000000ut6hIAA'*/ Venture_Partner__c=: u.ContactId AND /*Vehicle__r.Name Like 'Personal%'*/ Vehicle__c IN:vehList ];

        }else{  
            allRec =[SELECT  Account.Name  , Round_Stage__c, Amount,FiscalQuarter, FiscalYear,
            CloseDate, Fiscal,  Venture_Partner__r.Name ,  Vehicle__r.Name   FROM Opportunity 
             WHERE /*Venture_Partner__r.Id = '003Ei000000ut6hIAA'*/ Venture_Partner__c=: u.ContactId AND /*Vehicle__r.Name Like 'Personal%'*/ Vehicle__c IN:vehList ];

        }
        Integer i = 1;
        string closedate;
        Decimal Amount ;
        for(Opportunity oppItr : allRec){
            if(oppItr.CloseDate!= null){
                Date d1 = oppItr.CloseDate;                       
                closedate = DateTime.newInstance(d1.year(),d1.month(),d1.day()).format('MM/dd/YYYY');
            }
            if(oppItr.Amount!= null){
                decimal amt=oppItr.Amount;
                Amount =amt.setScale(2);
            }
            mainWrapper mainwrap=new mainWrapper(i,
                oppItr.Account.Name,
                oppItr.Round_Stage__c,
                Amount,
                closedate,
                oppItr.Fiscal,
                oppItr.Venture_Partner__r.Name,
                oppItr.Vehicle__r.Name ,
                oppItr.FiscalQuarter,
                oppItr.FiscalYear
                );
                mainwrapList.add(mainwrap);
                i++;
        }

        
        return JSON.serialize(mainwrapList);
    }

    @AuraEnabled(cacheable=true)
    public static String getPortfolioreport( string userId){
        User u=[SELECT ContactId,Id FROM User WHERE Id =:userId];
        List<Vehicle__c> vehList = [Select Id, Name FROM Vehicle__c WHERE Venture_Partner__c =:u.ContactId  AND Vehicle_type__c ='Personal'];


        List <Opportunity> oppList = new List <Opportunity>();
        try {
            List<mainWrapper> mainwrapList=new List<mainWrapper>();
            oppList = [SELECT  Account.Name  , Round_Stage__c, Amount,FiscalQuarter, FiscalYear,
            CloseDate, Fiscal,  Venture_Partner__r.Name ,  Vehicle__r.Name   FROM Opportunity  WHERE /*Venture_Partner__r.Id = '003Ei000000ut6hIAA'*/ Venture_Partner__c=:u.ContactId AND Vehicle__c IN:vehList/*Vehicle__r.Name Like 'Personal%'*/ /*Vehicle__r.Vehicle_Type__c ='Personal'*/ ];
            system.debug(oppList);
            Integer i=1;
            string closedate;
            Decimal Amount ;
            if(!oppList.isEmpty()){
            for(Opportunity oppItr:oppList){
                if(oppItr.CloseDate!= null){
                    Date d1 = oppItr.CloseDate;                       
                    closedate = DateTime.newInstance(d1.year(),d1.month(),d1.day()).format('MM/dd/YYYY');
                }
                if(oppItr.Amount!= null){
                    decimal amt=oppItr.Amount;
                    Amount =amt.setScale(2);
                }
                mainWrapper mainwrap=new mainWrapper(i,
                oppItr.Account.Name,
                oppItr.Round_Stage__c,
                Amount,
                closedate,
                oppItr.Fiscal,
                oppItr.Venture_Partner__r.Name,
                oppItr.Vehicle__r.Name ,
                oppItr.FiscalQuarter,
                oppItr.FiscalYear
                );  
                mainwrapList.add(mainwrap);
                i++;

            }
        }
            return JSON.serialize(mainwrapList);
        } 
        catch (Exception e) {
            throw new  AuraHandledException(e.getMessage());
            
        }
     
    }

   public class mainWrapper{
        @AuraEnabled   
        public String accName;
        @AuraEnabled   
        public String roundstage;
        @AuraEnabled   
        public Decimal amount ;
        @AuraEnabled   
        public string closedate;
        @AuraEnabled   
        public String venturepartnerName ;
        @AuraEnabled   
        public String vehicleName ;
        @AuraEnabled   
        public Integer fiscalyear ;
        @AuraEnabled   
        public Integer fiscalQuarter ;
        @AuraEnabled   
        public String fiscal;
        @AuraEnabled   
        public Integer i;
        @AuraEnabled 
        public String bgcolor;

        public mainWrapper(Integer i,String accName, String roundstage, Decimal amount,string closedate,String fiscal,String venturepartnerName,
        String vehicleName,Integer fiscalQuarter,Integer fiscalYear){
            
           this.i=i;
           this.accName=accName;
           if(roundstage !=null){
            this.roundstage=roundstage;
            bgcolor='slds-badge bg-badge';
           }else{
            this.roundstage='';
           }
          
           this.amount=amount;
           this.venturepartnerName=venturepartnerName;
           this.vehicleName=vehicleName;
           this.fiscalyear=fiscalyear;
           this.fiscalQuarter=fiscalQuarter;//Q3-2022
           this.fiscal='Q'+fiscalQuarter+'-'+fiscalyear;
           this.closedate=closedate;
        }
    }
}