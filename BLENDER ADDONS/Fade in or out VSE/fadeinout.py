bl_info = {
    "name": "Fade In/Out Helper",
    "blender": (2, 80, 0),
    "category": "IDK",
}

import bpy

class DoFadeInOut(bpy.types.Operator):
    """Script for quickly adding Fade In/Out effect to video strips in VSE"""
    bl_idname = "vse.fadeinout"
    bl_label = "Fade In/Out"
    bl_options = {"REGISTER", "UNDO"}

    fadeframes: bpy.props.IntProperty(name="Fade in/out frames", default=15, min=1)
    offsetframe: bpy.props.IntProperty(name="Offset start/end frame", default=0)

    def execute(self, context):
        selected = context.selected_strips
        for strip in selected:
            start = strip.frame_final_start-self.offsetframe
            end = strip.frame_final_end+self.offsetframe
            blend_default = strip.blend_alpha

            strip.blend_alpha = 0
            strip.keyframe_insert(data_path="blend_alpha", frame=start)
            strip.keyframe_insert(data_path="blend_alpha", frame=end)

            strip.blend_alpha = 1
            strip.keyframe_insert(data_path="blend_alpha", frame=start+self.fadeframes)
            strip.keyframe_insert(data_path="blend_alpha", frame=end-self.fadeframes)

            strip.blend_alpha = blend_default
        return {"FINISHED"}

def menu_func(self, context):
    self.layout.operator(DoFadeInOut.bl_idname)

def register():
    bpy.utils.register_class(DoFadeInOut)
    bpy.types.SEQUENCER_MT_strip.append(menu_func)

def unregister():
    bpy.types.SEQUENCER_MT_strip.remove(menu_func)
    bpy.utils.unregister_class(DoFadeInOut)

if __name__ == "__main__":
    register()
