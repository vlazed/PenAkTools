bl_info = {
    "name": "VSE Text Timer",
    "blender": (2, 80, 0),
    "category": "IDK",
}

import bpy
import math
import re

class DoTextTimer(bpy.types.Operator):
    """Script for setting duration of a text VSE strip to about the time it takes to read it"""
    bl_idname = "vse.texttimer"
    bl_label = "Text Timer"
    bl_options = {"REGISTER", "UNDO"}

    wordtime: bpy.props.FloatProperty(name="Time per word", default=0.3, min=0, step=10)
    sentencetime: bpy.props.FloatProperty(name="Time per sentence end", default=0.1, min=0, step=10)
    commatime: bpy.props.FloatProperty(name="Time per comma", default=0.1, min=0, step=10)

    def calctime(self, text, fps):
        textlist = text.split()
        words = re.findall(r"\w+", text)
        sentences = re.findall(r"\w(\.|!|\?)\B.*?\s.*?\w", text)
        commas = re.findall(r"\w,\B.*?\s.*?\w", text) #Find all commas that have text before and after them (so it's not last comma in the sentence)

        time = math.ceil(len(words) * self.wordtime + len(sentences) * self.sentencetime + len(commas) * self.commatime) * fps #Using 0.3, based on expectation that average person reads 200 words/minute, so 60/200 = 0.3 seconds per word
        return time

    def execute(self, context):
        selected = context.selected_strips
        fps = bpy.context.scene.render.fps
        for strip in selected:
            if strip.type != "TEXT":
                continue
            text = strip.text
            strip.frame_final_duration = self.calctime(text, fps)

        return {"FINISHED"}

def menu_func(self, context):
    self.layout.operator(DoTextTimer.bl_idname)

def register():
    bpy.utils.register_class(DoTextTimer)
    bpy.types.SEQUENCER_MT_strip.append(menu_func)

def unregister():
    bpy.types.SEQUENCER_MT_strip.remove(menu_func)
    bpy.utils.unregister_class(DoTextTimer)

if __name__ == "__main__":
    register()
