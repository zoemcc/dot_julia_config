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

# utility
ls(x) = readdir(x)
ls() = readdir()
ty(x) = typeof(x)
fn(x) = fieldnames(x)
fnty = fn ∘ ty

function kill_julia_workers() 
    julia_worker_procs = filter(x->occursin("--bind-to", x) && occursin("--worker", x), split(read(`pgrep -af julia`, String), "\n"))
    just_worker_pids = map(x->split(x, " ")[1], julia_worker_procs)
    worker_kill_command = `kill $just_worker_pids`
    (julia_worker_procs, worker_kill_command)
end
