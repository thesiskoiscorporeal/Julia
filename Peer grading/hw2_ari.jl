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

# ╔═╡ f7a6d7c3-37b9-437d-8b8e-853665ddbae3
filter!(LOAD_PATH) do path
	path != "@v#.#"
end;

# ╔═╡ 65780f00-ed6b-11ea-1ecf-8b35523a7ac0
begin
	import Pkg
	Pkg.activate(mktempdir())
	Pkg.add([
			Pkg.PackageSpec(name="Images", version="0.22.4"), 
			Pkg.PackageSpec(name="ImageMagick", version="0.7"), 
			Pkg.PackageSpec(name="PlutoUI", version="0.7"), 
			Pkg.PackageSpec(name="HypertextLiteral", version="0.5"),
			Pkg.PackageSpec(name="OffsetArrays"),
			#=Pkg.PackageSpec(name="ColorSchemes"),
			Pkg.PackageSpec(name="Plots"),
			Pkg.PackageSpec(name="ImageFiltering"),=#
			])
	using Images
	using PlutoUI
	using HypertextLiteral
	using OffsetArrays
	#= Packages I use for extra stuff or checking:
	using ColorSchemes
	using Plots
	using ImageFiltering=#
end

# ╔═╡ 83eb9ca0-ed68-11ea-0bc5-99a09c68f867
md"_homework 2, version 1_"

# ╔═╡ ac8ff080-ed61-11ea-3650-d9df06123e1f
md"""

# **Homework 2** - _convolutions_
`18.S191`, Spring 2021

`Due Date`: **Friday Mar 5, 2021 at 11:59pm EST**

This notebook contains _built-in, live answer checks_! In some exercises you will see a coloured box, which runs a test case on your code, and provides feedback based on the result. Simply edit the code, run it, and the check runs again.

_For MIT students:_ there will also be some additional (secret) test cases that will be run as part of the grading process, and we will look at your notebook and write comments.

Feel free to ask questions!
"""

# ╔═╡ 911ccbce-ed68-11ea-3606-0384e7580d7c
# edit the code below to set your name and kerberos ID (i.e. email without @mit.edu)

student = (name = "Ari", kerberos_id = "SOLUTIONS")

# press the ▶ button in the bottom right of this cell to run your edits
# or use Shift+Enter

# you might need to wait until all other cells in this notebook have completed running. 
# scroll down the page to see what's up

# ╔═╡ 8ef13896-ed68-11ea-160b-3550eeabbd7d
md"""

Submission by: **_$(student.name)_** ($(student.kerberos_id)@mit.edu)
"""

# ╔═╡ 5f95e01a-ee0a-11ea-030c-9dba276aba92
md"_Let's create a package environment:_"

# ╔═╡ e08781fa-ed61-11ea-13ae-91a49b5eb74a
md"""

## **Exercise 1** - _Convolutions in 1D_

As we have seen in the lectures, we can produce cool effects using the mathematical technique of **convolutions**. We input one image $M$ and get a new image $M'$ back. 

Conceptually we think of $M$ as a matrix. In practice, in Julia it will be a `Matrix` of color objects, and we may need to take that into account. Ideally, however, we should write a **generic** function that will work for any type of data contained in the matrix.

A convolution works on a small **window** of an image, i.e. a region centered around a given point $(i, j)$. We will suppose that the window is a square region with odd side length $2\ell + 1$, running from $-\ell, \ldots, 0, \ldots, \ell$.

The result of the convolution over a given window, centred at the point $(i, j)$ is a *single number*; this number is the value that we will use for $M'_{i, j}$.
(Note that neighbouring windows overlap.)

To get started, in Exercise 1 we'll restrict ourselves to convolutions in 1D.
So a window is just a 1D region from $-\ell$ to $\ell$.

"""

# ╔═╡ 80108d80-ee09-11ea-0368-31546eb0d3cc
md"""
#### Exercise 1.1

Let's create a vector `v` of random numbers of length `n=100`.
"""

# ╔═╡ 7fcd6230-ee09-11ea-314f-a542d00d582e
n = 50

# ╔═╡ 343273a4-79de-11eb-0e8d-a7bad6ec09eb
begin
	v = rand(n)
end

# ╔═╡ 7fe9153e-ee09-11ea-15b3-6f24fcc20734
md"_Feel free to experiment with different values!_

Let's use the function `colored_line` to view this 1D number array as a 1D image.
"

# ╔═╡ ff70782e-e8d2-4281-9b24-d45c925f55e2
begin
	colored_line(x::Vector) = hcat(Gray.(Float64.(x)))'
	colored_line(x::Any) = nothing
end

# ╔═╡ e06f7f0a-7cf3-11eb-3490-a789d466d347
colored_line(v)

# ╔═╡ 7522f81e-ee1c-11ea-35af-a17eb257ff1a
md"👉 Try changing `n` and `v` around. Notice that you can run the cell `v = rand(n)` again to regenerate new random values."

# ╔═╡ 801d90c0-ee09-11ea-28d6-61b806de26dc
md"""
#### Exercise 1.2
We need to decide how to handle the **boundary conditions**, i.e. what happens if we try to access a position in the vector `v` beyond `1:n`.  The simplest solution is to assume that $v_{i}$ is 0 outside the original vector; however, this may lead to strange boundary effects.
    
A better solution is to use the *closest* value that is inside the vector. Effectively we are extending the vector and copying the extreme values into the extended positions. (Indeed, this is one way we could implement this; these extra positions are called **ghost cells**.)

👉 Write a function `extend(v, i)` that checks whether the position $i$ is inside `1:n`. If so, return the $(HTML("<br>")) ``i``th component of `v`; otherwise, return the nearest end value.
"""

# ╔═╡ cc441320-7a95-11eb-0c8f-1bf0e39bef44
function extend(v::AbstractVector, i)
	v[clamp(i, firstindex(v), lastindex(v))]
end

# ╔═╡ b7f3994c-ee1b-11ea-211a-d144db8eafc2
md"_Some test cases:_"

# ╔═╡ 3492b164-7065-48e8-978b-6c96b965d376
begin
	exvec = [0.8, 0.2, 0.1, 0.7, 0.6, 0.4]
	example_vector = [exvec ; exvec ; exvec]
end

# ╔═╡ 880f773c-7b3d-11eb-2ab7-0709c2ffe4af
colored_line(example_vector)

# ╔═╡ 806e5766-ee0f-11ea-1efc-d753cd83d086
md"- Extended with 0:"

# ╔═╡ 38da843a-ee0f-11ea-01df-bfa8b1317d36
colored_line([0, 0, example_vector..., 0, 0])

# ╔═╡ 9bde9f92-ee0f-11ea-27f8-ffef5fce2b3c
md"- Extended with your `extend` function:"

# ╔═╡ 431ba330-0f72-416a-92e9-55f51ff3bcd1
md"""
#### Exercise 1.3
👉 Write (or copy) the `mean` function from Homework 1, which takes a vector and returns the mean.

"""

