@Istest
public class CaseTriggerhandlerTest {
    @testSetup static void testSetupMethod() {
        
        
        Profile pr = [SELECT id FROM Profile WHERE Name = 'Standard User'];
        User user1 = new User();
        user1.Alias = 'tcase';
        user1.Email = 'tcase@gmail.com';
        user1.Username = 'somyajain98765@gmail.com';
        user1.EmailEncodingKey = 'UTF-8';
        user1.LanguageLocaleKey = 'en_US';
        user1.LastName = 'Case Lastname';
        user1.FirstName = 'Test';
        user1.LocaleSidKey = 'en_US';
        user1.ProfileId = pr.Id;
        user1.TimeZoneSidKey = 'America/Los_Angeles';
        insert user1;
        
        PermissionSet getPerm = [SELECT Id FROM PermissionSet WHERE Name = 'Case_Admin' LIMIT 1];
        PermissionSetAssignment assignPerm = new PermissionSetAssignment();
        assignPerm.AssigneeId = user1.Id;
        assignPerm.PermissionSetId = getPerm.Id;
        insert assignPerm;
        System.runas(user1) {
            List<Case> caseList = new List<Case>();
            case each = new case();
            each.origin = 'email';
            each.type ='Problem';
            each.Priority = 'High';
            each.Description = 'Test';
            caseList.add(each);
            
            Case eachCase = new Case();
            eachCase.origin = 'email';
            eachCase.type ='Other';
            eachCase.Priority = 'High';
            eachCase.Description = 'Test';
            caseList.add(eachCase);
            
            Case eachCase1 = new Case();
            eachCase1.origin = 'email';
            eachCase1.type ='Structural';
            eachCase1.Priority = 'High';
            eachCase1.Description = 'Test';
            caseList.add(eachCase1);
            
            Case eachCase2 = new Case();
            eachCase2.origin = 'email';
            eachCase2.type ='Problem';
            eachCase2.Priority = 'High';
            eachCase2.Description = 'Test';
            caselist.add(eachcase2);
            
            insert caseList;
        }
    }
    @isTest
    static void testNcCreatedWhenCaseCreatedIfTypeIsProblem() {
        User us = [SELECT Id FROM User WHERE UserName = 'somyajain98765@gmail.com'];
        System.runAs(us) {
            List<case> caselist = [select id,subject,priority,description,caseNumber,SQX_NC_Reference__c from case where type = 'Problem' LIMIT 1];
            System.assert(caselist.size() > 0, 'Case should be created');
            
            List<SQX_Nonconformance__c> nonconlist = [select id,Title__c,Priority__c,Description__c,QMS_Reference_Number__c from SQX_Nonconformance__c where QMS_Reference_Number__c =: caselist[0].caseNumber];
            system.assert(nonconlist.size()>0,'NonConformance should be created when case type is problem');
            
            System.assert(caselist[0].SQX_NC_Reference__c == nonconlist[0].Id, 'Non-conformance should be associated if case is created as type problem');
            System.assert(caselist[0].Subject == nonconlist[0].title__c, 'Non-conformance title is same as case subject');
            System.assert(caselist[0].priority == nonconlist[0].Priority__c, 'Non-conformance Priority is same as case Priority');
            System.assert(caselist[0].description == nonconlist[0].Description__c, 'Non-conformance description is same as case description');
            System.assert(caselist[0].caseNumber == nonconlist[0].QMS_Reference_Number__c, 'Non-conformance QMS_Reference_Number__c is same as case caseNumber');
        }
    }
    @isTest
    static void testNcCreatedWhenCaseUpdatedIfTypeIsProblem() {
        User us = [SELECT Id FROM User WHERE UserName = 'somyajain98765@gmail.com'];
        System.runAs(us) {
            List<case> caselist = [select id,subject,priority,description,caseNumber,Type, SQX_NC_Reference__c from case where type = 'Other' LIMIT 1];
            System.assert(caselist.size() > 0, 'Case should be created');
            
            caselist[0].Type = 'Problem';
            update caselist;
            
            List<SQX_Nonconformance__c> nonconlist = [select id,Title__c,Priority__c,Description__c,QMS_Reference_Number__c from SQX_Nonconformance__c where QMS_Reference_Number__c =: caselist[0].caseNumber];
            system.assert(nonconlist.size()>0,'NonConformance should be created when case type is problem');
            
            List<case> caselist1 = [select id,caseNumber,Type, SQX_NC_Reference__c from case where Id=:caselist[0].Id];
            System.assert(caselist1[0].SQX_NC_Reference__c == nonconlist[0].Id, 'Non-conformance should be associated if case is updated as type problem');
            System.assert(caselist[0].Subject == nonconlist[0].title__c, 'Non-conformance title is same as case subject');
            System.assert(caselist[0].priority == nonconlist[0].Priority__c, 'Non-conformance Priority is same as case Priority');
            System.assert(caselist[0].description == nonconlist[0].Description__c, 'Non-conformance description is same as case description');
            System.assert(caselist[0].caseNumber == nonconlist[0].QMS_Reference_Number__c, 'Non-conformance QMS_Reference_Number__c is same as case caseNumber');
            
        }
    }
    @isTest
    static void testIfNCAlreadyCreatedAgainstCaseThenDoNotCreateAgain() {
        User us = [SELECT Id FROM User WHERE UserName = 'somyajain98765@gmail.com'];
        System.runAs(us) {
            List<case> caselist = [select id,caseNumber,Type, SQX_NC_Reference__c from case where type = 'Problem' LIMIT 1];
            System.assert(caselist.size() > 0, 'Case should be created');
            System.assert(caselist[0].SQX_NC_Reference__c != null, 'NC reference should be attached to Case');
            
            caselist[0].Type= 'Other';
            update caselist;
            
            caseList[0].Type = 'Problem';
            update caselist;
            
            List<SQX_Nonconformance__c> nonconlist = [select id,QMS_Reference_Number__c from SQX_Nonconformance__c where QMS_Reference_Number__c =: caselist[0].caseNumber];
            System.assert(nonconlist.size() == 1, 'NC should not be created if already exists');
        }
    }
    
