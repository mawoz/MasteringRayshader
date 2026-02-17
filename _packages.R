### Mastering Rayshader: Crafting Stunning 3D Maps in R
### A comprehensive guide to 3d visualization by Milos Popovic


## _packages & _directories & _volcano
## config file for setting up the environment



# 1: Why this matters

# Project Isolation:
# Keeping each project's R packages separate and version-locked ({renv})

# Path Independence:
# Ensuring our code runs on any machine, regardless of its folder structure ({here})

# Process Automation:
# Using tools to automatically test and render our work (GitHub Actions)
# Add this minimal configuration:
# FROM rocker/r-ver:4.4.1\nCOPY .. \nRUN R -e "renv::restore()"\nCMD ["quarto", "render"]


# Code Quality:
# Enforcing consistent style and catching errors before they are committed (pre-commit)

# Complete Environment Parity (optional):
# For ultimate reproducibility, packaging the entire OS and software stack (Docker)



# 2: The Project Launchpad with RStudio and {renv}


# Use pak for package management
if (!requireNamespace("pak", quietly = TRUE)) {
        install.packages("pak")
}

core_pkgs <- c("rayshader",
               "terra",
               "sf",
               "tidyverse",
               "elevatr",
               "geodata",
               "here",
               "renv",
               "precommit"
)


add_pkgs <- c("cpp11",
              "RcppArmadillo",
              "RcppThread",
              "spacefillr",
              "testthat"
)


pak::pkg_install(core_pkgs)

# Was needed once for {renv} snapshot;
# Other "additional" packages may be required depending on project and scope
# pak::pkg_install(add_pkgs)
# invisible(lapply(c(core_pkgs, add_pkgs), library, character.only = TRUE))

invisible(lapply(core_pkgs, library, character.only = TRUE))


# Initialize {renv} once per new project
if(!file.exists(here::here("renv.lock"))) {
        renv::init()
}



# 3: A tidy home for your project


# Creates standard project folders relative to the project directory with {here}
dir.create(
        here::here("data", "raw"),
        recursive = TRUE,
        showWarnings = FALSE
)

dir.create(
        here::here("data", "retrieved"),
        recursive = TRUE,
        showWarnings = FALSE
)

dir.create(
        here::here("data", "raw", "hdri"),
        recursive = TRUE,
        showWarnings = FALSE
)

dir.create(
        here::here("data", "raw", "climate"),
        recursive = TRUE,
        showWarnings = FALSE
)

dir.create(
        here::here("data", "raw", "hydrosheds"),
        recursive = TRUE,
        showWarnings = FALSE
)

dir.create(
        here::here("R"),
        recursive = TRUE,
        showWarnings = FALSE
)

dir.create(
        here::here("outputs"),
        recursive = TRUE,
        showWarnings = FALSE
)

dir.create(
        here::here("outputs", "images"),
        recursive = TRUE,
        showWarnings = FALSE
)



# 4: Deterministic Seeds for Perfect Replicas


# Set a random seed for reproducibility
set.seed(42)

# Quick test with built-in volcano dataset
volcano_matrix <- volcano
test_shade <- rayshader::sphere_shade(volcano_matrix)

# Fast preview vs final output option
# Use "final" for publication export
render_mode <- "final"


if (render_mode == "preview") {
        out_file <- here::here(
                "outputs", "images", "plot0_1.png"
        )
        out_width <- 1200
        out_height <- 1200
        out_res <- 150
} else {
        out_file <- here::here(
                "outputs", "images", "plot0_2.png"
        )
        out_width <- 2400
        out_height <- 2400
        out_res <- 300
}

png(
        filename = out_file,
        width = out_width,
        height = out_height,
        res = out_res)

plot(as.raster(test_shade), axes = FALSE)

dev.off()



# 5: Advanced Reproducibility


# Pre-commit Hooks: These are automated checks that run on your code before you
# commit it. Using the {precommit} R package, you can set up hooks to automatically
# re-style your code, check for common errors, and even run a spell check on your
# documentation. 

# Pipeline Managers: For projects with multiple data processing steps, a pipeline
# manager like {targets} is invaluable. It understands the dependencies between
# your code and data, and will only re-run steps that have changed, saving immense
# amounts of time during development.

# Containerization with Docker: For the ultimate guarantee of reproducibility,
# you can use Docker. A Dockerfile is a recipe that specifies the OS, system
# libraries, R version, and all code needed to run your project. This creates a
# self-contained "image" that will run identically on any machine, today or ten
# years from now.
