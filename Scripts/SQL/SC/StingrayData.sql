--EXEC stng.SP_Admin_CreateAppSecurity @Module='Admin',@Name='EmailFeedback',@Type='EmailFeedback',@CreatedBy='619704',@Description=''

EXEC stng.SP_Admin_CreateAppSecurity @Module='ETDB',@Name='ShowInternal',@Type='Data',@CreatedBy='619704',@Description='Hide or view internal records.';
EXEC stng.SP_Admin_CreateAppSecurity @Module='ETDB',@Name='CreateTDS',@Type='Button',@CreatedBy='619704',@Description='Enable the Create TDS button. A button will be visible on the module header'
EXEC stng.SP_Admin_CreateAppSecurity @Module='ETDB',@Name='Assigned',@Type='Dropdown',@CreatedBy='619704',@Location='TDS Assigned column & expanded view > Details tab',@Description='A dropdown list to assign a person to the TDS.'
EXEC stng.SP_Admin_CreateAppSecurity @Module='ETDB',@Name='EditTDS',@Type='Dropdown',@CreatedBy='619704',@Description='Enable ability to edit a TDS. A button will be visible on the module header'
EXEC stng.SP_Admin_CreateAppSecurity @Module='ETDB',@Name='TempusPick',@Type='Dropdown',@CreatedBy='619704',@Description=''
EXEC stng.SP_Admin_CreateAppSecurity @Module='ETDB',@Name='EmergentTicket',@Type='Dropdown',@CreatedBy='619704',@Description='A button to create an emergent ticket'
EXEC stng.SP_Admin_CreateAppSecurity @Module='ETDB',@Name='TDSHours',@Type='InputText',@CreatedBy='619704',@Description='Ability to edit TDS hours.'
EXEC stng.SP_Admin_CreateAppSecurity @Module='ETDB',@Name='TDSStatus',@Type='Dropdown',@CreatedBy='619704',@Description='A dropdown list to change the TDS status.'
EXEC stng.SP_Admin_CreateAppSecurity @Module='ETDB',@Name='NeedDate',@Type='Calendar',@CreatedBy='619704',@Description='Ability to chage the TDS need date.'
EXEC stng.SP_Admin_CreateAppSecurity @Module='ETDB',@Name='DetailState',@Type='Dropdown',@CreatedBy='619704',@Location='Expanded view > Details tab', @Description='Ability to change the Scope detail state.'
EXEC stng.SP_Admin_CreateAppSecurity @Module='ETDB',@Name='DetailEstimatedHours',@Type='InputNumber',@CreatedBy='619704',@Location='Expanded view > Details tab', @Description='Ability to change the Scope detail estimated hours.'
EXEC stng.SP_Admin_CreateAppSecurity @Module='ETDB',@Name='DetailActualHours',@Type='InputNumber',@CreatedBy='619704',@Location='Expanded view > Details tab', @Description='Ability to change the Scope detail actual hours.'
EXEC stng.SP_Admin_CreateAppSecurity @Module='ETDB',@Name='Issues',@Type='Dropdown',@CreatedBy='619704',@Location='Issues column on TDS', @Description='Ability to flag TDS as issues.'
EXEC stng.SP_Admin_CreateAppSecurity @Module='ETDB',@Name='IssuesSD',@Type='Dropdown',@CreatedBy='619704',@Location='Expanded view > Details tab', @Description='Ability to flag Scope detail as issues.'
EXEC stng.SP_Admin_CreateAppSecurity @Module='ETDB',@Name='EditDeleteComment',@Type='Button',@CreatedBy='619704',@Location='Scope Detail comment card', @Description='Ability to delete a comment after 1 day.'
EXEC stng.SP_Admin_CreateAppSecurity @Module='ETDB',@Name='ShowCommitmentDate',@Type='Column',@CreatedBy='619704',@Location='ETDB active and archive page',@Description='Display the commitment date column by default, otherwise select from column chooser.'

