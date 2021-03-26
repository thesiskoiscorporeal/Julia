### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ c4e43e12-8bc6-11eb-2eab-f1b8b841901c
using SymPy

# ╔═╡ 20fcc000-8bc7-11eb-0edc-bd261d903063
using LinearAlgebra

# ╔═╡ d3d96f80-8bc6-11eb-0b52-1be293ca2819
x, y = symbols("x, y", real=true)

# ╔═╡ dfaec350-8bc6-11eb-3422-4fcbd152e0c1
f(x,y) = exp(x+y) + exp(-x-y)

# ╔═╡ e0037300-8bc6-11eb-3b55-6d2df8d4a2fd
f(x,y)

# ╔═╡ 1f476ee0-8bc7-11eb-2737-9b92d76aac76
Laplace

# ╔═╡ Cell order:
# ╠═c4e43e12-8bc6-11eb-2eab-f1b8b841901c
# ╠═20fcc000-8bc7-11eb-0edc-bd261d903063
# ╠═d3d96f80-8bc6-11eb-0b52-1be293ca2819
# ╠═dfaec350-8bc6-11eb-3422-4fcbd152e0c1
# ╠═e0037300-8bc6-11eb-3b55-6d2df8d4a2fd
# ╠═1f476ee0-8bc7-11eb-2737-9b92d76aac76
