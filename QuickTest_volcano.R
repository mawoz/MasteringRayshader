## mastering rayshader
## by milos popovic

# test file for rayshader setup ("volcano")

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