# ╔═╡ 5fdc5d0d-a52c-476e-b3b5-3b6364b706e4
mean(xs) = sum(xs)/length(xs)

# ╔═╡ e84c9cc2-e6e1-46f1-bf4e-9605da5e6f4a
md"""

👉 Write a function `box_blur(v, l)` that blurs a vector `v` with a window of length `l` by averaging the elements within a window from $-\ell$ to $\ell$. This is called a **box blur**. Use your function `extend` to handle the boundaries correctly.

Return a vector of the same size as `v`.
"""

# ╔═╡ d2c36ca6-7beb-11eb-0140-2f1bc7e33819
zeros(size(example_vector))

# ╔═╡ 8c2a70d8-79da-11eb-055a-331e9d191e2a
colored_line(example_vector)

# ╔═╡ 809f5330-ee09-11ea-0e5b-415044b6ac1f
md"""
#### Exercise 1.4
👉 Apply the box blur to your vector `v`. Show the original and the new vector by creating two cells that call `colored_line`. Make the parameter $\ell$ interactive, and call it `l_box` instead of `l` to avoid a naming conflict.
"""

# ╔═╡ e555a7e6-f11a-43ac-8218-6d832f0ce251
@bind l_box Slider(0:10, show_value=true)

# ╔═╡ 80ab64f4-ee09-11ea-29b4-498112ed0799
md"""
#### Exercise 1.5
The box blur is a simple example of a **convolution**, i.e. a linear function of a window around each point, given by 

$$v'_{i} = \sum_{m}  \, v_{i - m} \, k_{m},$$

where $k$ is a vector called a **kernel**.
    
Again, we need to take care about what happens if $v_{i -m }$ falls off the end of the vector.
    
👉 Write a function `convolve(v, k)` that performs this convolution. You need to think of the vector $k$ as being *centred* on the position $i$. So $m$ in the above formula runs between $-\ell$ and $\ell$, where $2\ell + 1$ is the length of the vector $k$. 

   You will either need to do the necessary manipulation of indices by hand, or use the `OffsetArrays.jl` package.
"""

# ╔═╡ cf73f9f8-ee12-11ea-39ae-0107e9107ef5
md"_Edit the cell above, or create a new cell with your own test cases!_"

# ╔═╡ fa463b71-5aa4-44a3-a67b-6b0776236243
md"""
#### Exercise 1.6

👉 Define a function `box_blur_kernel(l)` which returns a _kernel_ (i.e. a vector) which, when used as the kernel in `convolve`, will reproduce a box blur of length `l`.
"""

# ╔═╡ 8a7d3cfd-6f19-43f0-ae16-d5a236f148e7
function box_blur_kernel(l)
	α = l*2 + 1
	k = [1/α for i in 1:α]
	return k
end

# ╔═╡ a34d1ad8-3776-4bc4-93e5-72cfffc54f15
@bind box_kernel_l Slider(1:5, show_value=true)

# ╔═╡ 971a801d-9c46-417a-ad31-1144894fb4e1
box_blur_kernel_test = box_blur_kernel(box_kernel_l)

# ╔═╡ 5f13b1a5-8c7d-47c9-b96a-a09faf38fe5e
md"""
Let's apply your kernel to our test vector `v` (first cell), and compare the result to our previous box blur function (second cell). The two should be identical.
"""

# ╔═╡ 03f91a22-1c3e-4c42-9d78-1ee36851a120
md"""
#### Exercise 1.7
👉 Write a function `gaussian_kernel`.

The definition of a Gaussian in 1D is

$$G(x) = \frac{1}{\sqrt{2\pi \sigma^2}} \exp \left( \frac{-x^2}{2\sigma^2} \right),$$

or as a Julia function:
"""

# ╔═╡ 48530f0d-49b4-4aec-8109-d69f1ef7f0ee
md"""
Write a function `gauss` that takes `σ` as a keyword argument and implements this function.
"""

# ╔═╡ beb62fda-38a6-4528-a176-cfb726f4b5bd
gauss(x::Real; σ=1) = 1 / sqrt(2π*σ^2) * exp(-x^2 / (2 * σ^2))

# ╔═╡ f0d55cec-2e81-4cbb-b166-2cf4f2a0f43f
md"""
We need to **sample** (i.e. evaluate) this at each pixel in an interval of length $2n+1$,
and then **normalize** so that the sum of the resulting kernel is 1.
"""

# ╔═╡ 27fcb544-7bf1-11eb-0565-f9aa208239a1
@bind sigma Slider(0.01:0.01:2.0, show_value=true, default=1.0)

# ╔═╡ f8bd22b8-ee14-11ea-04aa-ab16fd01826e
md"""
You can edit the cell above to test your kernel function!

Let's try applying it in a convolution.
"""

# ╔═╡ 2a9dd06a-ee13-11ea-3f84-67bb309c77a8
@bind gaussian_kernel_size_1D Slider(0:6)

# ╔═╡ ce24e486-df27-4780-bc57-d3bf7bee83bb
function create_bar()
	x = zeros(100)
	x[41:60] .= 1
	x
end

# ╔═╡ b01858b6-edf3-11ea-0826-938d33c19a43
md"""
 
   
## **Exercise 2** - _Convolutions in 2D_
    
Now let's move to 2D images. The convolution is then given by a **kernel matrix** $K$:
    
$$M'_{i, j} = \sum_{k, l}  \, M_{i- k, j - l} \, K_{k, l},$$
    
where the sum is over the possible values of $k$ and $l$ in the window. Again we think of the window as being *centered* at $(i, j)$.

A common notation for this operation is $\star$:

```math
M' = M \star K
```
"""

# ╔═╡ 7c1bc062-ee15-11ea-30b1-1b1e76520f13
md"""
#### Exercise 2.1
👉 Write a new method for `extend` that takes a matrix `M` and indices `i` and `j`, and returns the closest element of the matrix.
"""

# ╔═╡ 7c2ec6c6-ee15-11ea-2d7d-0d9401a5e5d1
function extend(M::AbstractMatrix, i, j)
	num_rows, num_columns = size(M)
	M[clamp(i, 1, num_rows), clamp(j, 1, num_columns)]
end

# ╔═╡ 46674714-7c06-11eb-39dc-7b37794dba3e
function extend(M::AbstractMatrix, I::CartesianIndex)
	extend(M, I[1], I[2])
end

# ╔═╡ e45e0d0c-7bea-11eb-26e3-bbad708f0cbf
# a test case for OffsetArray
[extend(OffsetArray([5,6,7], -1:1), i) for i in -2:2]

# ╔═╡ 803905b2-ee09-11ea-2d52-e77ff79693b0
extend([5,6,7], 1)

# ╔═╡ 80479d98-ee09-11ea-169e-d166eef65874
extend([5,6,7], -8)

