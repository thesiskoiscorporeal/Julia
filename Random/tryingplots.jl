using Plots
plotly()

# f(x, y) = x^2 + y^2
# contour(-3:0.1:3, -3:0.1:3, f, levels=[1])


#hey! i figured out how to plot parametric surfaces :)
# f(x,y) = (20 - π^3 + x^3 + sin(x))/y
y = x = range(-5, stop=5, length=100)

# surface(x, y, (x,y) -> f(x,y))
# scatter!((pi, 4, 5))

# not sure how to get this tangent plane to show.
# surface!(x, y, (x,y) -> (10 + π/4 - (3*π^3)/4 - 1/4*(1 - 3*π^2)*x - (5*y)/4))


surface(x,y, (x,y) -> x^2 - y^2)
