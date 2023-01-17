pageextension 50138 "Item Journal Ext" extends "Item Journal"
{
    layout
    {
        addbefore("Document No.")
        {
            field("Approval Status"; Rec."Approval Status")
            {
                ApplicationArea = all;
            }
        }
    }
     actions
    {
        addafter("P&osting")
        {
            group("Request Approval")
            {
                Caption = 'Request Approval';
                group(SendApprovalRequest)
                {
                    Caption = 'Send Approval Request';
                    Image = SendApprovalRequest;
                    action(SendApprovalRequestJournalLine)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Selected Journal Lines';
                        Enabled = NOT OpenApprovalEntriesCurrJnlLineExist AND CanRequestFlowApprovalForCurrentLine;
                        Image = SendApprovalRequest;
                        ToolTip = 'Send selected journal lines for approval.';

                        trigger OnAction()
                        var
                            ItemJournalLine: Record "Item Journal Line";
                            JournalBatchName: Code[20];
                        begin

                            GetCurrentlySelectedLines(ItemJournalLine);
                            ApprovalMgt.TrySendJournalLineApprovalRequests(ItemJournalLine);
                            
                        end;
                    }

                }
                group(CancelApprovalRequest)
                {
                    Caption = 'Cancel Approval Request';
                    Image = Cancel;
                    action(CancelApprovalRequestJournalLine)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Selected Journal Lines';
                        Enabled = CanCancelApprovalForJnlLine OR CanCancelFlowApprovalForLine;
                        Image = CancelApprovalRequest;
                        ToolTip = 'Cancel sending selected journal lines for approval.';

                        trigger OnAction()
                        var
                            [SecurityFiltering(SecurityFilter::Filtered)]
                            ItemJournalLine: Record "Item Journal Line";
                            ApprovalMgt: Codeunit "Approval Mgt Sriq";
                        begin
                            GetCurrentlySelectedLines(ItemJournalLine);
                            ApprovalMgt.TryCancelJournalLineApprovalRequests(ItemJournalLine);
                        end;
                    }
                }
            }



        }
    }
    trigger OnAfterGetRecord()
    var
        ApprovalMgt : Codeunit "Approvals Mgmt.";
        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
    begin
        OpenApprovalEntriesCurrJnlLineExist:= ApprovalMgt.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForJnlLine:= ApprovalMgt.CanCancelApprovalForRecord(Rec.RecordId);

        WorkflowWebhookMgt.GetCanRequestAndCanCancel(Rec.RecordId,CanRequestFlowApprovalForCurrentLine,CanCancelFlowApprovalForLine);
    end;
    procedure GetCurrentlySelectedLines(var ItemJnlLine: Record "Item Journal Line"): Boolean
    begin
        CurrPage.SetSelectionFilter(ItemJnlLine);
        exit(ItemJnlLine.FindSet);
    end;
    var 
    OpenApprovalEntriesCurrJnlLineExist: Boolean;
    CanRequestFlowApprovalForCurrentLine:Boolean;
    CanCancelApprovalForJnlLine:Boolean;
    CanCancelFlowApprovalForLine:Boolean;
    ApprovalMgt : Codeunit "Approval Mgt Sriq";




}
