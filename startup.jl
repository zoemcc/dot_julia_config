using Pkg

# Environment Stack knowledge from https://docs.julialang.org/en/v1/manual/code-loading/#Environment-stacks
DEVENV_LOC = joinpath(homedir(), ".julia", "config", "devenv")
if !(DEVENV_LOC in LOAD_PATH)
    @info "Adding $DEVENV_LOC to LOAD_PATH"
    push!(LOAD_PATH, DEVENV_LOC)
end

Pkg.activate(".")

try
    using Revise
catch e
    @warn "Error initializing Revise" exception=(e, catch_backtrace())
end

