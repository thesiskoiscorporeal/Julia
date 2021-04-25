function euler_SIR_step(β, γ, sir_0::Vector, h::Number)
	s, i, r = sir_0

	return [
		s - h * β*s*i, #s(t) - infected
		i - h * (β*s*i - γ*i), #i(t) + infected - recovered
		r + h * γ*i, #r(t) + recovered
	]
end


function euler_SIR(β, γ, sir_0::Vector, T::AbstractRange)
	# T is a range, you get the step size and number of steps like so:
	h = step(T)

	num_steps = length(T)

	output = [sir_0]

	for i in 1:num_steps-1
		push!(output, euler_SIR_step(β, γ, last(output), h))
	end
	return output
end

sir_T = 0 : 0.1 : 60.0

sir_results = euler_SIR(0.3, 0.15,
	[0.99, 0.01, 0.00],
	sir_T)
