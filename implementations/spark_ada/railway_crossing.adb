--  Railway Crossing — SPARK Ada Body

package body Railway_Crossing
   with SPARK_Mode => On
is

   function Init return Crossing_System is
   begin
      return (Train => Far, Gate => Open);
   end Init;

   procedure Train_Approach (S : in out Crossing_System) is
   begin
      S.Train := Near;
   end Train_Approach;

   procedure Train_Enter (S : in out Crossing_System) is
   begin
      S.Train := Crossing;
   end Train_Enter;

   procedure Train_Pass (S : in out Crossing_System) is
   begin
      S.Train := Gone;
   end Train_Pass;

   procedure Train_Reset (S : in out Crossing_System) is
   begin
      S.Train := Far;
   end Train_Reset;

   procedure Gate_Close (S : in out Crossing_System) is
   begin
      S.Gate := Closed;
   end Gate_Close;

   procedure Gate_Open (S : in out Crossing_System) is
   begin
      S.Gate := Open;
   end Gate_Open;

end Railway_Crossing;
