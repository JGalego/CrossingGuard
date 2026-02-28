--  Railway Crossing — SPARK Ada Specification
--
--  SPARK is a formally verifiable subset of Ada used in safety-critical
--  systems (avionics, railway signaling — ERTMS/ETCS).
--
--  GNATprove checks at compile time that:
--    - The safety invariant (Type_Invariant) holds after every operation
--    - No runtime exceptions (overflow, range check, etc.)
--    - All contracts (Pre/Post) are satisfied
--
--  Verify:
--    gnatprove -P railway_crossing.gpr --level=2
--
--  Build & run:
--    gprbuild -P railway_crossing.gpr
--    ./main

package Railway_Crossing
   with SPARK_Mode => On
is
   type Train_Position is (Far, Near, Crossing, Gone);
   type Gate_State     is (Open, Closed);

   type Crossing_System is private;

   --  Queries
   function Get_Train (S : Crossing_System) return Train_Position;
   function Get_Gate  (S : Crossing_System) return Gate_State;

   --  Safety invariant: train crossing implies gate closed
   function Is_Safe (S : Crossing_System) return Boolean;

   --  Constructor
   function Init return Crossing_System
      with Post => Get_Train (Init'Result) = Far
                   and Get_Gate (Init'Result) = Open
                   and Is_Safe (Init'Result);

   --  Train actions
   procedure Train_Approach (S : in out Crossing_System)
      with Pre  => Is_Safe (S) and Get_Train (S) = Far,
           Post => Is_Safe (S) and Get_Train (S) = Near
                   and Get_Gate (S) = Get_Gate (S'Old);

   procedure Train_Enter (S : in out Crossing_System)
      with Pre  => Is_Safe (S)
                   and Get_Train (S) = Near
                   and Get_Gate (S) = Closed,
           Post => Is_Safe (S) and Get_Train (S) = Crossing
                   and Get_Gate (S) = Closed;

   procedure Train_Pass (S : in out Crossing_System)
      with Pre  => Is_Safe (S) and Get_Train (S) = Crossing,
           Post => Is_Safe (S) and Get_Train (S) = Gone
                   and Get_Gate (S) = Get_Gate (S'Old);

   procedure Train_Reset (S : in out Crossing_System)
      with Pre  => Is_Safe (S) and Get_Train (S) = Gone,
           Post => Is_Safe (S) and Get_Train (S) = Far
                   and Get_Gate (S) = Get_Gate (S'Old);

   --  Gate actions
   procedure Gate_Close (S : in out Crossing_System)
      with Pre  => Is_Safe (S)
                   and Get_Train (S) = Near
                   and Get_Gate (S) = Open,
           Post => Is_Safe (S) and Get_Gate (S) = Closed
                   and Get_Train (S) = Get_Train (S'Old);

   procedure Gate_Open (S : in out Crossing_System)
      with Pre  => Is_Safe (S)
                   and (Get_Train (S) = Gone or Get_Train (S) = Far)
                   and Get_Gate (S) = Closed,
           Post => Is_Safe (S) and Get_Gate (S) = Open
                   and Get_Train (S) = Get_Train (S'Old);

private
   type Crossing_System is record
      Train : Train_Position := Far;
      Gate  : Gate_State     := Open;
   end record;

   function Get_Train (S : Crossing_System) return Train_Position is
      (S.Train);

   function Get_Gate (S : Crossing_System) return Gate_State is
      (S.Gate);

   function Is_Safe (S : Crossing_System) return Boolean is
      (if S.Train = Crossing then S.Gate = Closed else True);

end Railway_Crossing;