# ╔═╡ 805691ce-ee09-11ea-053d-6d2e299ee123
extend([5,6,7], 10)

# ╔═╡ 45c4da9a-ee0f-11ea-2c5b-1f6704559137
if extend(v,1) === missing
	missing
else
	colored_line([extend(example_vector, i) for i in -1:length(example_vector)+2])
end

# ╔═╡ 39342550-79db-11eb-0fd1-9f5954292b7b
function window(v::AbstractArray, index, l)
	[extend(v,j) for j in (index-l):(index+l)]
end

# ╔═╡ 5ea5af78-79db-11eb-17d0-8f7347c0bac6
window([0.8, 0.2, 0.1, 0.7, 0.6, 0.4], 2, 2)

# ╔═╡ 807e5662-ee09-11ea-3005-21fdcc36b023
function box_blur(v::AbstractArray, l)
	res = zeros(size(v))  
	for i in eachindex(v)
		res[i] = mean(window(v, i, l))
	end
	return res
end

# ╔═╡ 4f08ebe8-b781-4a32-a218-5ecd8338561d
colored_line(box_blur(example_vector, 1))

# ╔═╡ 808deca8-ee09-11ea-0ee3-1586fa1ce282
let
	try
		test_v = rand(n)
		original = copy(test_v)
		box_blur(test_v, 5)
		if test_v != original
			md"""
			!!! danger "Oopsie!"
			    It looks like your function _modifies_ `v`. Can you write it without doing so? Maybe you can use `copy`.
			"""
		end
	catch
	end
end

# ╔═╡ 7d80a1ea-a0a9-41b2-9cfe-a334717ab2f4
colored_line(box_blur(v, l_box))

# ╔═╡ bbe1a562-8d97-4112-a88a-c45c260f574d
let
	result = box_blur(v, box_kernel_l)
	colored_line(result)
end

# ╔═╡ 1873053e-7a92-11eb-122e-f938355c458e
function convolve(v::AbstractVector, k)
	res = zeros(size(v)) 
	l = length(k) ÷ 2
	for i in eachindex(v)
		res[i] = sum(window(v, i, l) .* OffsetArrays.no_offset_view(k))
	end
	return res
end

# ╔═╡ 9afc4dca-ee16-11ea-354f-1d827aaa61d2
md"_Let's test it!_"

# ╔═╡ cf6b05e2-ee16-11ea-3317-8919565cb56e
small_image = Gray.(rand(5,5))

# ╔═╡ e3616062-ee27-11ea-04a9-b9ec60842a64
md"- Extended with `0`:"

# ╔═╡ e5b6cd34-ee27-11ea-0d60-bd4796540b18
[get(small_image, (i, j), Gray(0)) for (i,j) in Iterators.product(-1:7,-1:7)]

# ╔═╡ b4e98589-f221-4922-b11e-364d72d0788e


# ╔═╡ d06ea762-ee27-11ea-2e9c-1bcff86a3fe0
md"- Extended with your `extend` function:"

# ╔═╡ e1dc0622-ee16-11ea-274a-3b6ec9e15ab5
[extend(small_image, i, j) for (i,j) in Iterators.product(-1:7,-1:7)]

# ╔═╡ c23b5b20-7c1d-11eb-12b9-d3ef832f4fdb
[extend(small_image, CartesianIndex(i, j)) for (i,j) in Iterators.product(-1:7,-1:7)]

# ╔═╡ 4bbea325-35f8-4a51-bd66-153aba4aed96
md"""
### Extending Philip
"""

# ╔═╡ c4f5a867-74ba-4106-91d4-195f6ae644d0
url = "https://user-images.githubusercontent.com/6933510/107239146-dcc3fd00-6a28-11eb-8c7b-41aaf6618935.png" 

# ╔═╡ c825ebe2-511b-43ba-afdf-6226dbac48d2
philip_filename = download(url) # download to a local file. The filename is returned

# ╔═╡ 2701ab0c-b91d-47fe-b36b-4e0036ecd4aa
philip = load(philip_filename);

# ╔═╡ 84a48984-9adb-40ab-a1f1-1ab7b76c9a19
philip_head = philip[470:800, 140:410];

# ╔═╡ 3cd535e4-ee26-11ea-2482-fb4ad43dda19
[
	extend(philip_head, i, j) for 
		i in -50:size(philip_head,1)+51,
		j in -50:size(philip_head,2)+51
]

# ╔═╡ 7c41f0ca-ee15-11ea-05fb-d97a836659af
md"""
#### Exercise 2.2
👉 Implement a new method `convolve(M, K)` that applies a convolution to a 2D array `M`, using a 2D kernel `K`. Use your new method `extend` from the last exercise.
"""

# ╔═╡ d0dfa1e6-7cf8-11eb-1b86-f19b984eb9f1
function convolve(M::AbstractMatrix, K::AbstractMatrix)

	# Change the storage type of the image to float32
	m = float32.(M)
	
	# Result is similar to the input in float32
	res = similar(m)

	# Change the kernel to a centered offset array
	l = size(K)[1] ÷ 2
	k = OffsetArray(K, -l:l, -l:l)

	for m₁ in axes(M, 1), m₂ in axes(M, 2)
		res[m₁, m₂] = sum(
			extend(M, m₁+k₁, m₂+k₂) * k[k₁, k₂] for 
				k₁ in axes(k, 1), k₂ in axes(k, 2))
	end
	return res
end

# ╔═╡ 93284f92-ee12-11ea-0342-833b1a30625c
test_convolution = let
	v = [1, 10, 100, 1000, 10000]
	k = [1, 1, 0]
	convolve(v, k)
end

# ╔═╡ 5eea882c-ee13-11ea-0d56-af81ecd30a4a
colored_line(test_convolution)

# ╔═╡ 71ad21dc-7bed-11eb-2b71-5f060d0b25c7
test_convolution2 = let
	v = [1, 10, 100, 1000, 10000]
	k = OffsetArray([1, 1, 0], -1:1)
	convolve(v, k)
end

# ╔═╡ 338b1c3f-f071-4f80-86c0-a82c17349828
let
	result = convolve(v, box_blur_kernel_test)
	colored_line(result)
end

# ╔═╡ 5a5135c6-ee1e-11ea-05dc-eb0c683c2ce5
md"_Let's test it out! 🎃_"

# ╔═╡ 577c6daa-ee1e-11ea-1275-b7abc7a27d73
test_image_with_border = [get(small_image, (i, j), Gray(0)) for (i,j) in Iterators.product(-1:7,-1:7)]

# ╔═╡ 275a99c8-ee1e-11ea-0a76-93e3618c9588
K_test = [
	0   0  0
	1/2 0  1/2
	0   0  0
]

# ╔═╡ 6f2b8492-7d02-11eb-08ab-3f28916a75d0
convolve(test_image_with_border, K_test)

