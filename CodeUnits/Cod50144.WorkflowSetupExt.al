codeunit 50144 "Workflow Setup Ext"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", 'OnAddWorkflowCategoriesToLibrary', '', false, false)]
    local procedure OnAddWorkflowCategoriesToLibrary()
    begin
        WorkFlowSetup.InsertWorkflowCategory(ItemJournalLineCategoryTxt, ItemJournalLineCategoryDescriptionTxt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", 'OnAfterInsertApprovalsTableRelations', '', false, false)]
    local procedure OnAfterInsertApprovalsTableRelations()
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        WorkFlowSetup.InsertTableRelation(Database::"Item Journal Line", 0, Database::"Approval Entry", ApprovalEntry.FieldNo("Record ID to Approve"));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", 'OnAfterInitWorkflowTemplates', '', false, false)]
    local procedure OnAfterInitWorkflowTemplates()
    var
        WorkFlowTable: Record Workflow;
    begin
        WorkFlowSetup.InsertWorkflowTemplate(WorkFlowTable, ItemJournalLineWorkflowCodeTxt, ItemJournalLineWorkflowDescriptionTxt, ItemJournalLineCategoryTxt);
    end;

    local procedure InsertItemJournalApprovalDetails(var WorkFlowTable: Record Workflow)
    var
        WorkflowSetupArgument: Record "Workflow Step Argument";
        BlankDateFormula: DateFormula;
        WorkflowEventHandlingExt: Codeunit "Workflow Event Handler Sriq";
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
        ItemJnlLine: Record "Item Journal Line";
    begin
        WorkFlowSetup.InitWorkflowStepArgument(WorkflowSetupArgument, WorkflowSetupArgument."Approver Type"::Approver, WorkflowSetupArgument."Approver Limit Type"::"Direct Approver", 0, '', BlankDateFormula, true);
        WorkFlowSetup.InsertDocApprovalWorkflowSteps(WorkFlowTable,BuildItemJnlLineTypeConditions(ItemJnlLine."Approval Status"::Open),
        WorkflowEventHandlingExt.RunWorkflowOnSendItemJnlLineForApprovalCode(),BuildItemJnlLineTypeConditions(ItemJnlLine."Approval Status"::"Pending Approval"),
        WorkflowEventHandlingExt.RunWorkflowOnCancelItemJnlLineForApprovalCode(),WorkflowSetupArgument,true);

    end;

    local procedure BuildItemJnlLineTypeConditions(Status:Enum "Approval Status Item Journal"): Text
    var
        ItemJnlLine: Record "Item Journal Line";
    begin
        ItemJnlLine.SetRange("Approval Status",Status);
        exit(StrSubstNo(ItemJnlLineTypeCondTxt, WorkflowSetup.Encode(ItemJnlLine.GetView(False))));
    end;


    var
        WorkFlowSetup: Codeunit "Workflow Setup";
        ItemJournalLineCategoryTxt: TextConst ENU = 'Inventory';
        ItemJournalLineCategoryDescriptionTxt: TextConst ENU = 'Item Journal';
        ItemJournalLineWorkflowCodeTxt: TextConst ENU = 'MS-IJAWF';
        ItemJournalLineWorkflowDescriptionTxt: TextConst ENU = 'Item Journal Approval Workflow';
        ItemJnlLineTypeCondTxt: TextConst ENU = '<?xml version="1.0" encoding="utf-8" standalone="yes"?><ReportParameters><DataItems><DataItem name="Item Journals">%1</DataItem></DataItems></ReportParameters>';


}