    @isTest
    static void testNCisAttachedtoCaseNotCreateAgain() {
        User us = [SELECT Id FROM User WHERE UserName = 'somyajain98765@gmail.com'];
        System.runAs(us) {
            
            List<case> caselist = [select id,caseNumber,Type, SQX_NC_Reference__c from case where type = 'Problem' LIMIT 1];
            System.assert(caselist.size() > 0, 'Case should be created');
            System.assert(caselist[0].SQX_NC_Reference__c != null, 'NC reference should be attached to Case');
            SQX_Nonconformance__c NCobj = new SQX_Nonconformance__c(Title__c ='testdata', QMS_Reference_Number__c = caselist[0].caseNumber);
            try{
                insert NCobj;
            }catch(exception ex){
                system.assert(ex.getmessage().contains('NonConformance is already associated with this case Numbe'),'Nc is craeted');
            }
            
            
        }
    }
    @isTest
    static void testIfUserNotassignedInPermissionSet() {
        User us = [SELECT Id FROM User WHERE UserName = 'somyajain98765@gmail.com'];
        PermissionSet getPerm = [SELECT Id FROM PermissionSet WHERE Name = 'Case_Admin' LIMIT 1];
        List<permissionSetAssignment> assignPerm =[select id from PermissionSetAssignment where assigneeId =: us.id and  PermissionSetId =:getPerm.id ];
        System.assert(assignPerm.size() > 0, 'permission set assignemnent should not be empty');
        delete assignPerm;
        System.runAs(us) {
            List<case> caselist = [select id,caseNumber,Type, SQX_NC_Reference__c from case where type = 'Structural' LIMIT 1];
            System.assert(caselist.size() > 0, 'Case should be created');
            
            SQX_Nonconformance__c NCobj = new SQX_Nonconformance__c(Title__c ='testdata', QMS_Reference_Number__c = caselist[0].caseNumber);
            try{
                insert NCobj;
            }catch(exception ex){
                system.assert(ex.getmessage().contains('Insufficient access of this object'),'Nc is created');
            }
            
            try{
                caseList[0].Type = 'Problem';
                update caselist;
            }catch(exception ex){
                System.assert(ex.getmessage().contains('Insufficient access of this object'),'case is updated' );
            }
            
        }
    }
    @isTest
    static void testwhenCaseIsCreatedIdNCIsalreadyAttachedwithCase(){
        User us = [SELECT Id FROM User WHERE UserName = 'somyajain98765@gmail.com'];
        System.runAs(us) {
            
            List<case> caselist = [select id,subject,priority,description,caseNumber,SQX_NC_Reference__c from case where type = 'Problem' ];
            System.assert(caselist.size() > 1, 'Case should be created');
            
            List<SQX_Nonconformance__c> nonconlist = [select id,Title__c,Priority__c,Description__c,QMS_Reference_Number__c from SQX_Nonconformance__c where QMS_Reference_Number__c =: caselist[0].caseNumber];
            system.assert(nonconlist.size()>0,'NonConformance should be created when case type is problem');
            
            
            Case eachCase = new Case();
            eachCase.origin = 'email';
            eachCase.type ='Problem';
            eachCase.Priority = 'High';
            eachCase.Description = 'Test';
            eachcase.SQX_NC_Reference__c = nonconlist[0].Id;
            
            try{
                insert eachCase;
            }catch(exception ex){
                System.assert(ex.getmessage().contains('this Nc Reference is already associated with another case'),'case is Created' );
                
            }
            try{
                caseList[0].SQX_NC_Reference__c = caseList[1].SQX_NC_Reference__c;
                update caselist[0];
            }catch(exception ex){
                System.assert(ex.getmessage().contains('this Nc Reference is already associated with another case'),'case is Created' );
                
            }
            
        }
    }
    
    
    
}