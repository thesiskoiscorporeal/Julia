begin
	#using Images
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
	output = [0 for i in 1:length(v)] #create output vector of zeros
	convert(Array{Float64,1}, output) #convert array to Float64
	l = (length(k)-1)÷2 #length(k)=2l+1 ⟹ l = (length(k)-1)÷2
	k_new = OffsetArray(k, -l:l) #set indices of k from -l to l
	for i in 1:length(v) #iterate through indices of output
		terms = [extend(v,i-m) * k_new[m] for m in -l:l]
		output[i]=my_sum(terms) #set output[i] to equal vᵢ′defined above	
	end
	return output
end

function box_blur_kernel(len)
	return [1/len for i in 1:len]
end


begin
	kernel = box_blur_kernel(3)
    println(kernel)
	vec_to_use = [1,10,100]
	new_vec = convolve(vec_to_use,kernel)
	println(new_vec)
end