EXEC stng.SP_Admin_CreateAppSecurity @Module='CARLA',@Name='StatusOptions',@Type='Dropdown',@CreatedBy='619704',@Description='A dropdown list to change the CSQ status'
EXEC stng.SP_Admin_CreateAppSecurity @Module='CARLA',@Name='CSQCategory',@Type='Dropdown',@CreatedBy='619704',@Description='A dropdown list to change the CSQ category'
EXEC stng.SP_Admin_CreateAppSecurity @Module='CARLA',@Name='CSQDate',@Type='Calendar',@CreatedBy='619704',@Description='Ability to actualize a CSQ finish date if you are NOT an Eng-Tech and NOT the commitment owner.'
EXEC stng.SP_Admin_CreateAppSecurity @Module='CARLA',@Name='CSQDateEngTech',@Type='Calendar',@CreatedBy='619704',@Description='Allow an Eng-Tech commitment owner to actualize a CSQ finish date'
EXEC stng.SP_Admin_CreateAppSecurity @Module='CARLA',@Name='CSQRevisedDate',@Type='Calendar',@CreatedBy='619704',@Description='Change the revised date on the CSQ'
EXEC stng.SP_Admin_CreateAppSecurity @Module='CARLA',@Name='CSQStatus',@Type='Dropdown',@CreatedBy='619704',@Description='A dropdown to update the CSQ status'
EXEC stng.SP_Admin_CreateAppSecurity @Module='CARLA',@Name='FinishDate',@Type='Calendar',@CreatedBy='619704',@Description='Ability to actualize and update finish dates.'
EXEC stng.SP_Admin_CreateAppSecurity @Module='CARLA',@Name='ScheduleUpdateEmail',@Type='Button',@CreatedBy='619704',@Description='A button to download a .msg template file that can be opened in outlook.'
EXEC stng.SP_Admin_CreateAppSecurity @Module='CARLA',@Name='ScopeDetail',@Type='Button',@CreatedBy='619704',@Description='A button to Add & Edit scope numbers, ie PR, CR, Contract, PO, RFQ, RFP, WO, TDS'
EXEC stng.SP_Admin_CreateAppSecurity @Module='CARLA',@Name='StartDate',@Type='Calendar',@CreatedBy='619704',@Description='Ability to actualize and update start dates.'
EXEC stng.SP_Admin_CreateAppSecurity @Module='CARLA',@Name='EditDeleteComment',@Type='Button',@CreatedBy='619704',@Description='Ability to delete a comment after the 1 day limit.'

EXEC stng.SP_Admin_CreateAppSecurity @Module='Admin',@Name='SysAdmin',@Type='System',@Location='System',@CreatedBy='619704',@Description='This will grant access to the entire Stingray Application.'
EXEC stng.SP_Admin_CreateAppSecurity @Module='Admin',@Name='UserManagementTabs',@Type='Tab',@CreatedBy='619704',@Description='Navigate and view all UserManagement tabs.'
EXEC stng.SP_Admin_CreateAppSecurity @Module='Admin',@Name='ModuleOwner',@Type='ModuleOwner',@CreatedBy='619704',@Description='To give access to User Management and ability to approve module access requests.'
EXEC stng.SP_Admin_CreateAppSecurity @Module='Admin',@Name='OverrideEmail',@Type='ModuleAccessRequest',@CreatedBy='619704',@Description='Override sending module access request emails. By default, 
emails are sent to Module Owners, use this to prevent email being sent.'

EXEC stng.SP_Common_CreateValueLabel @Module='CARLA',@Group='CSQ',@Name='Status',@Label='On Track',@Sort=1,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='CARLA',@Group='CSQ',@Name='Status',@Label='At Risk',@Sort=2,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='CARLA',@Group='CSQ',@Name='Status',@Label='Complete',@Sort=3,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='CARLA',@Group='CSQ',@Name='Status',@Label='Push Required',@Sort=4,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='CARLA',@Group='CSQ',@Name='Status',@Label='Push In-Progress',@Sort=5,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='CARLA',@Group='CSQ',@Name='Status',@Label='PCR Approved',@Sort=6,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='CARLA',@Group='CSQ',@Name='Status',@Label='Removed',@Sort=7,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='CARLA',@Group='CSQ',@Name='Status',@Label='Miss',@Sort=8,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='CARLA',@Group='CSQ',@Name='Status',@Label='Project On-Hold',@Sort=9,@CreatedBy='619704'

