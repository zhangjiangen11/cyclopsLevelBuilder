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
class_name ActionToolDuplicate
extends CyclopsAction


const ACTION_ID:String = "tool_duplicate"

func _get_action_id():
	return ACTION_ID
	
#func _init(plugin:CyclopsLevelBuilder, name:String = "", accellerator:Key = KEY_NONE):
	#super._init(plugin, "Duplicate Selected Blocks")
	
func _init():
	name = "Duplicate Selected Blocks"

func _execute(event:CyclopsActionEvent):
	var plugin:CyclopsLevelBuilder = event.plugin
#	plugin.switch_to_tool(ToolDuplicate.new())
	plugin.switch_to_tool_id(ToolDuplicate.TOOL_ID)