# ╔═╡ 42dfa206-ee1e-11ea-1fcd-21671042064c
convolve(test_image_with_border, K_test)

# ╔═╡ 37d85d76-7cdf-11eb-12c7-216e01aaa7bc
imfilter(test_image_with_border, K_test, "replicate")

# ╔═╡ 6e53c2e6-ee1e-11ea-21bd-c9c05381be07
md"_Edit_ `K_test` _to create your own test case!_"

# ╔═╡ 631c8b20-7c20-11eb-170a-8fe77707eac1
convolve(philip_head, K_test)

# ╔═╡ 1f59a322-7cdf-11eb-3699-15393276560f
imfilter(philip_head, K_test, "replicate")

# ╔═╡ 8a335044-ee19-11ea-0255-b9391246d231
md"""
---

You can create all sorts of effects by choosing the kernel in a smart way. Today, we will implement two special kernels, to produce a **Gaussian blur** and a **Sobel edge detection** filter.

Make sure that you have watched the lecture about convolutions!
"""

# ╔═╡ 79eb0775-3582-446b-996a-0b64301394d0
md"""
#### Exercise 2.3
The 2D Gaussian kernel will be defined using

$$G(x,y)=\frac{1}{2\pi \sigma^2}\exp\left(\frac{-(x^2+y^2)}{2\sigma^2}\right)$$

How can you express this mathematically using the 1D Gaussian function that we defined before?
"""

# ╔═╡ f4d9fd6f-0f1b-4dec-ae68-e61550cee790
gauss(x, y; σ=1) = 2π*σ^2 * gauss(x; σ=σ) * gauss(y; σ=σ)

# ╔═╡ 1c8b4658-ee0c-11ea-2ede-9b9ed7d3125e
function gaussian_kernel_1D(n; σ = 1)
	arr = OffsetArray(zeros(2*n+1), -n:n)
	for i in -n:n
		arr[i] = gauss(i; σ)
	end
	return arr ./ sum(arr)
end

# ╔═╡ 9f3a4de6-7bf7-11eb-0c6c-4de877472453
gaussian_kernel_1D(2, σ=0.5) ≈ KernelFactors.gaussian(0.5, 5)

# ╔═╡ d3a59ac0-7cf6-11eb-25da-81092fb88cb1
gaussian_kernel_1D(3, σ=0.1) ≈ KernelFactors.gaussian(0.1, 7)

# ╔═╡ d17c8590-7d95-11eb-0dcf-13c38f25dc48
uh_oh = gaussian_kernel_1D(3, σ=0.1)

# ╔═╡ 2a933930-7d96-11eb-062a-21a667b7ab1e
sum(uh_oh)

# ╔═╡ ee260002-7bf8-11eb-16fa-a9b3ef6199e3
gk_1D(σ) = gaussian_kernel_1D(4; σ)

# ╔═╡ 49ff6f50-7b81-11eb-2e30-1d7895bf8db0
colored_line(OffsetArrays.no_offset_view(gaussian_kernel_1D(4; σ=1.0)))

# ╔═╡ 38eb92f6-ee13-11ea-14d7-a503ac04302e
test_gauss_1D_a = let
	k = gaussian_kernel_1D(gaussian_kernel_size_1D)
	
	if k !== missing
		convolve(v, k)
	end
end

# ╔═╡ 6148dd72-7bfc-11eb-1702-09bd7a29ef2b
colored_line(test_gauss_1D_a)

# ╔═╡ 24c21c7c-ee14-11ea-1512-677980db1288
test_gauss_1D_b = let
	v = create_bar()
	k = gaussian_kernel_1D(gaussian_kernel_size_1D)
	
	if k !== missing
		convolve(v, k)
	end
end

# ╔═╡ bc1c20a4-ee14-11ea-3525-63c9fa78f089
colored_line(test_gauss_1D_b)

# ╔═╡ e31e3242-7bf0-11eb-10af-cd674ba29b28
g(σ) = (x) -> gauss(x; σ)

# ╔═╡ aabdb142-7bf9-11eb-2ed2-5d81e770b239
begin
	a = plot(g(sigma), label="σ=$sigma")
	b = plot(gk_1D(sigma), label="σ=$sigma\nn=4")
	plot(a, b, layout=2, size=(600,300))
end

# ╔═╡ 7c50ea80-ee15-11ea-328f-6b4e4ff20b7e
md"""
👉 Write a function that applies a **Gaussian blur** to an image. Use your previous functions, and add cells to write helper functions as needed!
"""

# ╔═╡ 6da0b0b6-7c69-11eb-0808-39905a1aa9ad
function gaussian_kernel(σ=3, l=5)
	return [gauss(i, j, σ=σ) for (i,j) in Iterators.product(-l:l,-l:l)]
end

# ╔═╡ aad67fd0-ee15-11ea-00d4-274ec3cda3a3
function with_gaussian_blur(image; σ=3, l=5)
	kernel = gaussian_kernel(σ, l)
	s = sum(kernel)
	kernel = kernel ./ s
	convolve(image, kernel)
end

# ╔═╡ b63a6d02-7c3b-11eb-3228-6b6a2f6c5084
with_gaussian_blur(philip_head; σ=3, l=3)

# ╔═╡ 8ae59674-ee18-11ea-3815-f50713d0fa08
md"_Let's make it interactive. 💫_"

# ╔═╡ 96146b16-79ea-401f-b8ba-e05663a18bd8
@bind face_σ Slider(0.1:0.1:10; show_value=true)

# ╔═╡ 2cc745ce-e145-4428-af3b-926fba271b67
@bind face_l Slider(0:20; show_value=true)

# ╔═╡ 23739350-7d98-11eb-1315-7f63d91cfcdb
gaussian_kernel(face_σ, face_l)

# ╔═╡ d5ffc6ab-156b-4d43-ac3d-1947d0176e7f
md"""
When you set `face_σ` to a low number (e.g. `2.0`), what effect does `face_l` have? And vice versa?
"""

# ╔═╡ 7c6642a6-ee15-11ea-0526-a1aac4286cdd
md"""
#### Exercise 2.4
👉 Create a **Sobel edge detection filter**.

Here, we will need to create two filters that separately detect edges in the horizontal and vertical directions, given by the following kernels:

```math
G_x = \begin{bmatrix}
1 & 0 & -1 \\
2 & 0 & -2 \\
1 & 0 & -1 \\
\end{bmatrix};
\qquad
G_y = \begin{bmatrix}
1 & 2 & 1 \\
0 & 0 & 0 \\
-1 & -2 & -1 \\
\end{bmatrix} 
```

We can think of these filterrs as derivatives in the $x$ and $y$ directions, as we discussed in lectures.

Then we combine them by finding the magnitude of the **gradient** (in the sense of multivariate calculus) by defining

$$G_\text{total} = \sqrt{G_x^2 + G_y^2},$$

where each operation applies *element-wise* on the matrices.

Use your previous functions, and add cells to write helper functions as needed!
"""

