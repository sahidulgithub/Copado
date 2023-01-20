public without sharing class SpvReportCtrl{
    public SpvReportCtrl(){
    }

    // method for getting all data related to SPV Report
    @AuraEnabled(cacheable = true)
    public static string getSPVAngelReportData(String currentUserId){
        //System.debug('called SpvReportCtrl -> getSPVAngelReportData');
        Map<String, Map<String, List<OppWrapper>>> mainMapOfData = new Map<String, Map<String, List<OppWrapper>>>();

        Report_Utils__c Report_Utils = [SELECT ID, Name, Stages__c, Vehical_Type__c
                                        FROM Report_Utils__c
                                        WHERE Name = 'Angel + SPV Report'
                                        LIMIT 1];

        List<String> stagesList = new List<String>();
        List<String> vehicleTypeLst = new List<String>();
        stagesList = Report_Utils.Stages__c.split(';');
        vehicleTypeLst = Report_Utils.Vehical_Type__c.split(';');


        User userObj = [SELECT ContactId, Id
                        FROM User
                        WHERE Id = :currentUserId];
        List<Vehicle__c> vehList = [SELECT Id
                                    FROM Vehicle__c
                                    WHERE Venture_Partner__c = :userObj.ContactId AND Vehicle_Type__c IN:vehicleTypeLst];

        //userObj!= null
        if (userObj != null){

            List<Opportunity> oppList = [SELECT StageName, Closedate, createdDate, Account.Name, Round_Stage__c, Amount, AmountField__c, CreatedDate__c, FiscalQuarter, FiscalYear, Vehicle__r.Name, Fiscal_period__c, CloseDate__c
                                         FROM opportunity
                                         WHERE Venture_Partner__c = :userObj.ContactId  /* AND Vehicle__c!=null*/ AND Vehicle__c IN:vehList AND StageName IN:stagesList /* AND Vehicle__r.Vehicle_Type__c = 'VP-Angel' AND Vehicle__r.Vehicle_Type__c = 'VP-SPV'*/
                                         ORDER BY Vehicle__r.Name, StageName ASC];

            for (Opportunity oppItr : oppList){


                if (mainMapOfData.containsKey(oppItr.Vehicle__r.Name)){

                    // if exist in map || Stage Name
                    if (mainMapOfData.get(oppItr.Vehicle__r.Name).containsKey(oppItr.StageName)){

                        // new code
                        List<OppWrapper> oppExisting = mainMapOfData.get(oppItr.Vehicle__r.Name).get(oppItr.StageName);
                        OppWrapper oppWraObj = new OppWrapper(oppExisting.size() + 1, false, false, oppItr);
                        oppExisting[0].oppCount = oppExisting.size() + 1;
                        oppExisting.add(oppWraObj);
                        mainMapOfData.get(oppItr.Vehicle__r.Name).put(oppItr.StageName, oppExisting);

                    } else{

                        // if not exist in map || Stage Name
                        OppWrapper oppWraObj = new OppWrapper(1, false, false, oppItr);
                        List<OppWrapper> oppWraList = new List<OppWrapper>();
                        oppWraList.add(oppWraObj);
                        mainMapOfData.get(oppItr.Vehicle__r.Name).put(oppItr.StageName, oppWraList);

                    }

                    //System.debug('Stage '+mainMapOfData.get(oppItr.Vehicle__r.Name).keySet());


                } else{

                    // if not exists || Vehicle Name
                    List<OppWrapper> oppWraList = new List<OppWrapper>();
                    OppWrapper oppWraObj = new OppWrapper(1, false, false, oppItr);
                    oppWraList.add(oppWraObj);
                    Map<String, List<OppWrapper>> subMap = new Map<String, List<OppWrapper>>();
                    subMap.put(oppItr.StageName, oppWraList);
                    mainMapOfData.put(oppItr.Vehicle__r.Name, subMap);

                }
            }


            return resetMapValues(mainMapOfData);


        } else{
            return JSON.serialize(mainMapOfData);
        }
    }

    @AuraEnabled(cacheable = true)
    public static String getAngleSPVTotalRecords(string userId){

        Set<String> vehicleName = new Set<string>{ 'VP-Angel%', 'VP-SPV%' };
        User userContact = [SELECT ContactId, Id
                            FROM User
                            WHERE Id = :userId];
        List<Vehicle__c> vehList = [Select Id, Name
                                    FROM Vehicle__c
                                    WHERE Venture_Partner__c = :userContact.ContactId AND Vehicle_Type__c != 'Personal'];


        try{
            Integer totalRecords = [SELECT Count()
                                    FROM Opportunity 
                                    WHERE Venture_Partner__c = :userContact.ContactId AND Vehicle__c IN:vehList/*SubVehicle__r.Name LIKE :vehicleName */];
            //System.debug('totalRecords ::'+totalRecords);
            return JSON.serialize(totalRecords);
        } catch (Exception e){
            //System.debug(e);
            return '0';
        }
    }

    @AuraEnabled(cacheable = true)
    public static string getDataByFilter(String searchKey, String currentUserId){
        //System.debug('called SpvReportCtrl -> getSPVAngelReportData');
        Map<String, Map<String, List<OppWrapper>>> mainMapOfData = new Map<String, Map<String, List<OppWrapper>>>();

        List<String> stagesList = new List<String>();
        stagesList.add('Triaging');
        stagesList.add('Executing');
        stagesList.add('Closed Won');
        stagesList.add('Closed Lost');
        List<Opportunity> oppList;


        User userObj = [SELECT ContactId, Id
                        FROM User
                        WHERE Id = :currentUserId];
        List<Vehicle__c> vehList = [Select Id, Name
                                    FROM Vehicle__c
                                    WHERE Venture_Partner__c = :userObj.ContactId AND Vehicle_Type__c != 'Personal'];


        //userObj!= null
        if (userObj != null){
            if (searchKey != null && searchKey != ''){
                String key = '%' + searchKey + '%';
                String datekey = searchKey;
                String amount = searchKey;
                //System.debug('Search Key :'+key);

                oppList = [SELECT StageName, Closedate, createdDate, Account.Name, Round_Stage__c, Amount, AmountField__c, CreatedDate__c, FiscalQuarter, FiscalYear, Vehicle__r.Name, Fiscal_period__c, CloseDate__c
                           FROM opportunity
                           WHERE Venture_Partner__c = :userObj.ContactId AND Vehicle__c IN:vehList/*Vehicle__c!=null*/ AND StageName IN:stagesList AND (Account.Name LIKE:key OR Vehicle__r.Name LIKE:key OR Round_Stage__c LIKE:key OR AmountField__c LIKE:amount OR CreatedDate__c = :searchKey OR CloseDate__c = :searchKey OR Fiscal_period__c LIKE:key OR StageName LIKE:key)];
                //System.debug('Searched Data is :'+oppList);
            }

            //System.debug('Searched Data after loop :'+oppList);
            for (Opportunity oppItr : oppList){

                if (mainMapOfData.containsKey(oppItr.Vehicle__r.Name)){

                    // if exist in map || Stage Name
                    if (mainMapOfData.get(oppItr.Vehicle__r.Name).containsKey(oppItr.StageName)){

                        // new code
                        List<OppWrapper> oppExisting = mainMapOfData.get(oppItr.Vehicle__r.Name).get(oppItr.StageName);

                        OppWrapper oppWraObj = new OppWrapper(oppExisting.size() + 1, false, false, oppItr);
                        oppExisting[0].oppCount = oppExisting.size() + 1;
                        oppExisting.add(oppWraObj);
                        mainMapOfData.get(oppItr.Vehicle__r.Name).put(oppItr.StageName, oppExisting);

                    } else{

                        // if not exist in map || Stage Name
                        OppWrapper oppWraObj = new OppWrapper(1, false, false, oppItr);
                        List<OppWrapper> oppWraList = new List<OppWrapper>();
                        oppWraList.add(oppWraObj);
                        mainMapOfData.get(oppItr.Vehicle__r.Name).put(oppItr.StageName, oppWraList);

                    }

                    //System.debug('Stage '+mainMapOfData.get(oppItr.Vehicle__r.Name).keySet());

                } else{

                    // if not exists || Vehicle Name
                    List<OppWrapper> oppWraList = new List<OppWrapper>();
                    OppWrapper oppWraObj = new OppWrapper(1, false, false, oppItr);
                    oppWraList.add(oppWraObj);
                    Map<String, List<OppWrapper>> subMap = new Map<String, List<OppWrapper>>();
                    subMap.put(oppItr.StageName, oppWraList);
                    mainMapOfData.put(oppItr.Vehicle__r.Name, subMap);

                }
            }


            return resetMapValues(mainMapOfData);

        } else{
            return JSON.serialize(mainMapOfData);
        }
    }

    public static string resetMapValues(Map<String, Map<String, List<OppWrapper>>> mainMapOfData){

        List<String> VehNameLists = new List<String>();
        VehNameLists.addAll(mainMapOfData.keySet());
        VehNameLists.sort ();

        // reset values
        for (String VehicleName : VehNameLists){

            Map<String, List<OppWrapper>> submap = mainMapOfData.get(VehicleName);

            List<String> stageLists = new List<String>();
            stageLists.addAll(submap.keySet());
            stageLists.sort ();
            //List<String> stageLists  = (List);

            Integer j = 1;
            for (String stageName : stageLists){
                //System.debug('Stage '+stageName);
                list<OppWrapper> oppWraList = submap.get(stageName);
                oppWraList[0].needToShow = true; // To show Stages
                if (j == 1){
                    oppWraList[0].needToShowVeh = true;  // To show vehicle Names
                }
                j++;
            }

        }

        return JSON.serialize(mainMapOfData);
    }

    public class OppWrapper{
        public Opportunity oppObj;
        public Boolean needToShowVeh = false;
        public Boolean needToShow = false;
        public Integer oppCount;
        public String roundStage;
        public String bgColor;
        public OppWrapper(Integer oppCount, Boolean needToShowVeh, Boolean needToShow, Opportunity oppObj){
            this.needToShowVeh = needToShowVeh;
            this.oppCount = oppCount;
            this.needToShow = needToShow;
            this.oppObj = oppObj;
            if (oppObj.Round_Stage__c != null){
                this.bgColor = 'slds-badge bg-badge';
            } else{
                this.bgColor = '';
            }
        }

    }

}