codeunit 50141 "Approval Mgt Sriq"
{

    [IntegrationEvent(false, false)]
    procedure OnSendItemJnlLineForApproval(var ItemJnlLine: Record "Item Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelItemJnlLineForApproval(var ItemJnlLine: Record "Item Journal Line")
    begin
    end;

    procedure CheckItemJnlLineApprovalsWorkflowEnable(var ItemJnlLine: Record "Item Journal Line"): Boolean
    begin
        if not IsItemJnlLineApprovalsWorkflowEnable(ItemJnlLine) then
            Error(NoWorkflowEnabledErr);
        exit(true);
    end;
    procedure CheckItemJnlLineApprovalsWorkflowEnable2(var ItemJnlLine: Record "Item Journal Line"): Boolean
    begin
        if not IsItemJnlLineApprovalsWorkflowEnable(ItemJnlLine) then
            exit(false)
        else
            exit(true);
    end;

    procedure IsItemJnlLineApprovalsWorkflowEnable(var ItemJnlLine: Record "Item Journal Line"): Boolean
    var
        WorkflowManagment: Codeunit "Workflow Management";
        WorkflowEventHandling: Codeunit "Workflow Event Handler Sriq";
    begin
        exit(WorkflowManagment.CanExecuteWorkflow(ItemJnlLine, WorkflowEventHandling.RunWorkflowOnSendItemJnlLineForApprovalCode));
    end;

    procedure TrySendJournalLineApprovalRequests(var ItemJnlLine: Record "Item Journal Line")
    var
        LinesSent: Integer;
    begin
        if ItemJnlLine.Count = 1 then
            if CheckItemJnlLineApprovalsWorkflowEnable(ItemJnlLine) then;
        REPEAT
            IF WorkflowManagment.CanExecuteWorkflow(ItemJnlLine,
                 WorkflowEventHandling.RunWorkflowOnSendItemJnlLineForApprovalCode) AND
               NOT ApprovalMgt.HasOpenApprovalEntries(ItemJnlLine.RecordId)
            THEN BEGIN
                OnSendItemJnlLineForApproval(ItemJnlLine);
                LinesSent += 1;
            END;
        UNTIL ItemJnlLine.NEXT = 0;

        CASE LinesSent OF
            0:
                MESSAGE(NoApprovalsSentMsg);
            ItemJnlLine.COUNT:
                MESSAGE(PendingApprovalForSelectedLinesMsg);
            ELSE
                MESSAGE(PendingApprovalForSomeSelectedLinesMsg);
        END;
    end;

    procedure TryCancelJournalLineApprovalRequests(var ItemJnlLine: Record "Item Journal Line")
    begin
        REPEAT
            IF ApprovalMgt.HasOpenApprovalEntries(ItemJnlLine.RECORDID) THEN
                OnCancelItemJnlLineForApproval(ItemJnlLine);
            WorkflowWebhookManagement.FindAndCancel(ItemJnlLine.RECORDID);
        UNTIL ItemJnlLine.NEXT = 0;
        MESSAGE(ApprovalReqCanceledForSelectedLinesMsg);
    end;


    var
        ApprovalMgt: Codeunit "Approvals Mgmt.";
        NoWorkflowEnabledErr: Label 'No approval workflow for this record type is enabled.';
        WorkflowManagment: Codeunit "Workflow Management";
        WorkflowWebhookManagement: Codeunit "Workflow Webhook Management";
        WorkflowEventHandling: Codeunit "Workflow Event Handler Sriq";
        NoApprovalsSentMsg: Label 'No approval requests have been sent, either because they are already sent or because related workflows do not support the journal line.';
        PendingApprovalForSelectedLinesMsg: Label 'Approval requests have been sent.';
        ApprovalReqCanceledForSelectedLinesMsg: Label 'The approval request for the selected record has been canceled.';
        PendingApprovalForSomeSelectedLinesMsg: Label 'Approval requests have been sent.\\Requests for some journal lines were not sent, either because they are already sent or because related workflows do not support the journal line.';
}
