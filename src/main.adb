with Ada.Text_IO;
with Ada.Characters.Latin_1; use Ada.Characters.Latin_1;

procedure Main with SPARK_Mode is

   function Backwards (Left : String; Right : String) return Boolean
   is
     ((Left'Length >= 0
      and then Left'Length = Right'Length
      and then
        (for all I in Left'Range =>
            Left (I) = Right (Right'Last - (I - Left'First)))))
       --                                       ^^^^^^^^^^
       --  using Left'First as Right is a slice to a higher index
     with Ghost;

   function Reverse_Func (Buffer : String) return String
     with
       Depends => (Reverse_Func'Result => Buffer),
       Pre => Buffer'Length >= 0,
       Post => Backwards (Reverse_Func'Result, Buffer)
   is
      Result  : String := Buffer;
      Current : Positive;
   begin
      for I in Buffer'Range loop
         Current := Buffer'Last - (I - Buffer'First);
         Result (I) := Buffer (Current);

         pragma Loop_Invariant
           (Backwards
              (Result (Result'First .. I), Buffer (Current .. Buffer'Last)));
      end loop;
      return Result;
   end Reverse_Func;

   Original_Buffer : constant String := "hello world";
   New_Buffer : String := Reverse_Func (Original_Buffer);
begin
   Ada.Text_IO.Put_Line (New_Buffer);
end Main;
