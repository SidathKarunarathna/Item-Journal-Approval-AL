codeunit 50145 "Item Journal Event Subs"
{
    [EventSubscriber(ObjectType::Page, Page::"Item Journal", 'OnBeforeActionEvent', 'Post', false, false)]
    local procedure ValidatePost(var Rec: Record "Item Journal Line")
    var
        ApprovalMgt: Codeunit "Approval Mgt Sriq";
        NotRealesed:Boolean;
    begin
        if ApprovalMgt.CheckItemJnlLineApprovalsWorkflowEnable2(Rec) then begin
            NotRealesed:=false;
            repeat 
                if not (Rec."Approval Status" = Rec."Approval Status"::Released) then
                    NotRealesed:=true;
            until Rec.Next()=0;
            if NotRealesed then
                Error('APPROVAL IS NEEDED BEFORE POSTING');
        end;

    end;
    [EventSubscriber(ObjectType::Page, Page::"Item Journal", 'OnBeforeActionEvent', 'Post and &Print', false, false)]
    local procedure ValidatePostAndPrint(var Rec: Record "Item Journal Line")
    var
        ApprovalMgt: Codeunit "Approval Mgt Sriq";
        NotRealesed:Boolean;
    begin
        if ApprovalMgt.CheckItemJnlLineApprovalsWorkflowEnable2(Rec) then begin
            NotRealesed:=false;
            repeat 
                if not (Rec."Approval Status" = Rec."Approval Status"::Released) then
                    NotRealesed:=true;
            until Rec.Next()=0;
            if NotRealesed then
                Error('APPROVAL IS NEEDED BEFORE POSTING');
        end;

    end;

}
