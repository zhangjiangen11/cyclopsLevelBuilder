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
extends Node3D

@export var face_sel_color:Color = Color(1, .5, 0, .4)
@export var face_unsel_color:Color = Color(.5, .5, .5, .4)
@export var edge_sel_color:Color = Color(1, .5, 0, 1)
@export var edge_unsel_color:Color = Color(.5, .5, .5, 1)

@export var block_nodes:Array[CyclopsBlock]:
	set(value):
		for node in block_nodes:
			node.mesh_changed.disconnect(on_node_mesh_changed)
			
		block_nodes = value
		
		for node in block_nodes:
			node.mesh_changed.connect(on_node_mesh_changed)
			
		dirty = true
		
var dirty:bool = true

#var block_edit_handles:Array[UvEditingState]
var block_edit_handles:Dictionary #[nodePath, UvEditingState]

func on_node_mesh_changed(node:Node3D):
	block_edit_handles.clear()
	
	rebuild_block_handles(node)

func rebuild_handles():
	for block in block_nodes:
		rebuild_block_handles(block)

func rebuild_block_handles(block:CyclopsBlock):
	var mvd:MeshVectorData = block.mesh_vector_data
	var cv:ConvexVolume = ConvexVolume.new()
	cv.init_from_mesh_vector_data(mvd)
	
	var state:UvEditingState = UvEditingState.new()
	
	for f:ConvexVolume.FaceInfo in cv.faces:
		var h_f:HandleUvFace = HandleUvFace.new()
		h_f.object_path = block.get_path()
		h_f.face_index = f.index
		
		state.handle_faces.append(h_f)
		
		for e_idx in f.edge_indices:
			var h_e:HandleUvEdge = HandleUvEdge.new()
			h_e.object_path = block.get_path()
			h_e.face_index = f.index
			h_e.edge_index = e_idx
			
			state.handle_edges.append(h_e)
		
		for v_idx in f.vertex_indices:
			var h_v:HandleUvVertex = HandleUvVertex.new()
			h_v.object_path = block.get_path()
			h_v.face_index = f.index
			h_v.vertex_index = v_idx
			
			state.handle_edges.append(h_v)
	
	block_edit_handles[block.get_path()] = state
	
	#queue_redraw()

####################

func create_mesh_faces(cv:ConvexVolume, material:Material, 
	sel_color:Color = Color.ORANGE, 
	unsel_color:Color = Color.GRAY, 
	selected_faces_only:bool = false)->ArrayMesh:

	var mesh:ArrayMesh = ArrayMesh.new()

	var indices:PackedInt32Array
	var points_indexed:PackedVector3Array
	var uvs_indexed:PackedVector2Array
	var colors_indexed:PackedColorArray

	for f:ConvexVolume.FaceInfo in cv.faces:
		if selected_faces_only && !f.selected:
			continue
		
		var color:Color = sel_color if f.selected else unsel_color
		
		var v_idx_arr:PackedInt32Array = f.get_trianges_v_idx()
		for v_idx in v_idx_arr:
			var fv0:ConvexVolume.FaceVertexInfo = cv.get_face_vertex(f.index, v_idx)
			var v0:ConvexVolume.VertexInfo = cv.vertices[v_idx]
			
			points_indexed.append(v0.point)
			uvs_indexed.append(fv0.uv0)
			colors_indexed.append(color)
			indices.append(indices.size())
		
		
		
	var arrays:Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = points_indexed
	arrays[Mesh.ARRAY_INDEX] = indices
	arrays[Mesh.ARRAY_TEX_UV] = uvs_indexed
	arrays[Mesh.ARRAY_COLOR] = colors_indexed
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(0, material)
	
	return mesh

func create_mesh_edges(cv:ConvexVolume, material:Material, 
	edge_sel_color:Color = Color.ORANGE, 
	edge_unsel_color:Color = Color.GRAY, 
	selected_faces_only:bool = false)->ArrayMesh:

	var mesh:ArrayMesh = ArrayMesh.new()

	var indices:PackedInt32Array
	var points_indexed:PackedVector3Array
	var uvs_indexed:PackedVector2Array
	var colors_indexed:PackedColorArray

	for f:ConvexVolume.FaceInfo in cv.faces:
		if selected_faces_only && !f.selected:
			continue
		
#		print("face")
		for local_fv_idx_0:int in f.face_vertex_indices.size():
			var local_fv_idx_1:int = wrap(local_fv_idx_0 + 1, 0, f.face_vertex_indices.size())
			
			var fv0:ConvexVolume.FaceVertexInfo = cv.face_vertices[f.face_vertex_indices[local_fv_idx_0]]
			var fv1:ConvexVolume.FaceVertexInfo = cv.face_vertices[f.face_vertex_indices[local_fv_idx_1]]
			
			var e:ConvexVolume.EdgeInfo = cv.get_edge(fv0.vertex_index, fv1.vertex_index)
			var color:Color = edge_sel_color if e.selected else edge_unsel_color
			
			var v0:ConvexVolume.VertexInfo = cv.vertices[fv0.vertex_index]
			var v1:ConvexVolume.VertexInfo = cv.vertices[fv1.vertex_index]
			
			colors_indexed.append(color)
			colors_indexed.append(color)

			uvs_indexed.append(fv0.uv0)
			uvs_indexed.append(fv1.uv0)
			
#			print("v0.point ", v0.point, " v1.point ", v1.point)
			points_indexed.append(v0.point)
			points_indexed.append(v1.point)
			
			indices.append(indices.size())
			indices.append(indices.size())
			
		
	var arrays:Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = points_indexed
	arrays[Mesh.ARRAY_INDEX] = indices
	arrays[Mesh.ARRAY_TEX_UV] = uvs_indexed
	arrays[Mesh.ARRAY_COLOR] = colors_indexed
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	mesh.surface_set_material(0, material)
	
	return mesh

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if dirty:
#		print("rebuild uv editor")
		var uv_mesh_faces_mat:ShaderMaterial = preload("res://addons/cyclops_level_builder/gui/docks/uv_editor/uv_mesh_faces_material.tres")
		var uv_mesh_edges_mat:ShaderMaterial = preload("res://addons/cyclops_level_builder/gui/docks/uv_editor/uv_mesh_edges_material.tres")
		
		for child in %meshes.get_children():
			%meshes.remove_child(child)
			child.queue_free()
		
		for node:CyclopsBlock in block_nodes:
			var mvd:MeshVectorData = node.mesh_vector_data
			var cv:ConvexVolume = ConvexVolume.new()
			cv.init_from_mesh_vector_data(mvd)
			
			var face_mesh:MeshInstance3D = MeshInstance3D.new()
			%meshes.add_child(face_mesh)
			face_mesh.mesh = create_mesh_faces(cv, uv_mesh_faces_mat, face_sel_color, face_unsel_color)
			
			var edge_mesh:MeshInstance3D = MeshInstance3D.new()
			%meshes.add_child(edge_mesh)
			edge_mesh.mesh = create_mesh_edges(cv, uv_mesh_edges_mat, edge_sel_color, edge_unsel_color)
		
		dirty = false
	pass
