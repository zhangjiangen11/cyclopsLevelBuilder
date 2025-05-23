# MIT License
#
# Copyright (c) 2023 Mark McKay
# https://github.com/blackears/cyclopsLevelBuilder
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

@tool
extends CyclopsTool
class_name ToolDuplicate

const TOOL_ID:String = "duplicate"

var drag_start_point:Vector3
var cmd_duplicate:CommandDuplicateBlocks

enum ToolState { READY, DRAGGING, DONE }
var tool_state:ToolState = ToolState.READY

func _get_tool_id()->String:
	return TOOL_ID

func _show_in_toolbar()->bool:
	return false
	
func _get_tool_name()->String:
	return "Duplicate"

func _get_tool_icon()->Texture2D:
	return null

func _get_tool_tooltip()->String:
	return "Duplicate selected blocks"

func _draw_tool(viewport_camera:Camera3D):
	var global_scene:CyclopsGlobalScene = builder.get_global_scene()
	global_scene.clear_tool_mesh()
	#global_scene.draw_selected_blocks(viewport_camera)

	builder.viewport_3d_manager.clear_tool_display()
	builder.viewport_3d_manager.draw_selection_marquis(viewport_camera)

func _can_handle_object(node:Node)->bool:
	return node is CyclopsBlock

func _gui_input(viewport_camera:Camera3D, event:InputEvent)->bool:	
	
	if event is InputEventMouseButton:
		
		var e:InputEventMouseButton = event
		if e.button_index == MOUSE_BUTTON_LEFT:

			if !e.is_pressed():
				if tool_state == ToolState.DRAGGING:
					#print("committing duplicate")
					var undo:EditorUndoRedoManager = builder.get_undo_redo()

					if cmd_duplicate.will_change_anything():
						cmd_duplicate.add_to_undo_manager(undo)
					
					tool_state = ToolState.DONE
#					builder.switch_to_tool(ToolBlock.new())
					builder.switch_to_tool_id(ToolBlock.TOOL_ID)
					
		return true
					
	elif event is InputEventMouseMotion:
		var e:InputEventMouseMotion = event

		if (e.button_mask & MOUSE_BUTTON_MASK_MIDDLE):
			return super._gui_input(viewport_camera, event)		

		var origin:Vector3 = viewport_camera.project_ray_origin(e.position)
		var dir:Vector3 = viewport_camera.project_ray_normal(e.position)
		
		if tool_state == ToolState.DRAGGING:
			var drag_to:Vector3
			if e.alt_pressed:
				drag_to = MathUtil.closest_point_on_line(origin, dir, drag_start_point, Vector3.UP)
			else:
				drag_to = MathUtil.intersect_plane(origin, dir, drag_start_point, Vector3.UP)
			
			var offset:Vector3 = drag_to - drag_start_point
			offset = builder.get_snapping_manager().snap_point(offset, SnappingQuery.new(viewport_camera))
			#print("drag offset %s" % offset)

			#print("duplicate drag by %s" % offset)
			
			cmd_duplicate.move_offset = offset
			cmd_duplicate.do_it()
		
		return true
			
	
	return false
	

func _activate(tool_owner:Node):
	super._activate(tool_owner)

	var global_scene:CyclopsGlobalScene = builder.get_global_scene()
	global_scene.clear_tool_mesh()
	
	#Invoke command immediately
	cmd_duplicate = CommandDuplicateBlocks.new()
	cmd_duplicate.builder = builder
	var blocks_root:Node = builder.get_block_add_parent()
	cmd_duplicate.blocks_root_path = blocks_root.get_path()
	var centroid:Vector3
	var count:int = 0
	
	var sel_blocks:Array[CyclopsBlock] = builder.get_selected_blocks()
	for block in sel_blocks:
		cmd_duplicate.blocks_to_duplicate.append(block.get_path())
		centroid += block.global_transform * block.control_mesh.bounds.get_center()
		count += 1
	
	cmd_duplicate.lock_uvs = builder.lock_uvs
	
	centroid /= count
	drag_start_point = centroid
	tool_state = ToolState.DRAGGING
	
	cmd_duplicate.do_it()
	
