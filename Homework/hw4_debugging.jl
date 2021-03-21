``## returns lowest possible sum energy at pixel (i, j), and the column to jump to in row i+1.

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


function least_energy_matrix(energies)
	result = copy(energies)
	m,n = size(energies)

	for row in m-1:-1:1 #iterate through rows, bottom up

		#edge cases #result[i,j] is energies[i,j] plus the lowest of the 3 below
		result[row, 1] = energies[row, 1] + min([result[row+1, 1], result[row+1, 2]]...)
		result[row, n] = energies[row, n] + min([result[row+1, n], result[row+1, n-1]]...)

		#iterate through cols 2 to n-1
		for col in 2:n-1
			result[row, col] = energies[row, col] + min([result[row, i] for i in col-1:col+1]...)
		end
	end

	return result
end

grant_example
