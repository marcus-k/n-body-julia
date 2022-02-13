module nbody

using DifferentialEquations

export NBody, solve_nb

struct NBody
    u0::Matrix
    t0::Float64
    tf::Float64
    G::Float64
    m::Vector
    softening::Float64

    function NBody(
        u0::Matrix{Float64}, 
        t0::Float64, 
        tf::Float64, 
        G::Float64, 
        m::Vector{Float64},
        softening::Float64
    )
        if size(u0)[2] != 6
            throw(DomainError("u0 should have 6 columns."))
        end
        if softening < 0
            throw(DomainError("softening value should be greater than 0."))
        end
        if size(u0)[1] != length(m)
            throw(DimensionMismatch(
                "The number of rows in u0 should match the length of m"
            ))
        end
        return new(u0, t0, tf, G, m, softening)
    end

    function NBody(;
        u0::Matrix{Float64}, 
        t0::Float64, 
        tf::Float64, 
        G::Float64, 
        m::Vector{Float64},
        softening::Float64
    )
        NBody(u0, t0, tf, G, m, softening)
    end
end

function derivs!(du, u, p, t)
    # Unpack variables
    x, y, z, vx, vy, vz = eachcol(u)
    G, m, softening = p

    # Set position derivative
    du[:, 1:3] = [vx vy vz]

    # Matrix to store pairwise separation
    dx = x' .- x
    dy = y' .- y
    dz = z' .- z

    # Find 1/r^3 pairwise
    inv_r3 = dx.^2 + dy.^2 + dz.^2 .+ softening.^2
    inv_r3[inv_r3 .> 0] .^= -1.5

    # Find acceleration
    ax = (G .* (dx .* inv_r3)) * m
	ay = (G .* (dy .* inv_r3)) * m
	az = (G .* (dz .* inv_r3)) * m

    # Set velocity derivative
    du[:, 4:6] = [ax ay az]
end

function solve_nb(nb::NBody)
    prob = ODEProblem(
        derivs!, nb.u0, (nb.t0, nb.tf), (nb.G, nb.m, nb.softening)
    )
    solve(prob, reltol=1e-6)
end

end # module
