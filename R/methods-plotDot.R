#' Plot Dot
#'
#' @rdname plotDot
#' @name plotDot
#'
#' @author Michael Steinbaugh
#'
#' @inheritParams AllGenerics
#' @param genes Character vector of gene symbols.
#' @param colors Named character vector (`low`, `high`) for plot colors.
#' @param colMin Minimum scaled average expression threshold. Everything
#'   smaller will be set to this.
#' @param colMax Maximum scaled average expression threshold. Everything larger
#'   will be set to this.
#' @param dotMin The fraction of cells at which to draw the smallest dot. All
#'   cell groups with less than this expressing the given gene will have no dot
#'   drawn.
#' @param dotScale Scale the size of the points, similar to `cex`.
#'
#' @note [Seurat::DotPlot()] is still plotting even when `do.return = TRUE`.
#' In the meantime, we've broken out the code into this generic to fix
#' RMarkdown looping of our marker plots.
#'
#' @seealso Modified version of [Seurat::DotPlot()].
#'
#' @examples
#' \dontrun{
#' data(seurat)
#' plotDot(seurat, genes = "Hspe1")
#' }
NULL



# Constructors ====
#' Min Max
#' @seealso `Seurat:::MinMax()`
#' @noRd
.minMax <- function(data, min, max) {
    data2 <- data
    data2[data2 > max] <- max
    data2[data2 < min] <- min
    data2
}



#' Percent Above
#' @seealso `Seurat:::PercentAbove()`
#' @noRd
.percentAbove <- function(x, threshold) {
    length(x[x > threshold]) / length(x)
}



# Methods ====
#' @rdname plotDot
#' @export
setMethod("plotDot", "seurat", function(
    object,
    genes,
    colors = c(low = "white", high = "black"),
    colMin = -2.5,
    colMax = 2.5,
    dotMin = 0,
    dotScale = 6) {
    data <- FetchData(object, vars.all = genes) %>%
        as.data.frame() %>%
        rownames_to_column("cell") %>%
        mutate(ident = object@ident) %>%
        gather(
            key = "symbol",
            value = "expression",
            !!genes) %>%
        group_by(!!!syms(c("ident", "symbol"))) %>%
        summarize(
            avgExp = mean(expm1(.data[["expression"]])),
            pctExp = .percentAbove(.data[["expression"]], threshold = 0)
        ) %>%
        ungroup() %>%
        group_by(!!sym("symbol")) %>%
        mutate(avgExpScale = scale(.data[["avgExp"]])) %>%
        mutate(
            avgExpScale = .minMax(
                .data[["avgExpScale"]],
                max = colMax,
                min = colMin)
        )
    data[["pctExp"]][data[["pctExp"]] < dotMin] <- NA
    ggplot(
        data = data,
        mapping = aes_string(
            x = "symbol",
            y = "ident")
    ) +
        geom_point(
            mapping = aes_string(
                color = "avgExpScale",
                size = "pctExp")
        ) +
        scale_radius(range = c(0, dotScale)) +
        scale_color_gradient(
            low = colors[["low"]],
            high = colors[["high"]]) +
        labs(x = "gene",
             y = "ident")
})