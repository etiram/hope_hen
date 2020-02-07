
with HAL.Bitmap;            use HAL.Bitmap;
package body display_gui is
   
   procedure display_Cardiac_Graph(Display : in out Framebuffer_ILI9341.Frame_Buffer;
                                   Offset : Natural;
                                   Width : Positive;
                                   Height : Positive;
                                   Layer : Positive
                                  ) is
      Index : Integer := 0;
      BG : constant Bitmap_Color := (Alpha => 255, others => 64);
      Current : Integer := Data(Offset + 1);
   begin
      Display.Hidden_Buffer (Layer).Set_Source (BG);
      Display.Hidden_Buffer (Layer).Fill;
      Display.Hidden_Buffer (Layer).Set_Source (HAL.Bitmap.Green);
      for I in 0 .. Data'Length - 1 loop
         Index := Data'First + ((Offset + I + 1) mod Data'Length);
         pragma Loop_Variant(Increases => I);
         Draw_Line
                    (Display.Hidden_Buffer (Layer).all,
                     Start     => (I * Width / Data'Length, Current* Height / 1023),
                     Stop      => ((I + 1) * Width / Data'Length, Data(Index) * height / 1023),
                     Thickness => 1,
                     Fast      => False);
         Current := Data(Index);
      end loop;
      Display.Update_Layer (Layer, Copy_Back => True);
   end display_Cardiac_Graph;
end display_gui;
