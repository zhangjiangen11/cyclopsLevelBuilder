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
class_name CommandMoveFaces
extends CyclopsCommand

class BlockFaceChanges extends RefCounted:
	var block_path:NodePath
	var face_indices:Array[int] = []
	var tracked_block_data:MeshVectorData

#Public 
var move_offset:Vector3 = Vector3.ZERO

#Private
var block_map:Dictionary = {}


func add_face(block_path:NodePath, index:int):
#	print("Adding face %s %s" % [block_path, index])
	add_faces(block_path, [index])
	
func add_faces(block_path:NodePath, indices:Array[int]):
	var changes:BlockFaceChanges
	if block_map.has(block_path):
		changes = block_map[block_path]
	else:
		changes = BlockFaceChanges.new()
		changes.block_path = block_path
		var block:CyclopsBlock = builder.get_node(block_path)
		changes.tracked_block_data = block.mesh_vector_data
		block_map[block_path] = changes

	for index in indices:
		if !changes.face_indices.has(index):
			changes.face_indices.append(index)


func _init():
	command_name = "Move faces"


func pre_do_it():
#	print("cmd move edges- DO IT")
	
	for block_path in block_map.keys():
		
#		print("%s" % block_path)
		
		var block:CyclopsBlock = builder.get_node(block_path)
		var rec:BlockFaceChanges = block_map[block_path]
		
		var w2l:Transform3D = block.global_transform.affine_inverse()
		var move_offset_local:Vector3 = w2l.basis * move_offset
#		print("rec %s" % rec)
		
		var vol:ConvexVolume = ConvexVolume.new()
		vol.init_from_mesh_vector_data(rec.tracked_block_data)

		var vert_indices:PackedInt32Array
		for f_index in rec.face_indices:
			var f:ConvexVolume.FaceInfo = vol.faces[f_index]
			for v_idx in f.vertex_indices:
				if !vert_indices.has(v_idx):
					vert_indices.append(v_idx)
		
		for v_idx in vert_indices:
			var v:ConvexVolume.VertexInfo = vol.vertices[v_idx]
			v.point += move_offset_local

		block.mesh_vector_data = vol.to_mesh_vector_data()

####
#		print("init done")

		#var new_points:PackedVector3Array
		#var new_sel_centroids:PackedVector3Array
		#var moved_vert_indices:Array[int] = []
		#for face_index in rec.face_indices:
			#var f:ConvexVolume.FaceInfo = vol.faces[face_index]
			#var centroid:Vector3 = f.get_centroid()
##			var v0:ConvexVolume.VertexInfo = vol.vertices[e.start_index]
##			var v1:ConvexVolume.VertexInfo = vol.vertices[e.end_index]
			#if f.selected:
				#new_sel_centroids.append(centroid + move_offset_local)
				#
				#for v_idx in f.vertex_indices:
					#if !moved_vert_indices.has(v_idx):
						#new_points.append(vol.vertices[v_idx].point + move_offset_local)
						#moved_vert_indices.append(v_idx)
			#else:
				#for v_idx in f.vertex_indices:
					#if !moved_vert_indices.has(v_idx):
						#new_points.append(vol.vertices[v_idx].point + move_offset_local)
						#moved_vert_indices.append(v_idx)
		#
		#for v_idx in vol.vertices.size():
			#if !moved_vert_indices.has(v_idx):
				#new_points.append(vol.vertices[v_idx].point)
		##print("new points_ %s" % new_points)
		#
		#var new_vol:ConvexVolume = ConvexVolume.new()
		#new_vol.init_from_points(new_points)
#
		#new_vol.copy_face_attributes(vol)
		##print("new init done")
		#
		##Copy selection data
		#for f_idx in new_vol.faces.size():
			#var f_new:ConvexVolume.FaceInfo = new_vol.faces[f_idx]
			#var centroid:Vector3 = f_new.get_centroid()
##			print ("vol point %s " % v1.point)
			#if new_sel_centroids.has(centroid):
##				print("set sel")
				#f_new.selected = true
#
		#block.mesh_vector_data = new_vol.to_mesh_vector_data()

func do_it():
	pre_do_it()
#
	#for block_path in block_map.keys():
		#var selected_points:PackedVector3Array
		#var new_points:PackedVector3Array
#
		#var rec:BlockFaceChanges = block_map[block_path]
		#var vol:ConvexVolume = ConvexVolume.new()
		#vol.init_from_mesh_vector_data(rec.tracked_block_data)
##		
		#for v_idx in vol.vertices.size():
			#if rec.vertex_indices.has(v_idx):
				#var p:Vector3 = vol.vertices[v_idx].point
				#new_points.append(p)
				#selected_points.append(p)
			#else:
				#new_points.append(vol.vertices[v_idx].point)
				#
		#
		#var new_vol:ConvexVolume = ConvexVolume.new()
		#new_vol.init_from_points(new_points)
		#
		#new_vol.copy_face_attributes(vol)
		#
		#for v_idx in new_vol.vertices.size():
			#var v:ConvexVolume.VertexInfo = new_vol.vertices[v_idx]
##			print ("vol point %s " % v.point)
			#if selected_points.has(v.point):
##				print("set sel")
				#v.selected = true
#
		#var block:CyclopsBlock = builder.get_node(block_path)
		#block.mesh_vector_data = new_vol.to_mesh_vector_data()
##########

func undo_it():
	for block_path in block_map.keys():
		var rec:BlockFaceChanges = block_map[block_path]
		var block:CyclopsBlock = builder.get_node(block_path)
		block.mesh_vector_data = rec.tracked_block_data
