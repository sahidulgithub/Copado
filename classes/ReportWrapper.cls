public class ReportWrapper {


    @AuraEnabled(cacheable=true)
    public static String getSPVTotalRecords(string userId){
        User userContact=[SELECT ContactId,Id FROM User WHERE Id =:userId];
        List<Vehicle__c> vehList = [Select Id, Name FROM Vehicle__c WHERE Venture_Partner__c =:userContact.ContactId  AND Vehicle_type__c = 'VP-SPV'];
        try{
            
            Integer totalRecords=[SELECT Count() FROM Opportunity WHERE Venture_Partner__c=:userContact.ContactId AND Vehicle__c IN:vehList ];
            system.debug('totalRecords ::'+totalRecords);
            return JSON.serialize(totalRecords);
        }
        catch(Exception e){
            System.debug(e);
            return '0';
        }

    }

    @AuraEnabled(cacheable=true)
    public static String getAngleTotalRecords(string userId){
        List<String> stagesList=new List<String>();
            stagesList.add('Triaging');
            stagesList.add('Executing');
            stagesList.add('Closed Won');

        User userContact=[SELECT ContactId,Id FROM User WHERE Id =:userId];
        try{
          
            Integer totalRecords=[SELECT Count() FROM Opportunity WHERE Venture_Partner__c=:userContact.ContactId AND StageName IN:stagesList AND Vehicle__r.Vehicle_Type__c = 'VP-Angel' ];
            system.debug('totalRecords ::'+totalRecords);
            return JSON.serialize(totalRecords);
        }
        catch(Exception e){
            System.debug(e);
            return '0';
        }

    }

    @AuraEnabled(cacheable=true)
    public static String getAngleSumAmount(string userId){
            User userObj=[SELECT ContactId,Id FROM User WHERE Id =:userId];
            List<Vehicle__c> vehList   = [SELECT Id, Name FROM Vehicle__c WHERE Venture_Partner__c =:userObj.ContactId  AND Vehicle_type__c 
            = 'VP-Angel'];
        try{
          
           AggregateResult sumAmount=[SELECT Sum(Amount) FROM Opportunity WHERE Venture_Partner__c= : userObj.ContactId AND Vehicle__c IN : vehList ];
            system.debug('totalRecords ::'+sumAmount);
            return JSON.serialize(sumAmount.get('expr0'));
        }
        catch(Exception e){
            System.debug(e);
            return '0';
        }

    }


    @AuraEnabled(cacheable=true)
    public static String getAngleSumSubVehicleCapacity(string userId){
 
            // stagesList.add('Decisioning');

        User userObj=[SELECT ContactId,Id FROM User WHERE Id =:userId];
        List<Vehicle__c> vehList   = [Select Id, Name FROM Vehicle__c WHERE Venture_Partner__c =:userObj.ContactId  AND Vehicle_type__c 
        = 'VP-Angel'];
        try{
          
            AggregateResult sumCapacity=[SELECT SUM(Vehicle__r.Capacity__c) FROM Opportunity WHERE Venture_Partner__c= : userObj.ContactId AND Vehicle__c IN : vehList ];
            system.debug('sumCapacity ::'+sumCapacity);
            return JSON.serialize(sumCapacity.get('expr0'));
        }
        catch(Exception e){
            System.debug(e);
            return '0';
        }

    }
    
    

        @AuraEnabled(cacheable=true)
        public static String getOpportunityData(string userId){
            List<wrapperClass> mainwrapList=new List<wrapperClass>();
            User u=[SELECT ContactId,Id FROM User WHERE Id =:userId];
            try{
                List<Opportunity> oppList=[SELECT Id, Name,Amount,StageName,Closedate,createdDate,Round_Stage__c,Vehicle__r.Capacity__c,Account.Name FROM Opportunity
                                           WHERE Venture_Partner__c=:u.ContactId AND Vehicle__r.Vehicle_Type__c = 'VP-Angel' ];
                Integer i=1;
                if(!oppList.isEmpty()) {
                    for(Opportunity oppItr:oppList){
                        // if(oppItr.CloseDate!= null){
                        //     Date d1 = oppItr.CloseDate;                       
                        //     closedate = DateTime.newInstance(d1.year(),d1.month(),d1.day()).format('MM/dd/YYYY');
                        // }
                        // if(oppItr.Amount!= null){
                        //     decimal amt=oppItr.Amount;
                        //     Amount =amt.setScale(2);
                        // }
                        wrapperClass wrapObj=new wrapperClass(
                            i,
                            oppItr.Amount,
                            oppItr.StageName,
                            oppItr.Closedate,
                            oppItr.createdDate,
                            oppItr.Round_Stage__c,
                            oppItr.Vehicle__r.Capacity__c,
                            oppItr.Account.Name
                        );
                        
                        mainwrapList.add(wrapObj);
                        i++;
                        
                    }
                }
                return JSON.serialize(mainwrapList);
            } 
            catch (Exception e) {
                throw new  AuraHandledException(e.getMessage());
            }
        } 
        
        @AuraEnabled(cacheable=true)
        public static Map<String, List<Opportunity> > getOpportunity(){
            List<mainWrapper> wrapperList=new  List<mainWrapper>();
            List<Opportunity> oppList=[SELECT Id, Name,Amount,StageName,Closedate FROM Opportunity  WHERE Venture_Partner__r.Id   = '003Ei000000ut6hIAA'];
            Map<string, List<Opportunity> > oppStage = new Map<string, List<Opportunity>>();
            List<Opportunity> opp=new List<Opportunity>();
            for(Opportunity oppItr:oppList){
                
                opp.add(oppItr);
                oppStage.put(oppItr.StageName,opp);
                // for(String stageName: oppStage.key()){
                //     mainWrapper wrapObj=new mainWrapper();
                // }
                
            }
            return oppStage;
        }
        
        public class mainWrapper{
            
            @AuraEnabled   
            public String name;
            @AuraEnabled   
            public String amount;
            @AuraEnabled   
            public String stagename ;
            @AuraEnabled   
            public string createddate;
            @AuraEnabled   
            public String venturepartnerName ;
            @AuraEnabled   
            public String vehicleName ;
            @AuraEnabled   
            public Integer fiscalyear ;
            @AuraEnabled   
            public Integer fiscalQuarter ;
            @AuraEnabled   
            public List<Opportunity> listOpp;
            public mainWrapper(){
                
            }
        }
        
        public class wrapperClass{
            
            @AuraEnabled   
            public String amount;
            @AuraEnabled   
            public String stagename ;
            @AuraEnabled   
            public Datetime createddate;
            @AuraEnabled   
            public Date closedate ;
            @AuraEnabled   
            public String roundstage ;
            @AuraEnabled   
            public String vehiclecapacity ;
            @AuraEnabled   
            public String accountname ;
            @AuraEnabled   
            public List<Opportunity> listOpp;
            
            public wrapperClass(Integer i,Decimal amount,String stagename,Date closedate,Datetime createddate,String roundstage,Decimal vehiclecapacity,String accountname){
                
                this.accountname=accountname;
                if(amount!=null){
                    this.amount='$'+amount;
                }else{ this.amount=''; }
                this.stagename=stagename;
                this.closedate=closedate;
                this.createddate=createddate;
                this.roundstage=roundstage;
                if(vehiclecapacity!=null){
                    this.vehiclecapacity='$'+vehiclecapacity;
                }else{
                    this.vehiclecapacity='';
                }
                
                
                
            }
            
        }
        
        @AuraEnabled(cacheable=true)
        public static string getAngleData(string userId){
            List<String> stagesList=new List<String>();
            stagesList.add('Triaging');
            stagesList.add('Executing');
            stagesList.add('Closed Won');
            stagesList.add('Staging');
            stagesList.add('Contacted');
            stagesList.add('Winning');
            stagesList.add('Scheduling');
            stagesList.add('Scheduled');
            stagesList.add('Diligencing');
            stagesList.add('Circled');
            stagesList.add('Committed');
            stagesList.add('Decisioning');
            
            Map<string, List<OppWrapper>> oppStageMap = new Map<string, List<OppWrapper>>();

            // Map<string,Map<List<OppWrapper>,List<subTotalWrapper>>> oppMainStageMap = new Map<string, Map<List<OppWrapper>,List<subTotalWrapper>>>();
            //OppMainWrapper   oppMain                   = new OppMainWrapper();
            
            User userObj                            = [SELECT ContactId,Id FROM User WHERE Id =:userId];
            
            List<Opportunity> oppList               = [SELECT Amount,StageName,Closedate,CreatedDate,Round_Stage__c,Vehicle__r.Capacity__c,Account.Name  FROM Opportunity  WHERE Venture_Partner__r.Id   =: userObj.ContactId
                                                      AND StageName !='Closed Lost'];
            
            
            for(Opportunity oppItr : oppList){                 
                
                if(oppStageMap.containsKey(oppItr.StageName)){
                    List<OppWrapper> oppExisting = oppStageMap.get(oppItr.StageName);
                    OppWrapper oppWraObj = new OppWrapper(oppExisting.size()+1,false,oppItr);
                    oppExisting[0].oppCount = oppExisting.size()+1;

                    oppExisting.add(oppWraObj);
                    oppStageMap.put(oppItr.StageName,oppExisting);
                    
                    //oppMain.stage   = oppItr.StageName;
                    //oppMain.oppList = oppExisting;
                }
                else{     
                    OppWrapper oppWraObj = new OppWrapper(1,true,oppItr);
                    List<OppWrapper>  oppWraList             = new List<OppWrapper>();
                    oppWraList.add(oppWraObj);
                    oppStageMap.put(oppItr.StageName,oppWraList);
                    
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
                this.stage      = stage;
                this.oppCount   = oppList.size();
                this.oppList    = oppList;
            }
        }
        
        public class OppWrapper{
            public Opportunity oppObj;
            public Boolean needToShow;
            public Integer oppCount;
            public String closedate;
            public date createddate;
            public string createdate;
            public Decimal capacity;
            public Decimal sumcapacity;
            public Decimal sumAmount;
            public OppWrapper(Integer oppCount, Boolean needToShow,Opportunity oppObj){
                this.oppCount   = oppCount;
                this.needToShow = needToShow;
                this.oppObj 	= oppObj;
                Date d1 = oppObj.Closedate;
                this.closedate = DateTime.newInstance(d1.year(),d1.month(),d1.day()).format('MM/dd/YYYY');
                   this.createddate= oppObj.CreatedDate.date();
                    this.createdate= DateTime.newInstance(createddate.year(),createddate.month(),createddate.day()).format('MM/dd/YYYY');
                //    this.closedate= oppObj.Closedate;
                // }
                this.capacity= oppObj.Vehicle__r.Capacity__c;
                //this.sumAmount=sumAmount;
               // this.sumAmount=  this.sumAmount+oppObj.Amount;
            //    this.sumcapacity+=oppObj.Vehicle__r.Capacity__c;
                if(oppObj.Round_Stage__c == null){
                    oppObj.Round_Stage__c = 'NA';
                } 
                // if(oppObj.Vehicle__r.Capacity__c!=null){
                //     oppObj.Vehicle__r.Capacity__c = 0.00;
                // }
                
            }
        }


    }