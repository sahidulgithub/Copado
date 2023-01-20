public with sharing class SpvWrapper{
    @AuraEnabled(cacheable = true)
    public static string getSpvInfo(string userId){

        Map<string, List<OppWrapper>> oppStageMap = new Map<string, List<OppWrapper>>();

        // Map<string,Map<List<OppWrapper>,List<subTotalWrapper>>> oppMainStageMap = new Map<string, Map<List<OppWrapper>,List<subTotalWrapper>>>();
        //OppMainWrapper   oppMain                   = new OppMainWrapper();

        User userObj = [SELECT ContactId, Id
                        FROM User
                        WHERE Id = :userId];


        Report_Utils__c Report_Utils = [SELECT ID, Name, Stages__c, Vehical_Type__c
                                        FROM Report_Utils__c
                                        WHERE Name = 'SPV Report'
                                        LIMIT 1];

        List<String> stagesList = new List<String>();
        List<String> vehicleTypeLst = new List<String>();
        stagesList = Report_Utils.Stages__c.split(';');
        vehicleTypeLst = Report_Utils.Vehical_Type__c.split(';');


        List<Vehicle__c> vehList = [SELECT Id
                                    FROM Vehicle__c
                                    WHERE Venture_Partner__c = :userObj.ContactId AND Vehicle_Type__c IN:vehicleTypeLst];

        List<Opportunity> oppList = [SELECT Amount, StageName, Closedate, CloseDate__c, createdDate, Round_Stage__c, Account.Name, Fiscal_period__c, CreatedDate__c, AmountField__c
                                     FROM Opportunity
                                     WHERE Venture_Partner__c = :userObj.ContactId /*AND Vehicle__r.Vehicle_Type__c ='VP-SPV'*/ AND Vehicle__c IN:vehList AND StageName IN:stagesList ];


        for (Opportunity oppItr : oppList){

            if (oppStageMap.containsKey(oppItr.StageName)){
                List<OppWrapper> oppExisting = oppStageMap.get(oppItr.StageName);

                OppWrapper oppWraObj = new OppWrapper(oppExisting.size() + 1, false, oppItr);
                oppExisting[0].oppCount = oppExisting.size() + 1;

                oppExisting.add(oppWraObj);
                oppStageMap.put(oppItr.StageName, oppExisting);

                //oppMain.stage   = oppItr.StageName;
                //oppMain.oppList = oppExisting;
            } else{
                OppWrapper oppWraObj = new OppWrapper(1, true, oppItr);
                List<OppWrapper> oppWraList = new List<OppWrapper>();
                oppWraList.add(oppWraObj);
                oppStageMap.put(oppItr.StageName, oppWraList);

                //oppMain.stage   = oppItr.StageName;
                //oppMain.oppList = oppWraList;
            }

        }


        //system.debug(oppMain);
        system.debug(oppList);
        return JSON.serialize(oppStageMap);
    }

    @AuraEnabled(cacheable = true)
    public static string getSPVAngleData(){
        List<String> stagesList = new List<String>();
        stagesList.add('Triaging');
        stagesList.add('Executing');
        stagesList.add('Closed Won');
        stagesList.add('Closed Lost');

        List<Opportunity> oppList = [SELECT StageName, Closedate, createdDate, CloseDate__c, Account.Name, Round_Stage__c, FiscalQuarter, FiscalYear, Vehicle__r.Name, Fiscal_period__c, CreatedDate__c, AmountField__c
                                     FROM opportunity
                                     WHERE StageName IN:stagesList];

        Map<String, Map<String, List<Opportunity>>> mainMap = new Map<String, Map<String, List<Opportunity>>>();

        Map<String, Map<String, List<OppWrapper>>> mainMap1 = new Map<String, Map<String, List<OppWrapper>>>();

        for (Opportunity oppItr : oppList){
            // if exist in map || Vehicle Name
            if (mainMap.containsKey(oppItr.Vehicle__r.Name)){

                // if exist in map || Stage Name
                if (mainMap.get(oppItr.Vehicle__r.Name).containsKey(oppItr.StageName)){
                    List<spvAngleSubWrapper> oppWraList = new List<spvAngleSubWrapper>();
                    List<Opportunity> existingOppList = new List<Opportunity>();
                    existingOppList.add(oppItr);
                    //  oppWraList.add();
                    mainMap.get(oppItr.Vehicle__r.Name).get(oppItr.StageName).add(oppItr);

                } else{
                    // if not exist in map || Stage Name
                    mainMap.get(oppItr.Vehicle__r.Name).put(oppItr.StageName, new List<Opportunity>{ oppItr });
                }

            } else{
                // if not exists || Vehicle Name
                List<Opportunity> oppWraList = new List<Opportunity>();
                oppWraList.add(oppItr);
                Map<String, List<Opportunity>> subMap = new Map<String, List<Opportunity>>();
                subMap.put(oppItr.StageName, oppWraList);
                mainMap.put(oppItr.Vehicle__r.Name, subMap);
            }
        }

        system.debug(mainMap);
        return JSON.serialize(mainMap);
    }

    @AuraEnabled(cacheable = true)
    public static String getDataByFilter(String searchKey, String currentUserId){
        Map<string, List<OppWrapper>> oppStageMap = new Map<string, List<OppWrapper>>();


        User userObj = [SELECT ContactId, Id
                        FROM User
                        WHERE Id = :currentUserId];
        List<Vehicle__c> vehList = [Select Id, Name
                                    FROM Vehicle__c
                                    WHERE Venture_Partner__c = :userObj.ContactId AND Vehicle_type__c = 'VP-SPV'];


        List<Opportunity> oppList = new List<Opportunity>();
        if (searchKey != null && searchKey != ''){
            String key = '%' + searchKey + '%';
            String datekey = searchKey;
            String amount = searchKey;

            oppList = [SELECT Amount, StageName, Closedate, createdDate, Round_Stage__c, Account.Name, Fiscal_period__c, AmountField__c, CloseDate__c, CreatedDate__c
                       FROM Opportunity
                       WHERE Venture_Partner__c = :userObj.ContactId AND Vehicle__c IN:vehList AND (Account.Name LIKE:key OR Round_Stage__c LIKE:key OR AmountField__c LIKE:amount OR CreatedDate__c = :searchKey OR CloseDate__c = :searchKey OR Fiscal_period__c LIKE:key OR StageName LIKE:key)];
        }

        for (Opportunity oppItr : oppList){

            if (oppStageMap.containsKey(oppItr.StageName)){
                List<OppWrapper> oppExisting = oppStageMap.get(oppItr.StageName);

                OppWrapper oppWraObj = new OppWrapper(oppExisting.size() + 1, false, oppItr);
                oppExisting[0].oppCount = oppExisting.size() + 1;

                oppExisting.add(oppWraObj);
                oppStageMap.put(oppItr.StageName, oppExisting);

                //oppMain.stage   = oppItr.StageName;
                //oppMain.oppList = oppExisting;
            } else{
                OppWrapper oppWraObj = new OppWrapper(1, true, oppItr);
                List<OppWrapper> oppWraList = new List<OppWrapper>();
                oppWraList.add(oppWraObj);
                oppStageMap.put(oppItr.StageName, oppWraList);

                //oppMain.stage   = oppItr.StageName;
                //oppMain.oppList = oppWraList;
            }

        }


        //system.debug(oppMain);
        system.debug(oppList);
        return JSON.serialize(oppStageMap);
    }

    public class OppMainWrapper{
        public String stage;
        public Integer oppCount;
        public List<OppWrapper> oppList;
        public OppMainWrapper(String stage, List<OppWrapper> oppList){
            this.stage = stage;
            this.oppCount = oppList.size();
            this.oppList = oppList;
        }

    }

    public class OppWrapper{
        public Opportunity oppObj;
        public Boolean needToShow;
        public Integer oppCount;
        public String closedate;
        public date createddate;
        public string createdate;
        public string bgColor;
        public string roundStage;
        public string fiscal;
        public OppWrapper(Integer oppCount, Boolean needToShow, Opportunity oppObj){
            this.oppCount = oppCount;
            this.needToShow = needToShow;
            this.oppObj = oppObj;
            if (oppObj.Round_Stage__c == null){
                oppObj.Round_Stage__c = ' ';
            } else{
                this.roundStage = oppObj.Round_Stage__c;
                this.bgColor = 'slds-badge badge-bg-color bg-badge';
            }
            this.fiscal = oppObj.Fiscal_period__c;
            // Date d1 = oppObj.Closedate;
            //  this.closedate = DateTime.newInstance(d1.year(),d1.month(),d1.day()).format('MM/dd/YYYY');
            this.closedate = oppObj.CloseDate__c;
            // this.createddate= oppObj.CreatedDate__c;
            this.createdate = oppObj.CreatedDate__c;
        }

    }

    public class spvAngleSubWrapper{
        public spvAngleSubWrapper(){
        }

    }

    public class spvAngleMainWrapper{
        public spvAngleMainWrapper(String vehicleName, String stage, List<opportunity> oppList){
        }

    }

    public class mainWrapper{
        @AuraEnabled
        public String accName;
        @AuraEnabled
        public String roundstage;
        @AuraEnabled
        public String amount;
        @AuraEnabled
        public string closedate;
        @AuraEnabled
        public String created;
        @AuraEnabled
        public String stageName;
        @AuraEnabled
        public String fiscal;
        @AuraEnabled
        public Integer i;
        @AuraEnabled
        public String bgcolor;
        public mainWrapper(Integer i, String accName, String roundstage, String amount, String created, string stageName, String fiscal, string closedate){

            this.i = i;
            this.accName = accName;
            if (roundstage != null){
                this.roundstage = roundstage;
                //bgcolor='seed series';
                bgcolor = 'slds-badge bg-badge';
            } else{
                this.roundstage = ' ';
            }

            this.amount = amount;
            this.closedate = closedate;
            this.created = created;
            this.stageName = stageName;
            this.fiscal = fiscal;
            //    this.fiscal=fiscal;
        }

    }

}