EXEC stng.SP_Common_CreateValueLabel @Module='ETDB',@Group='TDS',@Name='Status',@Label='New',@Sort=1,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='ETDB',@Group='TDS',@Name='Status',@Label='In Progress',@Sort=2,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='ETDB',@Group='TDS',@Name='Status',@Label='Mentor Review Required',@Sort=3,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='ETDB',@Group='TDS',@Name='Status',@Label='On Hold ',@Sort=4,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='ETDB',@Group='TDS',@Name='Status',@Label='Complete',@Sort=5,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='ETDB',@Group='TDS',@Name='Status',@Label='Cancelled',@Sort=6,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='ETDB',@Group='TDS',@Name='Status',@Label='Buyer Response Required',@Sort=7,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='ETDB',@Group='TDS',@Name='Status',@Label='Pending CRA',@Sort=8,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='ETDB',@Group='TDS',@Name='Status',@Label='PB Review Required',@Sort=9,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='ETDB',@Group='TDS',@Name='Status',@Label='Pending PMC Clarifications',@Sort=10,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='ETDB',@Group='TDS',@Name='Status',@Label='LOT/NOLOT Issue',@Sort=11,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='ETDB',@Group='TDS',@Name='Status',@Label='AML Update',@Sort=12,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='ETDB',@Group='TDS',@Name='Status',@Label='IEE',@Sort=13,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='ETDB',@Group='TDS',@Name='Status',@Label='Pending TOQ from Vendor',@Sort=14,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='ETDB',@Group='TDS',@Name='Status',@Label='Pending PMC Quote Approval',@Sort=15,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='ETDB',@Group='TDS',@Name='Status',@Label='Pending 50% Submission',@Sort=16,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='ETDB',@Group='TDS',@Name='Status',@Label='BP Review',@Sort=17,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='ETDB',@Group='TDS',@Name='Status',@Label='Pending 90% Submission',@Sort=18,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='ETDB',@Group='TDS',@Name='Status',@Label='Correction (Internal)',@Sort=19,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='ETDB',@Group='TDS',@Name='Status',@Label='Correction (External)',@Sort=20,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='ETDB',@Group='TDS',@Name='Status',@Label='Pending Complete (10% Review Done)',@Sort=21,@CreatedBy='619704'

EXEC stng.SP_Common_CreateValueLabel @Module='ETDB',@Group='Item',@Name='State',@Label='Approval Required',@Sort=1,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='ETDB',@Group='Item',@Name='State',@Label='Complete',@Sort=2,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='ETDB',@Group='Item',@Name='State',@Label='In Progress',@Sort=3,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='ETDB',@Group='Item',@Name='State',@Label='Removed',@Sort=4,@CreatedBy='619704'

EXEC stng.SP_Common_CreateValueLabel @Module='Escalations', @Group='Main',@Name='Status',@Label='Approval Required',@Sort=1,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Escalations', @Group='Main',@Name='Status',@Label='In Progress',@Sort=2,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Escalations', @Group='Main',@Name='Status',@Label='Complete',@Sort=3,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Escalations', @Group='Main',@Name='Status',@Label='Removed',@Sort=4,@CreatedBy='619704'

EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Role',@Name='Department',@Label='Supply Chain',@Value='SC',@Sort=1,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Role',@Name='Department',@Label='Engineering Support Division',@Value='ESD',@Sort=2,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Role',@Name='Department',@Label='Equipment Performance Division',@Value='EPD',@Sort=3,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Role',@Name='Department',@Label='Major Component Replacement',@Value='MCR',@Sort=4,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Role',@Name='Department',@Label='Nuclear Safety Analysis Support',@Value='NSAS',@Sort=5,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Role',@Name='Department',@Label='Project Management and Construction',@Value='PMC',@Sort=6,@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Role',@Name='Department',@Label='Design Engineering',@Value='DED',@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Vendor',@Name='Vendor',@Label='Allied',@Value='AECO',@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Vendor',@Name='Vendor',@Label='Alithya',@Value='ALIT',@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Vendor',@Name='Vendor',@Label='BWXT NEC',@Value='BWXT',@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Vendor',@Name='Vendor',@Label='BWXT Cambridge',@Value='BWXTC',@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Vendor',@Name='Vendor',@Label='Candu',@Value='CANDU',@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Vendor',@Name='Vendor',@Label='Framatome',@Value='FRAM',@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Vendor',@Name='Vendor',@Label='Hatch',@Value='HATC',@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Vendor',@Name='Vendor',@Label='KCI',@Value='KCI',@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Vendor',@Name='Vendor',@Label='Kinectrics NSS',@Value='KI NSS',@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Vendor',@Name='Vendor',@Label='Kinectrics MS',@Value='KI MS',@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Vendor',@Name='Vendor',@Label='Kinectrics NCL',@Value='KI NCL',@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Vendor',@Name='Vendor',@Label='Kinectrics PMPC',@Value='KI PMPC',@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Vendor',@Name='Vendor',@Label='LRI',@Value='LRI',@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Vendor',@Name='Vendor',@Label='NA Engineering',@Value='NAE',@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Vendor',@Name='Vendor',@Label='NPX',@Value='NPX',@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Vendor',@Name='Vendor',@Label='Promation',@Value='PROM',@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Vendor',@Name='Vendor',@Label='RCMT',@Value='RCMT',@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Vendor',@Name='Vendor',@Label='Rolls Royce',@Value='ROLLS',@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Vendor',@Name='Vendor',@Label='S&L',@Value='SAL',@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Vendor',@Name='Vendor',@Label='Sargent Lundy',@Value='SARGL',@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Vendor',@Name='Vendor',@Label='Siemens',@Value='SIEM',@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Vendor',@Name='Vendor',@Label='SNC Lavalin',@Value='SNC',@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Vendor',@Name='Vendor',@Label='Tetra Tech',@Value='TT',@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Vendor',@Name='Vendor',@Label='Various',@Value='VAR',@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Vendor',@Name='Vendor',@Label='Westinghouse',@Value='WEST',@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Vendor',@Name='Vendor',@Label='Westinghouse Canada',@Value='WESTC',@CreatedBy='619704'
EXEC stng.SP_Common_CreateValueLabel @Module='Admin', @Group='Vendor',@Name='Vendor',@Label='Worley Parsons',@Value='WORL',@CreatedBy='619704'

/*Roles*/
INSERT INTO stng.Admin_Role(Name,Description,CreatedBy,NameShort,ModuleID) VALUES
('System Admin','Gain access to User Management with ability to configure system settings and grant privileges',619704,'SysAdmin',1),
('Guest','Initial role when a user signs in for the first time. Access to no privileges and modules',619704,'Guest',NULL)

/*Modules*/
INSERT INTO stng.Admin_Module(Name,Description,Path,Icon,CreatedBy,Section) VALUES ('Common','Components and funcationality that are common across multiple modules',NULL,NULL,619704)
INSERT INTO stng.Admin_Module(Name,Description,Path,Icon,CreatedBy,Section) VALUES ('Admin','User Management',NULL,NULL,619704)
INSERT INTO stng.Admin_Module(Name,Description,Path,Icon,CreatedBy,Section) VALUES ('CARLA','Work management synced with P6 with gantt chart updates',NULL,NULL,619704)
INSERT INTO stng.Admin_Module(Name,Description,Path,Icon,CreatedBy,Section) VALUES ('MPL','Master project list',NULL,NULL,619704)
INSERT INTO stng.Admin_Module(Name,Description,Path,Icon,CreatedBy,Section) VALUES ('ALR','Work management for supply chain',NULL,NULL,619704)
INSERT INTO stng.Admin_Module(Name,Description,Path,Icon,CreatedBy,Section) VALUES ('ETDB','Eng-Tech dashboard for managing TDS forms and assignments',NULL,NULL,619704)
INSERT INTO stng.Admin_Module(Name,Description,Path,Icon,CreatedBy,Section) VALUES ('Escalations','Escalations for modules',NULL,NULL,619704)
INSERT INTO stng.Admin_Module(Name,Description,Path,Icon,CreatedBy,Section) VALUES ('SORT',NULL,NULL,NULL,619704)