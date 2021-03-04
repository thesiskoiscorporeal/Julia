begin
	using Images
	#using PlutoUI
	#using HypertextLiteral
	using OffsetArrays
end

function my_sum(xs)
	s = 0
	for i in 1:length(xs)
		s += xs[i]
	end
	return s
end

function extend(v::AbstractVector, i)
	return v[clamp(i,1,length(v))] #thank you clamp()
end

function convolve(v::AbstractVector, k)
	output = Float64[0 for i in 1:length(v)] #create output vector of zeros
	l = (length(k)-1)÷2 #length(k)=2l+1 ⟹ l = (length(k)-1)÷2
	k_new = OffsetArray(k, -l:l) #set indices of k from -l to l
	for i in 1:length(v) #iterate through indices of output
		terms = [extend(v,i-m) * k_new[m] for m in -l:l]
		output[i]=my_sum(terms) #set output[i] to equal vᵢ′defined above	
	end
	return output
end

function box_blur_kernel(l)
	len = 2*l+1
	return [1/len for i in 1:len]
end


begin
	kernel = box_blur_kernel(1)
    println(kernel)
	vec_to_use = [1,10,100]
	new_vec = convolve(vec_to_use,kernel)
	println(new_vec)
end


function extend(M::AbstractMatrix, i, j)
	i_new = clamp(i, 1, size(M)[1])
	j_new = clamp(j, 1, size(M)[2])
	return M[i_new,j_new]
end

function convolve(M::AbstractMatrix, K::AbstractMatrix)
	output = copy(M)
	l = (size(K)[1]-1)÷2
	K_new = OffsetArray(K, -l:l, -l:l)
	for i in 1:size(M)[1], j = 1:size(M)[2]
		M_slice = [extend(M, i-q, j-r) for q = -l:l, r=-l:l]
		output[i,j] = sum(M_slice .* K)
	end
	return output
end

begin
	K_test = [
		0   0  0
		1/2 0  1/2
		0   0  0
	]

	small_image = Gray.(rand(5,5))
	test_image_with_border = [get(small_image, (i, j), Gray(0)) for (i,j) in Iterators.product(-1:7,-1:7)]


	x = convolve(test_image_with_border, K_test)
