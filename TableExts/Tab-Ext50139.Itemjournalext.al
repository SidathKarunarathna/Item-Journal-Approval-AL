tableextension 50139 "Item journal ext" extends "Item Journal Line"
{
    
    fields
    {
        field(50100; "Approval Status"; Enum "Approval Status Item Journal")
        {
            Caption = 'Approval Status';
            DataClassification = ToBeClassified;
        }
    }
}