# ╔═╡ c4da3850-7c3c-11eb-1801-0321b8ab40e5
Gx = [1 0 -1
	2 0 -2
	1 0 -1]

# ╔═╡ f78f902e-7c3c-11eb-2c84-d786263939a7
Gy = [1 2 1
	0 0 0
	-1 -2 -1]

# ╔═╡ c4824ba4-7c3c-11eb-10a7-af78cc20e88b
Gtotal = sqrt.(Gx.*Gx + Gy.*Gy)

# ╔═╡ 9eeb876c-ee15-11ea-1794-d3ea79f47b75
function with_sobel_edge_detect(image)
	kernel = Gtotal ./ sum(Gtotal)
	convolve(image, kernel)
end

# ╔═╡ 8ffe16ce-ee20-11ea-18bd-15640f94b839
if student.kerberos_id === "jazz"
	md"""
!!! danger "Oops!"
    **Before you submit**, remember to fill in your name and kerberos ID at the top of this notebook!
	"""
end

# ╔═╡ 2d9f3ae4-9e4c-49ce-aab0-5f87aba85c3e
md"## Function library

Just some helper functions used in the notebook."

# ╔═╡ 5516c800-edee-11ea-12cf-3f8c082ef0ef
hint(text) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]))

# ╔═╡ ea435e58-ee11-11ea-3785-01af8dd72360
hint(md"Have a look at the lecture notes to see examples of adding interactivity with a slider. You can read the Interactivity and the PlutoUI sample notebooks to learn more, you can find them in Pluto's main menu. _(Right click the Pluto logo in the top left -> Open in new tab)_.")

# ╔═╡ 32a07f1d-93cd-4bf3-bac1-91afa6bb88a6
md"""
You can use the `÷` operator (you type `\div<TAB>` to get it with autocomplete) to do _integer division_. For example:

```julia
8 / 6 ≈ 1.3333333 # a floating point number!

8 // 6 == 4 // 3  # a fraction!

8 ÷ 6 == 1        # an integer!
```
""" |> hint

# ╔═╡ 649df270-ee24-11ea-397e-79c4355e38db
hint(md"`num_rows, num_columns = size(M)`")

# ╔═╡ 0cabed84-ee1e-11ea-11c1-7d8a4b4ad1af
hint(md"`num_rows, num_columns = size(K)`")

# ╔═╡ 9def5f32-ee15-11ea-1f74-f7e6690f2efa
hint(md"Can we just copy the 1D code? What is different in 2D?")

# ╔═╡ 57360a7a-edee-11ea-0c28-91463ece500d
almost(text) = Markdown.MD(Markdown.Admonition("warning", "Almost there!", [text]))

# ╔═╡ dcb8324c-edee-11ea-17ff-375ff5078f43
still_missing(text=md"Replace `missing` with your answer.") = Markdown.MD(Markdown.Admonition("warning", "Here we go!", [text]))

# ╔═╡ 58af703c-edee-11ea-2963-f52e78fc2412
keep_working(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]))

# ╔═╡ f3d00a9a-edf3-11ea-07b3-1db5c6d0b3cf
yays = [md"Great!", md"Yay ❤", md"Great! 🎉", md"Well done!", md"Keep it up!", md"Good job!", md"Awesome!", md"You got the right answer!", md"Let's move on to the next exercise."]

# ╔═╡ 5aa9dfb2-edee-11ea-3754-c368fb40637c
correct(text=rand(yays)) = Markdown.MD(Markdown.Admonition("correct", "Got it!", [text]))

# ╔═╡ f0c3e99d-9eb9-459e-917a-c2338af6683c
let
	result = gaussian_kernel_1D(5)
	
	if ismissing(result)
		still_missing()
	elseif isnothing(result)
		keep_working(md"Did you forget to write `return`?")
	elseif !(result isa AbstractVector)
		keep_working(md"The returned object is not a `Vector`.")
	elseif size(result) != (11,)
		hint(md"The returned vector has the wrong dimensions.")
	elseif !(sum(result) ≈ 1.0)
		keep_working(md"You need to _normalize_ the result.")
	elseif gaussian_kernel_1D(3; σ=1) == gaussian_kernel_1D(3; σ=2)
		keep_working(md"Use the keyword argument `σ` in your function.")
	else
		correct()
	end
end

# ╔═╡ 74d44e22-edee-11ea-09a0-69aa0aba3281
not_defined(variable_name) = Markdown.MD(Markdown.Admonition("danger", "Oopsie!", [md"Make sure that you define a variable called **$(Markdown.Code(string(variable_name)))**"]))

# ╔═╡ bcf98dfc-ee1b-11ea-21d0-c14439500971
if !@isdefined(extend)
	not_defined(:extend)
else
	let
		result = extend([6,7],-10)

		if ismissing(result)
			still_missing()
		elseif isnothing(result)
			keep_working(md"Did you forget to write `return`?")
		elseif result != 6 || extend([6,7],10) != 7
			keep_working()
		else
			correct()
		end
	end
end

# ╔═╡ 7ffd14f8-ee1d-11ea-0343-b54fb0333aea
if !@isdefined(convolve)
	not_defined(:convolve)
else
	let
		x = [1, 10, 100]
		result = convolve(x, [0, 1, 1])
		shouldbe = [11, 110, 200]
		shouldbe2 = [2, 11, 110]

		if ismissing(result)
			still_missing()
		elseif isnothing(result)
			keep_working(md"Did you forget to write `return`?")
		elseif !(result isa AbstractVector)
			keep_working(md"The returned object is not a `Vector`.")
		elseif size(result) != size(x)
			keep_working(md"The returned vector has the wrong dimensions.")
		elseif result != shouldbe && result != shouldbe2
			keep_working()
		else
			correct()
		end
	end
end

# ╔═╡ d93fa3f6-c361-4dfd-a2ea-f38e682bcd6a
if !@isdefined(box_blur_kernel)
	not_defined(:box_blur_kernel)
else
	let
		result = box_blur_kernel(2)
		
		if ismissing(result)
			still_missing()
		elseif isnothing(result)
			keep_working(md"Did you forget to write `return`?")
		elseif !(result isa AbstractVector)
			keep_working(md"The returned object is not a `Vector`.")
		elseif size(result) != (5,)
			hint(md"The returned vector has the wrong dimensions.")
		else
			
			x = [1, 10, 100]
			result1 = box_blur(x, 2)
			result2 = convolve(x, result)
			
			if result1 ≈ result2
				correct()
			else
				keep_working()
			end
		end
	end
end

# ╔═╡ efd1ceb4-ee1c-11ea-350e-f7e3ea059024
if !@isdefined(extend)
	not_defined(:extend)
