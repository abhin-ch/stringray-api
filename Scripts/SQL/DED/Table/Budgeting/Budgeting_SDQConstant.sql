create table stng.Budgeting_SDQConstant
(
	UniqueID int primary key identity(1,1),
	[Description] varchar(250) not null unique,
	[Value] varchar(max) not null,
	RAD datetime not null default stng.GetBPTime(getdate()),
	RAB varchar(20) not null foreign key references stng.Admin_User(EmployeeID),
	LUD datetime not null default stng.GetBPTime(getdate()),
	LUB varchar(20) not null foreign key references stng.Admin_User(EmployeeID)
);

declare @AssumptionLong varchar(max);
set @AssumptionLong = N'The following cost and scheduling assumptions apply:

(1) Pricing excludes HST.

(2) The Design Quote is a �Time and Material� Basis quote.

(3) Labour Costs are calculated at a cost rate of $143/hr for Bruce Power Effort.

(4) Labour Costs are calculated at a cost rate of $143/hr for Bruce Power Drafting Office Effort.

(5) Standard cost and scheduling estimate uncertainties have been applied, including 20% cost estimate uncertainties on design engineering (including vendor ? remove if no vendor for the project) costs, and 20% or two week schedule estimate uncertainties (whichever is greater).

(6) Project Management and Project Controls costs including project controls specialist, project planner, and planning/management/reporting spreads have been estimated on the basis of WBS, which is approximately 8% of the design engineering (including vendor ? remove if no vendor for the project) costs for direct charges and $800/month for reporting spreads

(7) Any additional scope changes and their associated costs, if not captured under a Design Variance Notice (DVN), will be identified in a subsequent Design Quote Revision.  This will be included when the additional scope is defined, resources assigned, work scheduled and commitment dates are agreed upon.

(8) Construction and Material estimates are provided by PMC. (? for PMC capital projects only)

(9) (OE/RDE/RSE/etc.) support is estimated on the basis of XX hours per week for X weeks, based on (? insert description of effort, e.g. bi-weekly 1 hour meetings)

(10) Bruce Power Engineering Service Division reserves the right to contract work out to meet required timelines.

(11) Field Team Lead (FTL) role is fulfilled by an Engineering Service Provider (ESP)/PMC/DED who is responsible for the implementation of the design.

(12) Costs associated with Design Engineering work performed by other ESP�s are included in this Design Quote.

(13) Closeout for DCN(s) is assumed to be 120 days after AFS is declared.

(14) Closeout for DCP is assumed to be 30 days after the last DCN is closed out.

(15) DCP date in this Design Quote refer to the date that Milestone 240 (DM MOD APPR) is signed off (? for preliminary engineering only; to be removed if not applicable).

(16) DCPE-PER date in this Design Quote refers to the date that Milestone 238 (DM EQV APPR) is signed off (? for DCPE-PER modifications only; to be removed if not applicable).

(17) DCN dates in this Design Quote refer to the date that Milestone 241 (DM DCN APPR) is signed off (? for detailed engineering only; to be removed if not applicable).

(18) Key Deliverables and their Due Dates are based on this Design Quote being signed within 2 weeks of submission to the Customer.

(19) The Project Baseline Schedule and respective deliverables will be set based on the Work Start Date.  The Work Start Date is to be no later than 1 week after the DQ is accepted and signed unless one or more of the following are invoked:

a. DED reserves the right to change the Work Start Date.

b. If the Work Start Date changes from what is identified in the Project Baseline Schedule, then a revised Work Start Date will be determined and agreed to by DED and the ESP.

(20) Installation for this work is assumed to be outage (? change to innage if applicable) and assumes the following:

a. The work will be scheduled for (? insert outage number, or remove if innage).

b. In the event that Outage Milestone #9 is missed, reasonable effort will be expended to schedule this work.  If this attempt is unsuccessful, this work will be moved to the next outage (? remove and add innage assumptions if applicable).

(21) This Design Quote assumes the current outage (? change to innage if applicable) schedule for Unit X of Day/Month/Year to Day/Month/Year.  If the outage dates (? change to innage if applicable) move, or if this work is removed from outage scope, the dates will automatically be re-baselined to align with the current outage schedule (? modify for innage as required).'

insert into stng.Budgeting_SDQConstant
([Description], [Value], RAB, LUB)
values
('AssumptionLong',@AssumptionLong, 'SYSTEM','SYSTEM');