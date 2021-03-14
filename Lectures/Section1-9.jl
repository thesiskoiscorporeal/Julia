### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ b677c6d1-9d7b-41d3-80a4-b38b5f51c7fb
filter!(LOAD_PATH) do path
	path != "@v#.#"
end;

# ╔═╡ 21e744b8-f0d1-11ea-2e09-7ffbcdf43c37
begin
	import Pkg
	
	Pkg.activate(mktempdir())
	Pkg.add([
		Pkg.PackageSpec(name="ImageIO", version="0.5"),
		Pkg.PackageSpec(name="ImageShow", version="0.2"),
		Pkg.PackageSpec(name="FileIO", version="1.6"),
		Pkg.PackageSpec(name="PNGFiles", version="0.3.6"),
		Pkg.PackageSpec(name="Colors", version="0.12"),
		Pkg.PackageSpec(name="ColorVectorSpace", version="0.8"),
        Pkg.PackageSpec(name="ImageFiltering", version="0.6"),

		Pkg.PackageSpec(name="PlutoUI", version="0.7"), 
		Pkg.PackageSpec(name="Plots", version="1.10"), 
		Pkg.PackageSpec(name="Compose", version="0.9"),
		Pkg.PackageSpec(name="Hyperscript", version="0.0.4"),
		Pkg.PackageSpec(name="Gadfly", version="1.3"),
	])
	
	using Gadfly
	using Colors, ColorVectorSpace, ImageShow, FileIO
	using ImageFiltering
	using Compose
	using Hyperscript
	using PlutoUI
	
	using Statistics
end

# ╔═╡ a3056031-6a4e-4552-a6d6-10333bc321d0
md"""
#### Intializing packages

_When running this notebook for the first time, this could take up to 15 minutes. Hang in there!_
"""

# ╔═╡ 1ab1c808-f0d1-11ea-03a7-e9854427d45f
md"""
# Applying Sobel filters to calculate gradients of images
"""

# ╔═╡ 10f850fc-f0d1-11ea-2a58-2326a9ea1e2a
set_default_plot_size(12cm, 12cm)

# ╔═╡ 7b4d5270-f0d3-11ea-0b48-79005f20602c
function convolve(M, kernel)
    height, width = size(kernel)
    
    half_height = height ÷ 2
    half_width = width ÷ 2
    
    new_image = similar(M)
	
    # (i, j) loop over the original image
	m, n = size(M)
    @inbounds for i in 1:m
        for j in 1:n
            # (k, l) loop over the neighbouring pixels
			accumulator = 0 * M[1, 1]
			for k in -half_height:-half_height + height - 1
				for l in -half_width:-half_width + width - 1
					Mi = i - k
					Mj = j - l
					# First index into M
					if Mi < 1
						Mi = 1
					elseif Mi > m
						Mi = m
					end
					# Second index into M
					if Mj < 1
						Mj = 1
					elseif Mj > n
						Mj = n
					end
					
					accumulator += kernel[k, l] * M[Mi, Mj]
				end
			end
			new_image[i, j] = accumulator
        end
    end
    
    return new_image
end

# ╔═╡ 6fd3b7a4-f0d3-11ea-1f26-fb9740cd16e0
function disc(n, r1=0.8, r2=0.8)
	white = RGB{Float64}(1,1,1)
	blue = RGB{Float64}(colorant"#4EC0E3")
	convolve(
		[(i-n/2)^2 + (j-n/2)^2 <= (n/2-5)^2 ? white : blue for i=1:n, j=1:n],
		Kernel.gaussian((1,1))
	)
end

# ╔═╡ fe3559e0-f13b-11ea-06c8-a314e44c20d6
brightness(c) = 0.3 * c.r + 0.59 * c.g + 0.11 * c.b

# ╔═╡ 0ccf76e4-f0d9-11ea-07c9-0159e3d4d733
@bind img_select Radio(["disc", "mario"], default="disc")

# ╔═╡ 236dab08-f13d-11ea-1922-a3b82cfc7f51
images = let
	url = "https://user-images.githubusercontent.com/6933510/110993432-950df980-8377-11eb-82e7-b7ce4a0d04bc.png"
	Dict(
		"disc" => disc(25),
		"mario" => load(download(url))
	)
end;

# ╔═╡ 7bc364d8-24e2-4866-990a-e780879d4b7f
img = images[img_select];

# ╔═╡ 03434682-f13b-11ea-2b6e-11ad781e9a51
md"""Show $G_x$ $(@bind Gx CheckBox())

     Show $G_y$ $(@bind Gy CheckBox())"""

# ╔═╡ ca13597a-f168-11ea-1a2c-ff7b98b7b2c7
function partial_derivatives(img)
	Sy,Sx = Kernel.sobel()
	∇x, ∇y = zeros(size(img)), zeros(size(img))

	if Gx
		∇x = convolve(brightness.(img), Sx)
	end
	if Gy
		∇y = convolve(brightness.(img), Sy)
	end
	return ∇x, ∇y
end

