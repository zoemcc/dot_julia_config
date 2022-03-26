using Pkg
using TOML

default_dev_pkgs = ["Cthulhu", "Plots"]

STARTUP_DIR = pwd()
DEVENV_DIR = joinpath(STARTUP_DIR, "jl_devenv")
main_project_toml = joinpath(STARTUP_DIR, "Project.toml")
# developer env
if isfile(main_project_toml) 
    if !isdir(DEVENV_DIR)
        mkdir(DEVENV_DIR)
    end

    dev_project_toml = joinpath(DEVENV_DIR, "Project.toml")
    if !isfile(dev_project_toml)
        added_project_toml = true
        project_toml = TOML.parse(read(main_project_toml, String))
        # needed to make Pkg think this devenv isn't a Package
        delete!(project_toml, "name")
        delete!(project_toml, "uuid")
        delete!(project_toml, "authors")
        delete!(project_toml, "version")

        open(dev_project_toml, "w")  do f
            TOML.print(f, project_toml)
        end
    else
        added_project_toml = false
    end

    main_manifest_toml = joinpath(STARTUP_DIR, "Manifest.toml")
    dev_manifest_toml = joinpath(DEVENV_DIR, "Manifest.toml")
    if isfile(main_manifest_toml) && !isfile(dev_manifest_toml)
        cp(main_manifest_toml, dev_manifest_toml)
    end

    Pkg.activate(DEVENV_DIR)
    if added_project_toml
        Pkg.develop(path=STARTUP_DIR)
    end
    if !isfile(dev_manifest_toml)
        Pkg.instantiate()
    end

    dev_project_toml_dict_deps = get(TOML.parse(read(dev_project_toml, String)), "deps", Dict())
    for dev_pkg in default_dev_pkgs
        if !haskey(dev_project_toml_dict_deps, dev_pkg)
            Pkg.add(dev_pkg)
        end
    end
    
end

function regular_pkg_add(args...)
    Pkg.add(args...)
    Pkg.activate(STARTUP_DIR)
    Pkg.add(args...)
    Pkg.activate(DEVENV_DIR)
end

try
    using Revise
catch e
    @warn "Error initializing Revise" exception=(e, catch_backtrace())
end

