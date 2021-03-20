## returns lowest possible sum energy at pixel (i, j), and the column to jump to in row i+1.

function least_energy(energies, i, j)
	m, n = size(energies)

	# base case, last row
	if i == m
	    return (energies[i,j], j) # no need for recursive computation in the base case!
	end

	# induction

	bestindex = 0
	bestenergy = 1
	for col in clamp(j-1, 1, n):clamp(j+1, 1, n)
		if least_energy(energies, i+1, col)[1] < bestenergy
			bestenergy = least_energy(energies, i+1, col)[1]
			bestindex = col
			println(col)
		end
	end

	return (energies[i,j] + bestenergy, bestindex)

end


grant_example =

[0.1  0.8  0.8  0.3  0.5  0.4
0.7  0.8  0.1  0.0  0.8  0.4
0.8  0.0  0.4  0.7  0.2  0.9
0.9  0.0  0.0  0.5  0.9  0.4
0.2  0.4  0.0  0.2  0.4  0.5
0.2  0.4  0.2  0.5  0.3  0.0]
