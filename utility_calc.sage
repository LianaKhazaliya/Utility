import argparse
import os  
import subprocess
from copy import copy
from pprint import pprint
from sage.graphs.graph_latex import check_tkz_graph

#./sage ./code/utility_calc.sage ./code/graph5.g6 ./code/table.tex

def get_args():
    parser = argparse.ArgumentParser(description='Decoding')
    parser.add_argument('input_file', type=str, help='File')
    parser.add_argument('output_file', type=str, help='File')
    args = parser.parse_args()

    return args

def FloydWarshall(adjacency_matrix):
	n = len(adjacency_matrix)
	dist_matrix = [[float('inf') for i in range(n)] for j in range(n)]
	for i in range(n):
		for j in range(n):
			if i == j:
				dist_matrix[i][j] = 0
			elif adjacency_matrix[i][j] == 1:
				dist_matrix[i][j] = 1
	for k in range(n):
		for i in range(n):
			for j in range(n):
				if dist_matrix[i][j] > dist_matrix[i][k] + dist_matrix[k][j]:
					dist_matrix[i][j] = dist_matrix[i][k] + dist_matrix[k][j]

	return dist_matrix

def get_utility(dist_matrix):
	general_utility = 0
	n = len(dist_matrix)
	for i in range(n):
		utility = 0
		for j in range(n):
			if dist_matrix[i][j] != float('inf') and dist_matrix[i][j] != 0:
				utility += 1/dist_matrix[i][j]
		general_utility += utility

	return general_utility

def graph_to_img(graph, number, folder_path):
	path = folder_path+'/G'+str(number)+'.png'
	graph.plot().save(path)

	return 'graphs'+'/G'+str(number)+'.png'

def get_data(g6file, texfile):
	g6graph = g6file.readline()
	k = 1
	while g6graph != '':			
		graph = Graph(g6graph)
		adjacency_matrix = list(graph.adjacency_matrix())
		dist_matrix = FloydWarshall(adjacency_matrix)
		utility = get_utility(dist_matrix)
		img = graph_to_img(graph, k, './code/graphs')
		write_to_tex2(graph, utility, texfile, k)
		k += 1
		g6graph = g6file.readline()

def write_to_tex(texfile, img, utility):
	texfile.write(str(utility)+'\\begin{center}\\includegraphics{'+img+'}\\end{center}\n')
	
def get_all(input_file, output_file):
	try:
		open_files(input_file, output_file)
	except:
		message = ['Please, try one more time','Write paths to executable, graph6 and tex files separated with spaces',
			'Something like', 'sage utility_calc.sage graph5.g6 table.tex']
		print('\n'.join(message))
	else:
		with open(input_file, mode='r') as g6file, open(output_file, mode='w') as texfile:
			get_data(g6file, texfile)

def open_files(input_file, output_file):
	assert (input_file.split('.')[-1] == 'g6' and output_file.split('.')[-1] == 'tex')

def set_tex_opt(graph):
	graph.set_latex_options(
		graphic_size=(3,3),
		vertex_size=0.2,
		edge_thickness=0.04,
		edge_color='green',
		vertex_color='green',
		vertex_label_color='red'
		)

def write_to_tex2(graph, utility, texfile, k):
	set_tex_opt(graph)
	if k%3 == 1 or k%3 == 2:
		texfile.write(str(utility)+'&'+latex(graph)+'&')
	else:
		texfile.write(str(utility)+'&'+latex(graph)+'\\\\ \n \\hline ')

def generate_tex(output_file):
	pass

def compile_tex():
	os.system('cd code')
	os.system('pdflatex data.tex')


if __name__ == '__main__':
	args = get_args()
	get_all(args.input_file, args.output_file)
	print('Compile data.tex file and enjoy result obtained')
	#compile_tex()
	#get_all('./code/graph5.g6', './code/table.tex')
