codeunit 50143 "Workflow Response Handler Sriq"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpenDocument', '', false, false)]
    local procedure OnOpenDocument(RecRef: RecordRef; var Handled: Boolean);
    var
        ItemJnlLine: Record "Item Journal Line";
    Begin
        RecRef.SetTable(ItemJnlLine);
        ItemJnlLine."Approval Status" := ItemJnlLine."Approval Status"::open;
        ItemJnlLine.Modify();
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', false, false)]
    local procedure OnReleaseDocument(RecRef: RecordRef; var Handled: Boolean);
    var
        ItemJnlLine: Record "Item Journal Line";
    begin

        RecRef.SetTable(ItemJnlLine);
        ItemJnlLine."Approval Status" := ItemJnlLine."Approval Status"::Released;
        ItemJnlLine.Modify();
        Handled := true;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSetStatusToPendingApproval', '', false, false)]
    local procedure OnSetStatusToPendingApproval(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean);
    var
        ItemJnlLine: Record "Item Journal Line";

    Begin
        RecRef.SetTable(ItemJnlLine);
        ItemJnlLine."Approval Status" := ItemJnlLine."Approval Status"::"Pending Approval";
        ItemJnlLine.Modify();
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsePredecessorsToLibrary', '', false, false)]
    local procedure OnAddWorkflowResponsePredecessorsToLibrary(ResponseFunctionName: Code[128]);
    var
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
        WorkflowEventHandling: Codeunit "Workflow Event Handler Sriq";
    begin
        Case ResponseFunctionName of
            WorkflowResponseHandling.SetStatusToPendingApprovalCode:
                begin

                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode,
                        WorkflowEventHandling.RunWorkflowOnSendItemJnlLineForApprovalCode);
                end;
            WorkflowResponseHandling.SendApprovalRequestForApprovalCode:
                begin

                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode,
                        WorkflowEventHandling.RunWorkflowOnSendItemJnlLineForApprovalCode);
                end;
            WorkflowResponseHandling.CancelAllApprovalRequestsCode:
                begin
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode,
                        WorkflowEventHandling.RunWorkflowOnCancelItemJnlLineForApprovalCode);

                end;
            WorkflowResponseHandling.OpenDocumentCode:
                begin
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode,
                        WorkflowEventHandling.RunWorkflowOnCancelItemJnlLineForApprovalCode);
                end;
        end;
    end;
}