else
	let
		input = [42 37; 1 0]
		result = extend(input, -2, -2)

		if ismissing(result)
			still_missing()
		elseif isnothing(result)
			keep_working(md"Did you forget to write `return`?")
		elseif result != 42 || extend(input, -1, 3) != 37
			keep_working()
		else
			correct()
		end
	end
end

# ╔═╡ 115ded8c-ee0a-11ea-3493-89487315feb7
bigbreak = html"<br><br><br><br><br>";

# ╔═╡ 54056a02-ee0a-11ea-101f-47feb6623bec
bigbreak

# ╔═╡ a3067222-a83a-47b8-91c3-24ad78dd65c5
bigbreak

# ╔═╡ 27847dc4-ee0a-11ea-0651-ebbbb3cfd58c
bigbreak

# ╔═╡ 0001f782-ee0e-11ea-1fb4-2b5ef3d241e2
bigbreak

# ╔═╡ 5842895a-ee10-11ea-119d-81e4c4c8c53b
bigbreak

# ╔═╡ dfb7c6be-ee0d-11ea-194e-9758857f7b20
function camera_input(;max_size=200, default_url="https://i.imgur.com/SUmi94P.png")
"""
<span class="pl-image waiting-for-permission">
<style>
	
	.pl-image.popped-out {
		position: fixed;
		top: 0;
		right: 0;
		z-index: 5;
	}

	.pl-image #video-container {
		width: 250px;
	}

	.pl-image video {
		border-radius: 1rem 1rem 0 0;
	}
	.pl-image.waiting-for-permission #video-container {
		display: none;
	}
	.pl-image #prompt {
		display: none;
	}
	.pl-image.waiting-for-permission #prompt {
		width: 250px;
		height: 200px;
		display: grid;
		place-items: center;
		font-family: monospace;
		font-weight: bold;
		text-decoration: underline;
		cursor: pointer;
		border: 5px dashed rgba(0,0,0,.5);
	}

	.pl-image video {
		display: block;
	}
	.pl-image .bar {
		width: inherit;
		display: flex;
		z-index: 6;
	}
	.pl-image .bar#top {
		position: absolute;
		flex-direction: column;
	}
	
	.pl-image .bar#bottom {
		background: black;
		border-radius: 0 0 1rem 1rem;
	}
	.pl-image .bar button {
		flex: 0 0 auto;
		background: rgba(255,255,255,.8);
		border: none;
		width: 2rem;
		height: 2rem;
		border-radius: 100%;
		cursor: pointer;
		z-index: 7;
	}
	.pl-image .bar button#shutter {
		width: 3rem;
		height: 3rem;
		margin: -1.5rem auto .2rem auto;
	}

	.pl-image video.takepicture {
		animation: pictureflash 200ms linear;
	}

	@keyframes pictureflash {
		0% {
			filter: grayscale(1.0) contrast(2.0);
		}

		100% {
			filter: grayscale(0.0) contrast(1.0);
		}
	}
</style>

	<div id="video-container">
		<div id="top" class="bar">
			<button id="stop" title="Stop video">✖</button>
			<button id="pop-out" title="Pop out/pop in">⏏</button>
		</div>
		<video playsinline autoplay></video>
		<div id="bottom" class="bar">
		<button id="shutter" title="Click to take a picture">📷</button>
		</div>
	</div>
		
	<div id="prompt">
		<span>
		Enable webcam
		</span>
	</div>

<script>
	// based on https://github.com/fonsp/printi-static (by the same author)

	const span = currentScript.parentElement
	const video = span.querySelector("video")
	const popout = span.querySelector("button#pop-out")
	const stop = span.querySelector("button#stop")
	const shutter = span.querySelector("button#shutter")
	const prompt = span.querySelector(".pl-image #prompt")

	const maxsize = $(max_size)

	const send_source = (source, src_width, src_height) => {
		const scale = Math.min(1.0, maxsize / src_width, maxsize / src_height)

		const width = Math.floor(src_width * scale)
		const height = Math.floor(src_height * scale)

		const canvas = html`<canvas width=\${width} height=\${height}>`
		const ctx = canvas.getContext("2d")
		ctx.drawImage(source, 0, 0, width, height)

		span.value = {
			width: width,
			height: height,
			data: ctx.getImageData(0, 0, width, height).data,
		}
		span.dispatchEvent(new CustomEvent("input"))
	}
	
	const clear_camera = () => {
		window.stream.getTracks().forEach(s => s.stop());
		video.srcObject = null;

		span.classList.add("waiting-for-permission");
	}

	prompt.onclick = () => {
		navigator.mediaDevices.getUserMedia({
			audio: false,
			video: {
				facingMode: "environment",
			},
		}).then(function(stream) {

			stream.onend = console.log

			window.stream = stream
			video.srcObject = stream
			window.cameraConnected = true
			video.controls = false
			video.play()
			video.controls = false

			span.classList.remove("waiting-for-permission");

		}).catch(function(error) {
			console.log(error)
		});
	}
	stop.onclick = () => {
		clear_camera()
	}
	popout.onclick = () => {
		span.classList.toggle("popped-out")
	}

	shutter.onclick = () => {
		const cl = video.classList
		cl.remove("takepicture")
		void video.offsetHeight
		cl.add("takepicture")
		video.play()
		video.controls = false
		console.log(video)
		send_source(video, video.videoWidth, video.videoHeight)
	}
	
	
	document.addEventListener("visibilitychange", () => {
		if (document.visibilityState != "visible") {
			clear_camera()
		}
	})


	// Set a default image

	const img = html`<img crossOrigin="anonymous">`

	img.onload = () => {
	console.log("helloo")
		send_source(img, img.width, img.height)
	}
	img.src = "$(default_url)"
	console.log(img)
</script>
</span>
""" |> HTML
end

# ╔═╡ 94c0798e-ee18-11ea-3212-1533753eabb6
@bind gauss_raw_camera_data camera_input(;max_size=100)

# ╔═╡ 1a0324de-ee19-11ea-1d4d-db37f4136ad3
@bind sobel_raw_camera_data camera_input(;max_size=200)

# ╔═╡ e15ad330-ee0d-11ea-25b6-1b1b3f3d7888

function process_raw_camera_data(raw_camera_data)
	# the raw image data is a long byte array, we need to transform it into something
	# more "Julian" - something with more _structure_.
	
	# The encoding of the raw byte stream is:
	# every 4 bytes is a single pixel
	# every pixel has 4 values: Red, Green, Blue, Alpha
	# (we ignore alpha for this notebook)
	
	# So to get the red values for each pixel, we take every 4th value, starting at 
	# the 1st:
	reds_flat = UInt8.(raw_camera_data["data"][1:4:end])
	greens_flat = UInt8.(raw_camera_data["data"][2:4:end])
	blues_flat = UInt8.(raw_camera_data["data"][3:4:end])
	
	# but these are still 1-dimensional arrays, nicknamed 'flat' arrays
	# We will 'reshape' this into 2D arrays:
	
	width = raw_camera_data["width"]
	height = raw_camera_data["height"]
	
	# shuffle and flip to get it in the right shape
	reds = reshape(reds_flat, (width, height))' / 255.0
	greens = reshape(greens_flat, (width, height))' / 255.0
	blues = reshape(blues_flat, (width, height))' / 255.0
	
	# we have our 2D array for each color
	# Let's create a single 2D array, where each value contains the R, G and B value of 
	# that pixel
	
	RGB.(reds, greens, blues)
