------------------------------------------------------------------------------
--                                                                          --
--                     Copyright (C) 2015-2016, AdaCore                     --
--                                                                          --
--  Redistribution and use in source and binary forms, with or without      --
--  modification, are permitted provided that the following conditions are  --
--  met:                                                                    --
--     1. Redistributions of source code must retain the above copyright    --
--        notice, this list of conditions and the following disclaimer.     --
--     2. Redistributions in binary form must reproduce the above copyright --
--        notice, this list of conditions and the following disclaimer in   --
--        the documentation and/or other materials provided with the        --
--        distribution.                                                     --
--     3. Neither the name of the copyright holder nor the names of its     --
--        contributors may be used to endorse or promote products derived   --
--        from this software without specific prior written permission.     --
--                                                                          --
--   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS    --
--   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT      --
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR  --
--   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT   --
--   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, --
--   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT       --
--   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,  --
--   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY  --
--   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT    --
--   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE  --
--   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   --
--                                                                          --
------------------------------------------------------------------------------

with Last_Chance_Handler;  pragma Unreferenced (Last_Chance_Handler);
--  The "last chance handler" is the user-defined routine that is called when
--  an exception is propagated. We need it in the executable, therefore it
--  must be somewhere in the closure of the context clauses.

with STM32.Board;           use STM32.Board;
with HAL.Bitmap;            use HAL.Bitmap;
pragma Warnings (Off, "referenced");
with HAL.Touch_Panel;       use HAL.Touch_Panel;
with STM32.User_Button;     use STM32;
with BMP_Fonts;
with LCD_Std_Out;

with Peripherals_Nonblocking;    use Peripherals_Nonblocking;
with Serial_IO.Nonblocking;      use Serial_IO.Nonblocking;
with Message_Buffers;            use Message_Buffers;

procedure Main
is
   Incoming : aliased Message (Physical_Size => 1024);  -- arbitrary size

   procedure Send (This : String);

   procedure Send (This : String) is
      Outgoing : aliased Message (Physical_Size => 1024);  -- arbitrary size
   begin
      Set (Outgoing, To => This);
      Put (COM, Outgoing'Unchecked_Access);
      Await_Transmission_Complete (Outgoing);
      --  We must await xmit completion because Put does not wait
   end Send;
   BG : Bitmap_Color := (Alpha => 255, others => 0);
   Ball_Pos   : Point := (20, 280);
   bg_layer : Constant Positive := 1;
begin
   Display.Initialize;
   Touch_Panel.Initialize;
   User_Button.Initialize;
   Display.Initialize_Layer(bg_layer, ARGB_8888, 0, 0, 320, 320);
   -- init UART
   Initialize (COM);
   Configure (COM, Baud_Rate => 115_200);
   Set_Terminator (Incoming, To => ASCII.CR);
   loop
      --Get (COM, Incoming'Unchecked_Access);
      --Send ("Received : " & Content (Incoming));
      if User_Button.Has_Been_Pressed then
         Send ("t");
         BG := HAL.Bitmap.Blanched_Almond;
      end if;
      Display.Hidden_Buffer (1).Set_Source (BG);
      Display.Hidden_Buffer (1).Fill;
      Display.Hidden_Buffer (1).Set_Source (HAL.Bitmap.Blue);
      Display.Hidden_Buffer (1).Fill_Circle (Ball_Pos, 10);
      declare
         State : constant TP_State := Touch_Panel.Get_All_Touch_Points;
      begin
         case State'Length is
            when 1 =>
               Ball_Pos := (State (State'First).X, State (State'First).Y);

            when others => null;
         end case;
      end;
      --  Update screen
      Display.Update_Layer (1, Copy_Back => True);
   end loop;
end Main;
