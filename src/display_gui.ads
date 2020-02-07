with Framebuffer_ILI9341;

package display_gui is 
   procedure display_gui_button(Display : in out Framebuffer_ILI9341.Frame_Buffer;
                                Offset : Natural;
                                Width : Positive;
                                Height : Positive;
                                Layer : Positive;
                               )
end display_gui;