end

# ╔═╡ f461f5f2-ee18-11ea-3d03-95f57f9bf09e
gauss_camera_image = process_raw_camera_data(gauss_raw_camera_data);

# ╔═╡ a75701c4-ee18-11ea-2863-d3042e71a68b
with_gaussian_blur(gauss_camera_image; σ=face_σ, l=face_l)

# ╔═╡ 1ff6b5cc-ee19-11ea-2ca8-7f00c204f587
sobel_camera_image = Gray.(process_raw_camera_data(sobel_raw_camera_data));

# ╔═╡ 1bf94c00-ee19-11ea-0e3c-e12bc68d8e28
Gray.(with_sobel_edge_detect(sobel_camera_image))

# ╔═╡ Cell order:
# ╟─83eb9ca0-ed68-11ea-0bc5-99a09c68f867
# ╟─8ef13896-ed68-11ea-160b-3550eeabbd7d
# ╟─ac8ff080-ed61-11ea-3650-d9df06123e1f
# ╠═911ccbce-ed68-11ea-3606-0384e7580d7c
# ╟─5f95e01a-ee0a-11ea-030c-9dba276aba92
# ╠═65780f00-ed6b-11ea-1ecf-8b35523a7ac0
# ╟─f7a6d7c3-37b9-437d-8b8e-853665ddbae3
# ╟─54056a02-ee0a-11ea-101f-47feb6623bec
# ╟─e08781fa-ed61-11ea-13ae-91a49b5eb74a
# ╟─a3067222-a83a-47b8-91c3-24ad78dd65c5
# ╟─80108d80-ee09-11ea-0368-31546eb0d3cc
# ╠═7fcd6230-ee09-11ea-314f-a542d00d582e
# ╠═343273a4-79de-11eb-0e8d-a7bad6ec09eb
# ╟─7fe9153e-ee09-11ea-15b3-6f24fcc20734
# ╠═e06f7f0a-7cf3-11eb-3490-a789d466d347
# ╟─ff70782e-e8d2-4281-9b24-d45c925f55e2
# ╟─7522f81e-ee1c-11ea-35af-a17eb257ff1a
# ╟─801d90c0-ee09-11ea-28d6-61b806de26dc
# ╠═cc441320-7a95-11eb-0c8f-1bf0e39bef44
# ╠═e45e0d0c-7bea-11eb-26e3-bbad708f0cbf
# ╟─b7f3994c-ee1b-11ea-211a-d144db8eafc2
# ╠═803905b2-ee09-11ea-2d52-e77ff79693b0
# ╠═80479d98-ee09-11ea-169e-d166eef65874
# ╠═805691ce-ee09-11ea-053d-6d2e299ee123
# ╟─bcf98dfc-ee1b-11ea-21d0-c14439500971
# ╠═3492b164-7065-48e8-978b-6c96b965d376
# ╠═880f773c-7b3d-11eb-2ab7-0709c2ffe4af
# ╟─806e5766-ee0f-11ea-1efc-d753cd83d086
# ╠═38da843a-ee0f-11ea-01df-bfa8b1317d36
# ╟─9bde9f92-ee0f-11ea-27f8-ffef5fce2b3c
# ╟─45c4da9a-ee0f-11ea-2c5b-1f6704559137
# ╟─431ba330-0f72-416a-92e9-55f51ff3bcd1
# ╠═5fdc5d0d-a52c-476e-b3b5-3b6364b706e4
# ╟─e84c9cc2-e6e1-46f1-bf4e-9605da5e6f4a
# ╠═39342550-79db-11eb-0fd1-9f5954292b7b
# ╠═5ea5af78-79db-11eb-17d0-8f7347c0bac6
# ╠═807e5662-ee09-11ea-3005-21fdcc36b023
# ╠═d2c36ca6-7beb-11eb-0140-2f1bc7e33819
# ╠═4f08ebe8-b781-4a32-a218-5ecd8338561d
# ╠═8c2a70d8-79da-11eb-055a-331e9d191e2a
# ╟─808deca8-ee09-11ea-0ee3-1586fa1ce282
# ╟─809f5330-ee09-11ea-0e5b-415044b6ac1f
# ╠═e555a7e6-f11a-43ac-8218-6d832f0ce251
# ╠═7d80a1ea-a0a9-41b2-9cfe-a334717ab2f4
# ╟─ea435e58-ee11-11ea-3785-01af8dd72360
# ╟─80ab64f4-ee09-11ea-29b4-498112ed0799
# ╠═1873053e-7a92-11eb-122e-f938355c458e
# ╟─32a07f1d-93cd-4bf3-bac1-91afa6bb88a6
# ╟─5eea882c-ee13-11ea-0d56-af81ecd30a4a
# ╠═93284f92-ee12-11ea-0342-833b1a30625c
# ╠═71ad21dc-7bed-11eb-2b71-5f060d0b25c7
# ╟─cf73f9f8-ee12-11ea-39ae-0107e9107ef5
# ╟─7ffd14f8-ee1d-11ea-0343-b54fb0333aea
# ╟─fa463b71-5aa4-44a3-a67b-6b0776236243
# ╠═8a7d3cfd-6f19-43f0-ae16-d5a236f148e7
# ╠═a34d1ad8-3776-4bc4-93e5-72cfffc54f15
# ╠═971a801d-9c46-417a-ad31-1144894fb4e1
# ╟─5f13b1a5-8c7d-47c9-b96a-a09faf38fe5e
# ╠═338b1c3f-f071-4f80-86c0-a82c17349828
# ╠═bbe1a562-8d97-4112-a88a-c45c260f574d
# ╟─d93fa3f6-c361-4dfd-a2ea-f38e682bcd6a
# ╟─03f91a22-1c3e-4c42-9d78-1ee36851a120
# ╟─48530f0d-49b4-4aec-8109-d69f1ef7f0ee
# ╠═beb62fda-38a6-4528-a176-cfb726f4b5bd
# ╟─f0d55cec-2e81-4cbb-b166-2cf4f2a0f43f
# ╠═1c8b4658-ee0c-11ea-2ede-9b9ed7d3125e
# ╠═9f3a4de6-7bf7-11eb-0c6c-4de877472453
# ╠═d3a59ac0-7cf6-11eb-25da-81092fb88cb1
# ╠═d17c8590-7d95-11eb-0dcf-13c38f25dc48
# ╠═2a933930-7d96-11eb-062a-21a667b7ab1e
# ╟─f0c3e99d-9eb9-459e-917a-c2338af6683c
# ╠═27fcb544-7bf1-11eb-0565-f9aa208239a1
# ╠═e31e3242-7bf0-11eb-10af-cd674ba29b28
# ╠═ee260002-7bf8-11eb-16fa-a9b3ef6199e3
# ╠═aabdb142-7bf9-11eb-2ed2-5d81e770b239
# ╠═49ff6f50-7b81-11eb-2e30-1d7895bf8db0
# ╟─f8bd22b8-ee14-11ea-04aa-ab16fd01826e
# ╠═2a9dd06a-ee13-11ea-3f84-67bb309c77a8
# ╠═6148dd72-7bfc-11eb-1702-09bd7a29ef2b
# ╠═38eb92f6-ee13-11ea-14d7-a503ac04302e
# ╠═bc1c20a4-ee14-11ea-3525-63c9fa78f089
# ╠═24c21c7c-ee14-11ea-1512-677980db1288
# ╟─ce24e486-df27-4780-bc57-d3bf7bee83bb
# ╟─27847dc4-ee0a-11ea-0651-ebbbb3cfd58c
# ╟─b01858b6-edf3-11ea-0826-938d33c19a43
# ╟─7c1bc062-ee15-11ea-30b1-1b1e76520f13
# ╠═7c2ec6c6-ee15-11ea-2d7d-0d9401a5e5d1
# ╠═46674714-7c06-11eb-39dc-7b37794dba3e
# ╟─649df270-ee24-11ea-397e-79c4355e38db
# ╟─9afc4dca-ee16-11ea-354f-1d827aaa61d2
# ╠═cf6b05e2-ee16-11ea-3317-8919565cb56e
# ╟─e3616062-ee27-11ea-04a9-b9ec60842a64
# ╟─e5b6cd34-ee27-11ea-0d60-bd4796540b18
# ╟─b4e98589-f221-4922-b11e-364d72d0788e
# ╟─d06ea762-ee27-11ea-2e9c-1bcff86a3fe0
# ╠═e1dc0622-ee16-11ea-274a-3b6ec9e15ab5
# ╠═c23b5b20-7c1d-11eb-12b9-d3ef832f4fdb
# ╟─efd1ceb4-ee1c-11ea-350e-f7e3ea059024
# ╟─4bbea325-35f8-4a51-bd66-153aba4aed96
# ╠═c4f5a867-74ba-4106-91d4-195f6ae644d0
# ╠═c825ebe2-511b-43ba-afdf-6226dbac48d2
# ╠═2701ab0c-b91d-47fe-b36b-4e0036ecd4aa
# ╠═84a48984-9adb-40ab-a1f1-1ab7b76c9a19
# ╠═3cd535e4-ee26-11ea-2482-fb4ad43dda19
# ╟─7c41f0ca-ee15-11ea-05fb-d97a836659af
# ╠═d0dfa1e6-7cf8-11eb-1b86-f19b984eb9f1
# ╠═6f2b8492-7d02-11eb-08ab-3f28916a75d0
# ╟─0cabed84-ee1e-11ea-11c1-7d8a4b4ad1af
# ╟─5a5135c6-ee1e-11ea-05dc-eb0c683c2ce5
# ╟─577c6daa-ee1e-11ea-1275-b7abc7a27d73
# ╟─275a99c8-ee1e-11ea-0a76-93e3618c9588
# ╠═42dfa206-ee1e-11ea-1fcd-21671042064c
# ╠═37d85d76-7cdf-11eb-12c7-216e01aaa7bc
# ╟─6e53c2e6-ee1e-11ea-21bd-c9c05381be07
# ╠═631c8b20-7c20-11eb-170a-8fe77707eac1
# ╠═1f59a322-7cdf-11eb-3699-15393276560f
# ╟─8a335044-ee19-11ea-0255-b9391246d231
# ╟─79eb0775-3582-446b-996a-0b64301394d0
# ╠═f4d9fd6f-0f1b-4dec-ae68-e61550cee790
# ╟─7c50ea80-ee15-11ea-328f-6b4e4ff20b7e
# ╠═6da0b0b6-7c69-11eb-0808-39905a1aa9ad
# ╠═aad67fd0-ee15-11ea-00d4-274ec3cda3a3
# ╠═b63a6d02-7c3b-11eb-3228-6b6a2f6c5084
# ╟─9def5f32-ee15-11ea-1f74-f7e6690f2efa
# ╟─8ae59674-ee18-11ea-3815-f50713d0fa08
# ╠═94c0798e-ee18-11ea-3212-1533753eabb6
# ╠═a75701c4-ee18-11ea-2863-d3042e71a68b
# ╠═23739350-7d98-11eb-1315-7f63d91cfcdb
# ╠═96146b16-79ea-401f-b8ba-e05663a18bd8
# ╠═2cc745ce-e145-4428-af3b-926fba271b67
# ╟─d5ffc6ab-156b-4d43-ac3d-1947d0176e7f
# ╠═f461f5f2-ee18-11ea-3d03-95f57f9bf09e
# ╟─7c6642a6-ee15-11ea-0526-a1aac4286cdd
# ╠═c4da3850-7c3c-11eb-1801-0321b8ab40e5
# ╠═f78f902e-7c3c-11eb-2c84-d786263939a7
# ╠═c4824ba4-7c3c-11eb-10a7-af78cc20e88b
# ╠═9eeb876c-ee15-11ea-1794-d3ea79f47b75
# ╠═1a0324de-ee19-11ea-1d4d-db37f4136ad3
# ╠═1bf94c00-ee19-11ea-0e3c-e12bc68d8e28
# ╟─1ff6b5cc-ee19-11ea-2ca8-7f00c204f587
# ╟─0001f782-ee0e-11ea-1fb4-2b5ef3d241e2
# ╟─8ffe16ce-ee20-11ea-18bd-15640f94b839
# ╟─5842895a-ee10-11ea-119d-81e4c4c8c53b
# ╟─2d9f3ae4-9e4c-49ce-aab0-5f87aba85c3e
# ╟─5516c800-edee-11ea-12cf-3f8c082ef0ef
# ╟─57360a7a-edee-11ea-0c28-91463ece500d
# ╟─dcb8324c-edee-11ea-17ff-375ff5078f43
# ╟─58af703c-edee-11ea-2963-f52e78fc2412
# ╟─f3d00a9a-edf3-11ea-07b3-1db5c6d0b3cf
# ╟─5aa9dfb2-edee-11ea-3754-c368fb40637c
# ╟─74d44e22-edee-11ea-09a0-69aa0aba3281
# ╟─115ded8c-ee0a-11ea-3493-89487315feb7
# ╟─dfb7c6be-ee0d-11ea-194e-9758857f7b20
# ╟─e15ad330-ee0d-11ea-25b6-1b1b3f3d7888