# ╔═╡ 9d9cccb2-f118-11ea-1638-c76682e636b2
function arrowhead(θ)
	eq_triangle = [(0, 1/sqrt(3)),
		           (-1/3, -2/(2 * sqrt(3))),
		           (1/3, -2/(2 * sqrt(3)))]

	compose(context(units=UnitBox(-1,-1,2,2), rotation=Rotation(θ, 0, 0)),
				polygon(eq_triangle))
end

# ╔═╡ b7ea8a28-f0d7-11ea-3e98-7b19a1f58304
function quiver(points, vecs)
	xmin = minimum(first.(points))
	ymin = minimum(last.(points))
	xmax = maximum(first.(points))
	ymax = maximum(last.(points))
	hs = map(x->hypot(x...), vecs)
	hs = hs / maximum(hs)

	vector(p, v, h) = all(iszero, v) ? context() :
		(context(),
		    (context((p.+v.*6 .- .2)..., .4,.4),
				arrowhead(atan(v[2], v[1]) - pi/2)),
		stroke(RGBA(90/255,39/255,41/255,h)),
		fill(RGBA(90/255,39/255,41/255,h)),
		line([p, p.+v.*8]))

	compose(context(units=UnitBox(xmin,ymin,xmax,ymax)),
         vector.(points, vecs, hs)...)
end

# ╔═╡ c821b906-f0d8-11ea-2df0-8f2d06964aa2
function sobel_quiver(img, ∇x, ∇y)
    quiver([(j-1,i-1) for i=1:size(img,1), j=1:size(img,2)],
           [(∇x[i,j], ∇y[i,j]) for i=1:size(img,1), j=1:size(img,2)])
end

# ╔═╡ 6da3fdfe-f0dd-11ea-2407-7b85217b35cc
# render an Image using squares in Compose
function compimg(img)
	xmax, ymax = size(img)
	xmin, ymin = 0, 0
	arr = [(j-1, i-1) for i=1:ymax, j=1:xmax]

	compose(context(units=UnitBox(xmin, ymin, xmax, ymax)),
		fill(vec(img)),
		rectangle(
			first.(arr),
			last.(arr),
			fill(1.0, length(arr)),
			fill(1.0, length(arr))))
end

# ╔═╡ f22aa34e-f0df-11ea-3053-3dcdc070ec2f
let
	∇x, ∇y = partial_derivatives(img)

	compose(context(),
		sobel_quiver(img, ∇x, ∇y),
		compimg(img))
end

# ╔═╡ 885ec336-f146-11ea-00c4-c1d1ab4c0001
	function show_colored_array(array)
		pos_color = RGB(0.36, 0.82, 0.8)
		neg_color = RGB(0.99, 0.18, 0.13)
		to_rgb(x) = max(x, 0) * pos_color + max(-x, 0) * neg_color
		to_rgb.(array) / maximum(abs.(array))
	end

# ╔═╡ 9232dcc8-f188-11ea-08fe-b787ea93c598
begin
	Sy, Sx = Kernel.sobel()
	show_colored_array(Sx)
	Sx
end

# ╔═╡ 7864bd00-f146-11ea-0020-7fccb3913d8b
let
	∇x, ∇y = partial_derivatives(img)

	to_show = (x -> RGB(0, 0, 0)).(zeros(size(img)))
	if Gx && Gy
		edged = sqrt.(∇x.^2 + ∇y.^2)
		to_show = Gray.(edged) / maximum(edged)
	elseif Gx
		to_show = show_colored_array(∇x)
	elseif Gy
		to_show = show_colored_array(∇y)
	end
	compose(
		context(),
		compimg(to_show)
	)
end

# ╔═╡ Cell order:
# ╟─a3056031-6a4e-4552-a6d6-10333bc321d0
# ╠═21e744b8-f0d1-11ea-2e09-7ffbcdf43c37
# ╟─b677c6d1-9d7b-41d3-80a4-b38b5f51c7fb
# ╟─1ab1c808-f0d1-11ea-03a7-e9854427d45f
# ╠═10f850fc-f0d1-11ea-2a58-2326a9ea1e2a
# ╟─7b4d5270-f0d3-11ea-0b48-79005f20602c
# ╠═6fd3b7a4-f0d3-11ea-1f26-fb9740cd16e0
# ╟─fe3559e0-f13b-11ea-06c8-a314e44c20d6
# ╟─b7ea8a28-f0d7-11ea-3e98-7b19a1f58304
# ╟─0ccf76e4-f0d9-11ea-07c9-0159e3d4d733
# ╠═236dab08-f13d-11ea-1922-a3b82cfc7f51
# ╠═7bc364d8-24e2-4866-990a-e780879d4b7f
# ╟─03434682-f13b-11ea-2b6e-11ad781e9a51
# ╟─ca13597a-f168-11ea-1a2c-ff7b98b7b2c7
# ╠═f22aa34e-f0df-11ea-3053-3dcdc070ec2f
# ╟─9232dcc8-f188-11ea-08fe-b787ea93c598
# ╠═7864bd00-f146-11ea-0020-7fccb3913d8b
# ╟─9d9cccb2-f118-11ea-1638-c76682e636b2
# ╟─c821b906-f0d8-11ea-2df0-8f2d06964aa2
# ╟─6da3fdfe-f0dd-11ea-2407-7b85217b35cc
# ╠═885ec336-f146-11ea-00c4-c1d1ab4c0001
