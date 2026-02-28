--  Railway Crossing — Demo main program

with Ada.Text_IO;       use Ada.Text_IO;
with Railway_Crossing;  use Railway_Crossing;

procedure Main
   with SPARK_Mode => On
is
   S : Crossing_System := Init;
begin
   Put_Line ("Initial:  train=Far,      gate=Open");

   Train_Approach (S);
   Put_Line ("Approach: train=Near,     gate=Open");

   Gate_Close (S);
   Put_Line ("Close:    train=Near,     gate=Closed");

   Train_Enter (S);
   Put_Line ("Enter:    train=Crossing, gate=Closed");

   Train_Pass (S);
   Put_Line ("Pass:     train=Gone,     gate=Closed");

   Gate_Open (S);
   Put_Line ("Open:     train=Gone,     gate=Open");

   Train_Reset (S);
   Put_Line ("Reset:    train=Far,      gate=Open");

   Put_Line ("");
   Put_Line ("All transitions verified by SPARK/GNATprove!");
end Main;
