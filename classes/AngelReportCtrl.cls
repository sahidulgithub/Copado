public class AngelReportCtrl{
  @AuraEnabled(cacheable = true)
  public static string getDataByFilter(String searchKey, String currentUserId){

    Map<string, List<OppWrapper>> oppStageMap = new Map<string, List<OppWrapper>>();
    User userObj = [SELECT ContactId, Id
                FROM User
                WHERE Id = :currentUserId];

    Report_Utils__c Report_Utils = [SELECT ID, Name, Stages__c, Vehical_Type__c
                                FROM Report_Utils__c
                                WHERE Name = 'Angel Report'
                                LIMIT 1];

    List<String> stagesList = new List<String>();
    List<String> vehicleTypeLst = new List<String>();
    stagesList = Report_Utils.Stages__c.split(';');
    vehicleTypeLst = Report_Utils.Vehical_Type__c.split(';');

    List<Vehicle__c> vehList = [SELECT Id
                            FROM Vehicle__c
                            WHERE Venture_Partner__c = :userObj.ContactId AND Vehicle_type__c IN:vehicleTypeLst];

    List<Opportunity> oppList;

    //System.debug('Size :: '+oppList.size());
    if (searchKey != null && searchKey != ''){
      String key = '%' + searchKey + '%';
      String datekey = searchKey;
      String amount = searchKey;
      oppList = [SELECT Amount, StageName, CreatedDate__c, CloseDate__c, AmountField__c, Round_Stage__c, Vehicle__r.Capacity__c, Account.Name
           FROM Opportunity
           WHERE Venture_Partner__c = :userObj.ContactId AND Vehicle__c IN:vehList AND StageName IN:stagesList AND (Account.Name LIKE:key OR AmountField__c LIKE:key OR Round_Stage__c LIKE:key OR SubVehicleCapacity__c LIKE:key OR CloseDate__c LIKE:key OR StageName LIKE:key OR CreatedDate__c LIKE:key)];
    }
    for (Opportunity oppItr : oppList){

      if (oppStageMap.containsKey(oppItr.StageName)){
        List<OppWrapper> oppExisting = oppStageMap.get(oppItr.StageName);

        OppWrapper oppWraObj = new OppWrapper(oppExisting.size() + 1, false, oppItr);
        oppExisting[0].oppCount = oppExisting.size() + 1;

        oppExisting.add(oppWraObj);
        oppStageMap.put(oppItr.StageName, oppExisting);

      } else{
        OppWrapper oppWraObj = new OppWrapper(1, true, oppItr);
        List<OppWrapper> oppWraList = new List<OppWrapper>();
        oppWraList.add(oppWraObj);
        oppStageMap.put(oppItr.StageName, oppWraList);

      }

    }

    return JSON.serialize(oppStageMap);
  }

  @AuraEnabled(cacheable = true)
  public static string getAngelDataMethod(String userId){
    try{
      Map<string, List<OppWrapper>> oppStageMap = new Map<string, List<OppWrapper>>();

      User userObj = [SELECT ContactId, Id
                FROM User
                WHERE Id = :userId];

      Report_Utils__c Report_Utils = [SELECT ID, Name, Stages__c, Vehical_Type__c
                                FROM Report_Utils__c
                                WHERE Name = 'Angel Report'
                                LIMIT 1];

      List<String> stagesList = new List<String>();
      List<String> vehicleTypeLst = new List<String>();
      stagesList = Report_Utils.Stages__c.split(';');
      vehicleTypeLst = Report_Utils.Vehical_Type__c.split(';');

      List<Vehicle__c> vehList = [SELECT Id
                            FROM Vehicle__c
                            WHERE Venture_Partner__c = :userObj.ContactId AND Vehicle_type__c IN:vehicleTypeLst];

      List<Opportunity> oppList = [SELECT Amount, StageName, CreatedDate__c, CloseDate__c, AmountField__c, Round_Stage__c, Vehicle__r.Capacity__c, Account.Name
                             FROM Opportunity
                             WHERE Venture_Partner__c = :userObj.ContactId AND Vehicle__c IN:vehList AND StageName IN:stagesList];

      System.debug('Size :: ' + oppList.size());
      for (Opportunity oppItr : oppList){

        if (oppStageMap.containsKey(oppItr.StageName)){
          List<OppWrapper> oppExisting = oppStageMap.get(oppItr.StageName);

          OppWrapper oppWraObj = new OppWrapper(oppExisting.size() + 1, false, oppItr);
          oppExisting[0].oppCount = oppExisting.size() + 1;

          oppExisting.add(oppWraObj);
          oppStageMap.put(oppItr.StageName, oppExisting);

        } else{
          OppWrapper oppWraObj = new OppWrapper(1, true, oppItr);
          List<OppWrapper> oppWraList = new List<OppWrapper>();
          oppWraList.add(oppWraObj);
          oppStageMap.put(oppItr.StageName, oppWraList);

        }

      }

      return JSON.serialize(oppStageMap);
    } catch (Exception e){
      throw new AuraHandledException(e.getMessage());
    }
  }

  public class MainWrapper{
    public List<OppWrapper> executingOppList;
    public SubTotalWrapper executingSubTotal;
    public List<OppWrapper> triagingOppList;
    public SubTotalWrapper triagingSubTotal;
    public List<OppWrapper> closedWonOppList;
    public SubTotalWrapper closedWonSubTotal;
    public FinalTotalWrapper finalTotalWrapper;
  }

  public class OppWrapper{
    public Opportunity oppObj;
    public Boolean needToShow;
    public Integer oppCount;
    public String bgColor;
    public String roundStage;
    public Boolean isOpportunity;
    public Boolean isSubTotal;
    public OppWrapper(Integer oppCount, Boolean needToShow, Opportunity oppObj){
      this.oppObj = oppObj;
      this.oppCount = oppCount;
      this.needToShow = needToShow;
      this.isOpportunity = true;
      this.isSubTotal = false;
      if (oppObj.Round_Stage__c != null){
        this.roundStage = oppObj.Round_Stage__c;
        bgColor = 'slds-badge bg-badge';
      } else{
        this.roundStage = '';
      }
    }

  }

  public class SubTotalWrapper{
    public Decimal subTotal = 0.00;
    public Decimal subCapacity = 0.00;
    public Decimal subRemaining = 0.00;
    public Decimal subtotalCloseWonAmount = 0.00;
    public Decimal subtotalTriagingAmount = 0.00;
    public Decimal subtotalExecutingAmount = 0.00;
  }

  public class FinalTotalWrapper{
    public Decimal finalsubTotal = 0.00;
    public Decimal finalsubCapacity = 0.00;
    public Decimal finalsubRemaining = 0.00;
  }

}