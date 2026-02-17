## Mastering Rayschader by Milos Popovic
## Mount Fuji



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
               "scico",
               "colorspace",
               "rgl",
               "magick",
               "precommit"
)

pak::pkg_install(core_pkgs)
invisible(lapply(core_pkgs, library, character.only = TRUE))



# Creates standard project folders relative to the project directory with {here}
dir.create(
        here::here("data", "derived"),
        recursive = TRUE,
        showWarnings = FALSE
)

dir.create(
        here::here("outputs", "images"),
        recursive = TRUE,
        showWarnings = FALSE
)



# Set a random seed for reproducibility
set.seed(42)



# Get and transform Mount Fuji data
# 1. Define our location of interest in WGS84 (lat/lon)
fuji_aoi_ll <- sf::st_point(c(138.7307, 35.3628)) |>
        sf::st_sfc(crs = "EPSG:4326")


# 2. Calculate the appropriate UTM zone and EPSG code
lon0 <- sf::st_coordinates(sf::st_centroid(fuji_aoi_ll))[1]
utm_zone <- floor((lon0 + 180) / 6) + 1 
utm_crs <- paste0("EPSG:", 32600+ utm_zone) 


# 3. Download the DEM in WGS84,
# then reproject to our UTM zone
dem_ll <- elevatr::get_elev_raster(
        locations = fuji_aoi_ll,
        z = 10 # Zoom level
)

dem_utm <- terra::project(
        terra::rast(dem_ll), utm_crs
)

# Sanity check
if (interactive()) {
        cat(
                "Projected CRS units:",
                terra::linearUnits(dem_utm), "\n"
        )
        print(dim(dem_utm))
}

# Cache the processed DEM to avoid
# re-downloading/projecting
terra::writeRaster(
        dem_utm,
        here::here(
                "data", "derived",
                "fuji_dem_utm.tif"
        ),
        overwrite = TRUE
)



# The 2D baseline check
# Define the nuuk palette - a
# colorblind-friendly scientific palette
# from the scico package. Nuuk features
# cool blues transitioning to warm
# earth tones, designed for perceptual
# uniformity across all forms of
# color vision deficiency [CVD]
# (deuteranopia, protanopia, tritanopia)

nuuk_pal <- scico::scico(100, palette = "nuuk")

terra::plot(
        dem_utm,
        col = nuuk_pal,
        main = "Mount Fuji Elevation (m)"
)


# Generate CVD-simulated versions of our nuuk palette
nuuk_deutan <- colorspace::deutan(nuuk_pal)
nuuk_protan <- colorspace::protan(nuuk_pal)
nuuk_tritan <- colorspace::tritan(nuuk_pal)


# Create a 2x2 comparison plot
par(mfrow = c(2, 2), mar = c(2, 2, 3, 4))

terra::plot(
        dem_utm, col = nuuk_pal,
        main = "Original (nuuk palette)"
)

terra::plot(
        dem_utm, col = nuuk_deutan,
        main = "Deuteranopia simulation"
)

terra::plot(
        dem_utm, col = nuuk_protan,
        main = "Protanopia simulation"
)

terra::plot(
        dem_utm, col = nuuk_tritan,
        main = "Tritanopia simulation"
)



# The minimal 3D render
# First, convert our raster object to a matrix
fuji_matrix <- rayshader::raster_to_matrix(
        dem_utm
)

# Use nuuk palette for 3D rendering
# 256 colors for smooth gradients
nuuk_texture <- scico::scico(256, palette = "nuuk")


# Then, we build our 3D map layer by layer
fuji_matrix |>
        rayshader::height_shade(
                texture = nuuk_texture
        ) |>
        rayshader::add_shadow(
                rayshader::ray_shade(
                        fuji_matrix,
                        zscale = 30
                ), 0.6
        ) |>
        rayshader::add_shadow(
                rayshader::lamb_shade(
                        fuji_matrix,
                        zscale = 30
                ), 0.6
        ) |>
        rayshader::plot_3d(
                fuji_matrix,
                zscale = 30,
                theta = 135,
                phi = 30,
                zoom = 0.9
        )



# Exporting the graphic
# First, close the interactive
# window, if it's still open
if (rgl::rgl.cur() > 0) {
        rgl::close3d()
}


# Use nuuk palette for 3D rendering
# 256 colors for smooth gradients
nuuk_texture <- scico::scico(256, palette = "nuuk")


# Re-run the plot_3d command
# with our nuuk palette
fuji_matrix |>
        rayshader::height_shade(
                texture = nuuk_texture
        ) |>
        rayshader::add_shadow(
                rayshader::ray_shade(
                        fuji_matrix,
                        zscale = 30
                ), 0.6
        ) |>
        rayshader::add_shadow(
                rayshader::lamb_shade(
                        fuji_matrix,
                        zscale = 30
                ), 0.6
        ) |>
        rayshader::plot_3d(
                fuji_matrix,
                zscale = 30,
                theta = 135,
                phi = 30,
                zoom = 0.9
        )


# Save a high-resolution snapshot
rayshader::render_snapshot(
        filename = here::here(
                "outputs", "images",
                "plot1_2.png"
        ),
        title_text = "Mount Fuji, Japan",
        title_bar_color = "#1e3d59",
        title_color = "white",
        vignette = 0.2,
        width = 2400,
        hight = 2400
)
