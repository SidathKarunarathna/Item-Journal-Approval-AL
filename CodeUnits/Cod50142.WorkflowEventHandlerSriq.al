codeunit 50142 "Workflow Event Handler Sriq"
{
     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', false, false)]
    local procedure OnAddWorkflowEventsToLibrary();
    begin
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendItemJnlLineForApprovalCode, Database::"Item Journal Line", ItemJnlLineSendForApprovalEventDescTxt, 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelItemJnlLineForApprovalCode, Database::"Item Journal Line", ItemJnlLineApprovalReuqestCancelEventDescText, 0, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventPredecessorsToLibrary', '', false, false)]
    local procedure OnAddWorkflowEventPredecessorsToLibrary(EventFunctionName: Code[128]);
    begin
        case EventFunctionName of


            RunWorkflowOnCancelItemJnlLineForApprovalCode():
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelItemJnlLineForApprovalCode, RunWorkflowOnSendItemJnlLineForApprovalCode);

            WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode:
                begin
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendItemJnlLineForApprovalCode);
                end;
        end;
    end;


    procedure RunWorkflowOnSendItemJnlLineForApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnSendItemJnlLineForApproval'));
    end;

    procedure RunWorkflowOnCancelItemJnlLineForApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelItemJnlLineForApproval'));
    end;




    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgt Sriq", 'OnSendItemJnlLineForApproval', '', false, false)]
    local procedure OnSendItemJnlLineForApproval(var ItemJnlLine: Record "Item Journal Line");
    begin
        WorkflowManagment.HandleEvent(RunWorkflowOnSendItemJnlLineForApprovalCode, ItemJnlLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgt Sriq", 'OnCancelItemJnlLineForApproval', '', false, false)]
    local procedure OnCancelItemJnlLineForApproval(var ItemJnlLine: Record "Item Journal Line");
    begin
        WorkflowManagment.HandleEvent(RunWorkflowOnCancelItemJnlLineForApprovalCode, ItemJnlLine);
    end;



    var
        WorkflowManagment: Codeunit "Workflow Management";
        WorkflowEventHandling: Codeunit "Workflow Event Handling";


        ItemJnlLineSendForApprovalEventDescTxt: TextConst ENU = 'Approval of a Item Journal Line is required';
        ItemJnlLineApprovalReuqestCancelEventDescText: TextConst ENU = 'Approval of a Item Journal Line is canceled';
}
