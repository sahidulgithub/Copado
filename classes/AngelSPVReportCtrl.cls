public class AngelSPVReportCtrl {
  @AuraEnabled(cacheable=true)
    public static string getSPVAngelReportData1(String currentUserId){
		System.debug('called SpvReportCtrl -> getSPVAngelReportData');
        Map<String,Map<String,List<OppWrapper>>> mainMapOfData = new Map<String,Map<String,List<OppWrapper>>>(); 
        /*Set<String> vName = new Set<string> ();
        vName.add('VP-Angel%');
        vName.add('VP-SPV%');*/

       List<String> stagesList = new List<String>();
        stagesList.add('Triaging');
       
        stagesList.add('Executing');
        stagesList.add('Closed Won');
        stagesList.add('Closed Lost');
        

        User userObj = [SELECT ContactId,Id FROM User WHERE Id =:currentUserId];
		//userObj!= null
        if(userObj!= null){
            
            List<Opportunity> oppList   = [SELECT StageName,Closedate,createdDate,Account.Name,Round_Stage__c,Amount,FiscalQuarter, FiscalYear,Vehicle__r.Name ,Fiscal_period__c ,CloseDate__c, SubVehicle__r.Name FROM opportunity WHERE Venture_Partner__c =:userObj.ContactId  /*Venture_Partner__r.Id  = '003Ei000000ut6hIAA'*/  /*AND  SubVehicle__r.Name !=NULL*/AND SubVehicle__r.Name Like 'VP%' /* AND StageName IN:stagesList*/  ];
			
            Integer listSize  = oppList.size();
			Integer loopCount = 1;
            for(Opportunity oppItr : oppList){
                // if exist in map || Vehicle Name
                Boolean needToshowVehName = true;
                   

                if(mainMapOfData.containsKey(oppItr.SubVehicle__r.Name)){
                    needToshowVehName = false;
                    //System.debug(needToshowVehName+' %% veh Name if'+oppItr.Vehicle__r.Name+' exist '+mainMapOfData.containsKey(oppItr.Vehicle__r.Name)+' stage '+oppItr.StageName);
                } 
			                
                if(mainMapOfData.containsKey(oppItr.SubVehicle__r.Name)){
                     
                    // if exist in map || Stage Name
                    if(mainMapOfData.get(oppItr.SubVehicle__r.Name).containsKey(oppItr.SubVehicle__r.Name)){
						
                        
                        
                        // new code
                        List<OppWrapper> oppExisting = mainMapOfData.get(oppItr.SubVehicle__r.Name).get(oppItr.StageName);
                    
                        OppWrapper oppWraObj = new OppWrapper(oppExisting.size()+1,needToshowVehName,false,oppItr);
                        
                        oppExisting[0].oppCount = oppExisting.size()+1;
            
                        oppExisting.add(oppWraObj);
                        mainMapOfData.get(oppItr.SubVehicle__r.Name).put(oppItr.StageName,oppExisting);
                        
                        
                        
                    }else{                         

                        // if not exist in map || Stage Name
                        OppWrapper oppWraObj            = new OppWrapper(1,needToshowVehName,true,oppItr);
                        List<OppWrapper>  oppWraList    = new List<OppWrapper>();
                        oppWraList.add(oppWraObj); 
                        mainMapOfData.get(oppItr.SubVehicle__r.Name).put(oppItr.StageName,oppWraList);
                        
                    } 
                     
                    //System.debug('Stage '+mainMapOfData.get(oppItr.Vehicle__r.Name).keySet()); 

                
                }else{
                     
                    // if not exists || Vehicle Name
                    List<OppWrapper>  oppWraList             = new List<OppWrapper>();
                    OppWrapper oppWraObj                     = new OppWrapper(1,needToshowVehName,true,oppItr);
                    oppWraList.add(oppWraObj);
                    Map<String,List<OppWrapper>> subMap      = new Map<String,List<OppWrapper>>();
                    subMap.put(oppItr.StageName,oppWraList);
                    mainMapOfData.put(oppItr.SubVehicle__r.Name,subMap);
                    
                }
                		
                
                		// for resetting value of showing vehicle
                		if(listSize == loopCount){
                            //system.debug('first If Count Matched '+loopCount+' at stage '+oppItr.StageName);
                            //loop for get all keys
                            Set<String> proccessedStageList = mainMapOfData.get(oppItr.SubVehicle__r.Name).keySet();
                            //System.debug('stage '+proccessedStageList);
                    		//System.debug('Veh Name '+oppItr.Vehicle__r.Name);
                    		Boolean isValueAssigned = false;
                            for(String str : proccessedStageList){
                                List<OppWrapper> getExistingOppList = mainMapOfData.get(oppItr.SubVehicle__r.Name).get(str);
                                for(OppWrapper oppWra : getExistingOppList){
                                    //System.debug(str+' for show val '+oppWra.needToShowVeh+' count '+oppWra.oppCount+' & '+oppWra.needToShow+' for stage '+oppWra.oppObj.StageName);
                                    //oppWra.needToShowVeh = false;
                                    if(oppWra.needToShow && oppWra.needToShowVeh){
                                        oppWra.needToShowVeh = false;
                                    }else{
                                        if(!oppWra.needToShow && !oppWra.needToShowVeh){
                                            oppWra.needToShowVeh = false;
                                        }else{
                                            if(!isValueAssigned && (oppItr.StageName == str)){
                                                oppWra.needToShowVeh = true;
                                               isValueAssigned = true; 
                                            }
											
                                        }
                                        
                                    }
                                    //System.debug('After show val '+oppWra.needToShowVeh+' & '+oppWra.needToShow+' for stage '+oppWra.oppObj.StageName);
                                    
                                }
                            }
                        }
                loopCount++;
                 
            }
            
            system.debug(mainMapOfData);
            return JSON.serialize(mainMapOfData); 

        }else{
            return JSON.serialize(mainMapOfData);
        }
        
        
        
    }
    public class OppWrapper{
        public Opportunity oppObj;
        public Boolean needToShowVeh = false;
        public Boolean needToShow = false;
        public Integer oppCount;
        public String closedate;
        public date createddate;
        public string createdate;
        public OppWrapper(Integer oppCount, Boolean needToShowVeh ,Boolean needToShow, Opportunity oppObj){
            this.needToShowVeh = needToShowVeh;
            this.oppCount   = oppCount;
            this.needToShow = needToShow;
            this.oppObj 	= oppObj;
            if(oppObj.Round_Stage__c == null){
                oppObj.Round_Stage__c = ' ';
               
            } 
            Date d1 = oppObj.Closedate;
                this.closedate = DateTime.newInstance(d1.year(),d1.month(),d1.day()).format('MM/dd/YYYY');
           
            this.createddate= oppObj.CreatedDate.date();
            this.createdate= DateTime.newInstance(createddate.year(),createddate.month(),createddate.day()).format('MM/dd/YYYY');
        }
    }







}