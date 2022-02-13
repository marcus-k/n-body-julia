using ProgressBars
using Printf
using Plots

using nbody

# Create NBody object
len = 5
nb = NBody(
    u0 = [rand(len, 3) .* 2 .- 1 zeros(len, 3)],
    t0 = 0.0,
    tf = 50.0,
    G = 1.0,
    m = ones(Float64, len),
    softening = 0.05
)

# Solve for future evolution
println("Start solving")
sol = solve_nb(nb)
println("Solving done")

# Create an animation
lim = 5
anim = @animate for t in tqdm(nb.t0:0.1:nb.tf)
    frame = sol(t)
    scatter(
        frame[:, 1], frame[:, 2],
		xlim = (-lim, lim),
		ylim = (-lim, lim),
		aspect_ratio = :equal,
        label = @sprintf("t = %.2f", t),
        markersize = 3
    )
end
gif(anim, "output.gif", fps=30)
