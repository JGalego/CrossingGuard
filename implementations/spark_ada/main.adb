--  Railway Crossing — Demo main program

with Ada.Text_IO;       use Ada.Text_IO;
with Railway_Crossing;  use Railway_Crossing;

procedure Main
   with SPARK_Mode => On
is
   S : Crossing_System := Init;
   T : Train_Position;
   G : Gate_State;
begin
   T := Get_Train (S);
   G := Get_Gate (S);
   Put_Line ("Initial:  train=" & Train_Position'Image (T)
             & ", gate=" & Gate_State'Image (G));

   Train_Approach (S);
   T := Get_Train (S);
   G := Get_Gate (S);
   Put_Line ("Approach: train=" & Train_Position'Image (T)
             & ", gate=" & Gate_State'Image (G));

   Gate_Close (S);
   T := Get_Train (S);
   G := Get_Gate (S);
   Put_Line ("Close:    train=" & Train_Position'Image (T)
             & ", gate=" & Gate_State'Image (G));

   Train_Enter (S);
   T := Get_Train (S);
   G := Get_Gate (S);
   Put_Line ("Enter:    train=" & Train_Position'Image (T)
             & ", gate=" & Gate_State'Image (G));

   Train_Pass (S);
   T := Get_Train (S);
   G := Get_Gate (S);
   Put_Line ("Pass:     train=" & Train_Position'Image (T)
             & ", gate=" & Gate_State'Image (G));

   Gate_Open (S);
   T := Get_Train (S);
   G := Get_Gate (S);
   Put_Line ("Open:     train=" & Train_Position'Image (T)
             & ", gate=" & Gate_State'Image (G));

   Train_Reset (S);
   T := Get_Train (S);
   G := Get_Gate (S);
   Put_Line ("Reset:    train=" & Train_Position'Image (T)
             & ", gate=" & Gate_State'Image (G));

   Put_Line ("");
   Put_Line ("All transitions verified by SPARK/GNATprove!");
end Main;
